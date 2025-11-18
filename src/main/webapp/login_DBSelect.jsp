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
	String getMemberData = "SELECT memberid, positionId, blacklist FROM Personal_information WHERE memberid='" +
			request.getParameter("memberid")+"' AND memberpwd='" +
			request.getParameter("memberpwd")+"'";
	ResultSet members = smt.executeQuery(getMemberData);
	if(members.next()){
		// 檢查是否被停權
		boolean isBlacklisted = members.getBoolean("blacklist");
		
		if(isBlacklisted){
			// 帳號已被停權,拒絕登入
			members.close();
			smt.close();
			con.close();
			response.sendRedirect("login.jsp?status=blacklisted");
		} else {
			// 帳號正常,允許登入
			session.setAttribute("accessId", request.getParameter("memberid"));
			session.setAttribute("positionId", members.getString("positionId"));
			//session.setMaxInactiveInterval(20); 自動登出
			members.close();
			smt.close();
			con.close();
			response.sendRedirect("index1.jsp");
		}
	} else {
		// 帳號或密碼錯誤
		smt.close();
		con.close();
		response.sendRedirect("login.jsp?status=loginerror");
	}
}
%>