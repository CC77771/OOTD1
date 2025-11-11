<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>

<%
    // 接收參數
    String postId = request.getParameter("postId");
    String action = request.getParameter("action"); // "reject" 或 "approve"

    String message = "";
    boolean success = false;

    if(postId != null && action != null && !postId.trim().isEmpty()) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            // ✅ Access 資料庫檔案路徑
            // Java 也接受正斜線
			String dbPath = "C://Users//user//Documents//OODT1//OOTD1//src//main//webapp//OOTD1.accdb";

            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

            String sql = "";
            
            if("reject".equals(action)) {
                // ✅ 拒絕評論：將 post_state 取消打勾
                // Access Yes/No 欄位：False = 0 或 False
                sql = "UPDATE personal_wear SET post_state = False WHERE postid = ?";
                message = "評論已拒絕";
            } else if("approve".equals(action)) {
                // ✅ 通過評論：將 post_state 打勾
                // Access Yes/No 欄位：True = -1 或 True
                sql = "UPDATE personal_wear SET post_state = True WHERE postid = ?";
                message = "評論已通過";
            } else {
                message = "無效的操作";
            }

            if(!sql.isEmpty()) {
                pstmt = con.prepareStatement(sql);
                // postid 是數字型態，所以用 setInt
                pstmt.setInt(1, Integer.parseInt(postId));
                
                int result = pstmt.executeUpdate();

                if(result > 0) {
                    success = true;
                    message += "，已更新 " + result + " 筆資料";
                } else {
                    message = "找不到 postid = " + postId + " 的資料";
                }
            }

        } catch(NumberFormatException e) {
            message = "postId 格式錯誤: " + postId;
            e.printStackTrace();
        } catch(ClassNotFoundException e) {
            message = "找不到資料庫驅動程式";
            e.printStackTrace();
        } catch(SQLException e) {
            message = "資料庫操作失敗: " + e.getMessage();
            e.printStackTrace();
        } catch(Exception e) {
            message = "系統錯誤: " + e.getMessage();
            e.printStackTrace();
        } finally {
            // 關閉資源
            try {
                if(pstmt != null) pstmt.close();
                if(con != null) con.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        message = "參數錯誤 (postId=" + postId + ", action=" + action + ")";
    }

    // ✅ 回到管理者頁面 manager3.jsp
    response.sendRedirect("manager3.jsp?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&success=" + success);
%>