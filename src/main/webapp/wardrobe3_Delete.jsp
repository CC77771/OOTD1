<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
    String memberId = request.getParameter("memberId");
    String clothing_number = request.getParameter("clothing_number");
    String category = request.getParameter("category");
    
    // 預設返回頁面
    if(category == null || category.isEmpty()) {
        category = "衣服";
    }
    
    String message = "";
    
    if(memberId != null && clothing_number != null) {
        try {
            String dbPath = objDBConfig.FilePath();
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
            
            // 只更新 state 欄位為 No，不刪除資料
            String sql = "UPDATE my_wardrobe SET state = 'False' WHERE memberId = ? AND clothing_number = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.setString(2, clothing_number);
            
            int result = pstmt.executeUpdate();
            
            pstmt.close();
            con.close();
            
            if(result > 0) {
                message = "刪除成功";
            } else {
                message = "找不到該衣物";
            }
            
        } catch(Exception e) {
            message = "刪除失敗: " + e.getMessage();
            e.printStackTrace();
        }
    } else {
        message = "參數錯誤";
    }
    
    // 刪除完成後，導向回原本的分類頁面
    response.sendRedirect("my_wardrobe3.jsp?category=" + java.net.URLEncoder.encode(category, "UTF-8"));
%>