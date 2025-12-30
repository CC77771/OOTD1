<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
    String memberId = request.getParameter("memberId");
    String styleTitle = request.getParameter("styleTitle");

    String message = "";

    if(memberId != null && styleTitle != null) {
        try {
            String dbPath = objDBConfig.FilePath();
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

            // 更新 authorization 欄位為 false（軟刪除）
            String sql = "UPDATE commodity_information SET authorization = ? WHERE memberId = ? AND commodity_title = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setBoolean(1, false);
            pstmt.setString(2, memberId);
            pstmt.setString(3, styleTitle);

            int result = pstmt.executeUpdate();

            pstmt.close();
            con.close();

            if(result > 0) {
                message = "刪除成功";
            } else {
                message = "找不到該穿搭組合";
            }

        } catch(Exception e) {
            message = "刪除失敗: " + e.getMessage();
            e.printStackTrace();
        }
    } else {
        message = "參數錯誤";
    }

    // 刪除完成後，導向回 merchant.jsp
    response.sendRedirect("merchant.jsp");
%>