<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*,java.util.*"%>
<%@include file = "menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CZ Web</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .profile-container {
            background-color: #ffffff;
            border: 1px solid #ddd;
            border-radius: 10px;
            width: 400px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .profile-container .photo {
            width: 100px;
            height: 100px;
            background-color: #ccc;
            border-radius: 50%;
            margin: 0 auto 20px;
        }
        .profile-container h2 {
            color: #4a4a4a;
            font-size: 1.5em;
            margin: 0 0 10px;
        }
        .profile-container h3 {
            color: #7d7d7d;
            font-size: 1em;
            margin: 0 0 20px;
        }
        .profile-container ul {
            list-style: none;
            padding: 0;
            margin: 0 0 20px;
        }
        .profile-container ul li {
            color: #4a4a4a;
            font-size: 0.9em;
            margin: 5px 0;
        }
        .profile-container button {
            background-color: #a89f91;
            color: #fff;
            border: none;
            border-radius: 5px;
            padding: 10px 20px;
            font-size: 0.9em;
            cursor: pointer;
        }
        .profile-container button:hover {
            background-color: #918b7e;
        }

            .profile-image img {
                width: 120px;
                height: 120px;
            }

            h1 {
                font-size: 24px;
            }

            h3 {
                font-size: 20px;
            }

            .form-section input[type="text"],
            .form-section select,
            .form-section button {
                padding: 10px;
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
<%	
	request.setCharacterEncoding("UTF-8");
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String sk1 = request.getParameter("gender");
	String sk2 = request.getParameter("born");
	String sk3 = request.getParameter("Email");
	
	smt.executeUpdate("UPDATE personal_information SET gendercode='" + sk1+"', born ='" + sk2+"', Email ='" + sk3 +"' WHERE memberId ='" + request.getParameter("memberId")+"' ");
	response.sendRedirect("member.jsp?memberId="+request.getParameter("memberId")+"");
%>
</body>
</html>