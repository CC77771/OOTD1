<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<html>
<body>
<%
String postid = request.getParameter("postid"); // 獲取 postid
String commentText = request.getParameter("text"); // 獲取留言文本
String memberId = request.getParameter("memberId"); // 獲取會員ID

if (postid != null && commentText != null && !commentText.trim().isEmpty() && memberId != null) {
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // 創建數據庫連接
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        // 先查詢該 postid 的原始貼文資料
        String selectQuery = "SELECT memberid, wearId, pic, [like], collect, view, post_state FROM personal_wear WHERE postid = ? AND message IS NULL";
        pstmt = con.prepareStatement(selectQuery);
        pstmt.setInt(1, Integer.parseInt(postid));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            // 不需要取得原始貼文的 memberid，因為留言要用留言者自己的 memberId
            String wearId = rs.getString("wearId");
            String pic = rs.getString("pic");
            int likeCount = rs.getInt("like");
            int collectCount = rs.getInt("collect");
            int viewCount = rs.getInt("view");
            boolean postState = rs.getBoolean("post_state");
            
            // 關閉第一個查詢
            rs.close();
            pstmt.close();
            
         // SQL 插入語句：插入留言
            String insertCommentQuery = "INSERT INTO personal_wear (postid, memberid, wearId, message, pic, [like], collect, view, post_state) " +
                                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(insertCommentQuery);

            // 設定參數
            pstmt.setInt(1, Integer.parseInt(postid));  // postid（相同）
            pstmt.setString(2, memberId);               // ✅ 正確：用留言者的 memberId
            pstmt.setString(3, wearId);                 
            pstmt.setString(4, commentText);            
            pstmt.setString(5, pic);                    
            pstmt.setInt(6, likeCount);                 
            pstmt.setInt(7, collectCount);              
            pstmt.setInt(8, viewCount);                 
            pstmt.setBoolean(9, postState);
            
            // 執行插入操作
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                out.println("<script>alert('留言提交成功！');</script>");
            }
        } else {
            out.println("<script>alert('找不到該貼文！');</script>");
        }

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<script>alert('發生錯誤：" + e.getMessage() + "');</script>");
    } catch (NumberFormatException e) {
        out.println("<script>alert('postid 格式錯誤！');</script>");
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
    out.println("<script>alert('請輸入完整資訊！');</script>");
}

// 重定向回 index1.jsp
out.println("<script>window.location.href='index1.jsp';</script>");
%>
</body>
</html>