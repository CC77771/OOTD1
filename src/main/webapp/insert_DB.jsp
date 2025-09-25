<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>

<%@page import="java.sql.*"%>

	<%
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://C:\\Users\\My\\eclipse-workspace\\CZ\\src\\main\\webapp\\穿櫥自己的OOTD1.accdb;");
	Statement smt= con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,ResultSet.CONCUR_READ_ONLY);
	String memberid = new String(request.getParameter("memberid"));
	String nickname = new String(request.getParameter("nickname"));
	String email = new String(request.getParameter("email"));
	String updateSql = "UPDATE personal_information SET nickname = ?, email = ? WHERE memberid = ?";
	PreparedStatement pstmt = con.prepareStatement(updateSql);

	// 設定更新的欄位值
	pstmt.setString(1, nickname);
	pstmt.setString(2, email);
	pstmt.setString(3, memberid);

	// 執行更新操作
	int rowsUpdated = pstmt.executeUpdate();
	
	// 輸出執行結果
	if (rowsUpdated > 0) {
		out.println("資料更新成功！");
	} else {
		out.println("找不到要更新的資料！");
	}
	
	con.close();
	//response.sendRedirect("insert.jsp");
	%>
