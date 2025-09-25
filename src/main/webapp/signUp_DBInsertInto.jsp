<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<html>
<body>
	<%
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String memberid = new String(request.getParameter("memberid"));
	String memberpwd = new String(request.getParameter("memberpwd"));

    try {
        // Check if the memberId already exists in the database
        String checkSql = "SELECT COUNT(*) FROM personal_information WHERE memberId = ?";
        PreparedStatement checkStmt = con.prepareStatement(checkSql);
        checkStmt.setString(1, memberid);
        ResultSet rs = checkStmt.executeQuery();
        
        // If the memberId exists, redirect to the sign-up page with a status
        if (rs.next() && rs.getInt(1) > 0) {
            response.sendRedirect("signUp.jsp?status=IDexist");
        } else {
            // If memberId does not exist, proceed with the INSERT operation
            String sql = "INSERT INTO personal_information (memberId, memberPwd) VALUES (?, ?)";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberid);  // Set memberid in the query
            pstmt.setString(2, memberpwd); // Set memberpwd in the query

            // Execute the query
            pstmt.executeUpdate();
            pstmt.close();

            // Redirect to login page with a status indicating a new member was added
            response.sendRedirect("login.jsp?status=newmember");
        }

        // Close resources
        rs.close();
        con.close();

    } catch (Exception e) {
        // Handle any exceptions and provide feedback
        e.printStackTrace();
        response.sendRedirect("signUp.jsp?status=error");
    }
%>

</body>
</html>
