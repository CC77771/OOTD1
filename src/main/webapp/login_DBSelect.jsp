<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<%
if(request.getParameter("memberid") !=null &&
	request.getParameter("memberpwd") !=null){
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String getMemberData = "SELECT memberid FROM Personal_information WHERE memberid='"+
			request.getParameter("memberid")+"' AND memberpwd='" +
			request.getParameter("memberpwd")+"'";
	ResultSet members = smt.executeQuery(getMemberData);
	if(members.next()){
		session.setAttribute("accessId",request.getParameter("memberid"));
		//session.setMaxInactiveInterval(20); 自動登出
		response.sendRedirect("index1.jsp");
	}else
		response.sendRedirect("login.jsp?status=loginerror");
}
%>