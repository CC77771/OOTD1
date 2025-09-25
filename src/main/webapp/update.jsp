<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.sql.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<html>
<body>
<%
String wearId = request.getParameter("wearId"); // 獲取 wearId
String commentText = request.getParameter("text"); // 獲取留言文本
String memberId = request.getParameter("memberId");
if (wearId != null && commentText != null && !commentText.trim().isEmpty()) {
    Connection con = null;
    PreparedStatement pstmt = null;
    try {
        // 創建數據庫連接
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        // SQL 插入語句
        String insertCommentQuery = "INSERT INTO personal_wear (wearId, message,memberId) VALUES (?, ?, ?)";
        pstmt = con.prepareStatement(insertCommentQuery);

        // 設定參數
        pstmt.setString(1, wearId);
        pstmt.setString(2, commentText);
        pstmt.setString(3, memberId);
        // 執行更新操作
        pstmt.executeUpdate();

    } catch (SQLException e) {
        // 捕獲並顯示錯誤
        e.printStackTrace(); // 可以記錄到日志或顯示具體錯誤信息
        response.getWriter().println("發生錯誤，請稍後再試。"); // 顯示友好的錯誤信息給用戶
    } finally {
        // 確保資源在使用後被關閉
        try {
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace(); // 處理資源關閉時的異常
        }
    }
}

// URL 編碼 wearId 和 accessId 參數
String encodedWearId = URLEncoder.encode(wearId, "UTF-8");
String accessId = (String) session.getAttribute("accessId");
String encodedAccessId = URLEncoder.encode(accessId, "UTF-8");

// 重定向到 index1.jsp，使用 URL 編碼後的參數
response.sendRedirect("index1.jsp?wearId=" + encodedWearId + "&accessId=" + encodedAccessId);
%>
</body>
</html>
