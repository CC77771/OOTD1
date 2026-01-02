<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
request.setCharacterEncoding("UTF-8");

String postid = request.getParameter("postid");
String memberId = request.getParameter("memberId");
String action = request.getParameter("action"); // "add" 或 "remove"

if (postid != null && memberId != null && action != null) {
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        if (action.equals("add")) {
            // 新增按讚記錄
            String insertSql = "INSERT INTO user_likes (memberId, postid) VALUES (?, ?)";
            pstmt = con.prepareStatement(insertSql);
            pstmt.setString(1, memberId);
            pstmt.setInt(2, Integer.parseInt(postid));
            pstmt.executeUpdate();
            pstmt.close();
            
            // 更新貼文的按讚數 +1
            String updateSql = "UPDATE personal_wear SET [like] = [like] + 1 WHERE postid = ? AND post_state = True";
            pstmt = con.prepareStatement(updateSql);
            pstmt.setInt(1, Integer.parseInt(postid));
            pstmt.executeUpdate();
            
        } else if (action.equals("remove")) {
            // 刪除按讚記錄
            String deleteSql = "DELETE FROM user_likes WHERE memberId = ? AND postid = ?";
            pstmt = con.prepareStatement(deleteSql);
            pstmt.setString(1, memberId);
            pstmt.setInt(2, Integer.parseInt(postid));
            pstmt.executeUpdate();
            pstmt.close();
            
            // 更新貼文的按讚數 -1
            String updateSql = "UPDATE personal_wear SET [like] = [like] - 1 WHERE postid = ? AND post_state = True AND [like] > 0";
            pstmt = con.prepareStatement(updateSql);
            pstmt.setInt(1, Integer.parseInt(postid));
            pstmt.executeUpdate();
        }
        
        pstmt.close();
        
        // 查詢最新的按讚數
        String selectSql = "SELECT [like] FROM personal_wear WHERE postid = ? AND post_state = True";
        pstmt = con.prepareStatement(selectSql);
        pstmt.setInt(1, Integer.parseInt(postid));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            out.print(rs.getInt("like"));
        } else {
            out.print("error");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.print("error");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
} else {
    out.print("error");
}
%>