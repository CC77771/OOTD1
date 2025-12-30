<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
try {
    request.setCharacterEncoding("UTF-8");
    
    String memberId = request.getParameter("memberId");
    String styleTitle = request.getParameter("styleTitle");
    
    out.println("<!-- 刪除請求 -->");
    out.println("<!-- memberId: " + memberId + " -->");
    out.println("<!-- styleTitle: " + styleTitle + " -->");
    
    // 連接資料庫
    String dbPath = objDBConfig.FilePath();
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
    
    // 更新 authorization 為 false (軟刪除)
    String updateSql = "UPDATE commodity_information SET authorization = ? WHERE memberId = ? AND commodity_title = ?";
    PreparedStatement pstmt = con.prepareStatement(updateSql);
    pstmt.setBoolean(1, false);
    pstmt.setString(2, memberId);
    pstmt.setString(3, styleTitle);
    
    int rowsAffected = pstmt.executeUpdate();
    
    out.println("<!-- 更新筆數: " + rowsAffected + " -->");
    
    pstmt.close();
    con.close();
    
    if(rowsAffected > 0) {
        response.setStatus(200);
        out.println("SUCCESS: 已成功刪除 " + rowsAffected + " 筆資料");
    } else {
        response.setStatus(404);
        out.println("ERROR: 找不到符合的資料");
    }
    
} catch(Exception e) {
    out.println("<!-- 錯誤: " + e.getMessage() + " -->");
    e.printStackTrace(new java.io.PrintWriter(out));
    response.setStatus(500);
    out.println("ERROR: " + e.getMessage());
}
%>