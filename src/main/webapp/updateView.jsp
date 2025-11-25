<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<%
    String postid = request.getParameter("postid");
    
    System.out.println("=== updateView.jsp 被呼叫 ===");
    System.out.println("收到的 postid: " + postid);
    
    if (postid != null && !postid.isEmpty()) {
        Connection con = null;
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
            
            // 關鍵：設定為手動提交
            con.setAutoCommit(false);
            
            System.out.println("資料庫連線成功");
            
            // 先查詢目前的值
            String checkSql = "SELECT view FROM personal_wear WHERE postid = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, postid);
            ResultSet checkRs = checkStmt.executeQuery();
            
            int currentView = 0;
            if (checkRs.next()) {
                currentView = checkRs.getInt("view");
                if (checkRs.wasNull()) {
                    currentView = 0;
                }
                System.out.println("目前的 view 值: " + currentView);
            }
            checkRs.close();
            checkStmt.close();
            
            // 計算新的值
            int newView = currentView + 1;
            
            // 更新瀏覽次數 - 直接設定新值
            String updateSql = "UPDATE personal_wear SET view = ? WHERE postid = ?";
            PreparedStatement pstmt = con.prepareStatement(updateSql);
            pstmt.setInt(1, newView);
            pstmt.setString(2, postid);
            int updateCount = pstmt.executeUpdate();
            
            System.out.println("更新影響的行數: " + updateCount);
            System.out.println("新的 view 值: " + newView);
            
            pstmt.close();
            
            // 關鍵：提交事務
            con.commit();
            System.out.println("✅ 事務已提交");
            
            // 回傳新的瀏覽數
            out.print(newView);
            
        } catch (Exception e) {
            System.out.println("❌ 發生錯誤: " + e.getMessage());
            e.printStackTrace();
            
            // 發生錯誤時回滾
            if (con != null) {
                try {
                    con.rollback();
                    System.out.println("事務已回滾");
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
            out.print("error");
        } finally {
            // 關閉連線
            if (con != null) {
                try {
                    con.setAutoCommit(true); // 恢復自動提交
                    con.close();
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
        }
    } else {
        System.out.println("postid 是 null 或空的");
        out.print("error");
    }
%>