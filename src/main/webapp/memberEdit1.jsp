<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<%@include file = "menu.jsp" %>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>編輯個人資料 - CZ Web</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #f9f9f9;
        }
        .profile-container {
            background-color: #ffffff;
            border: 1px solid #ddd;
            border-radius: 10px;
            width: 450px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .profile-image img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            margin-bottom: 20px;
        }
        .profile-container h2 {
            font-size: 1.5em;
            color: #333;
            margin-bottom: 10px;
        }
        .profile-container h3 {
            font-size: 1.2em;
            color: #7d7d7d;
            margin-bottom: 20px;
        }
        .profile-container p {
            font-size: 1em;
            color: #555;
            margin-bottom: 20px;
        }
        .profile-container ul {
            list-style: none;
            padding: 0;
        }
        .profile-container ul li {
            font-size: 0.9em;
            color: #555;
            margin: 5px 0;
        }
        .form-group {
            margin-bottom: 15px;
            text-align: left;
        }
        .form-group input[type="text"],
        .form-group select {
            width: 100%;
            padding: 10px;
            font-size: 1em;
            margin-top: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .form-group input[type="submit"] {
            background-color: #a89f91;
            color: white;
            padding: 12px 20px;
            font-size: 1em;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            width: 100%;
        }
        .form-group input[type="submit"]:hover {
            background-color: #918b7e;
        }
        .form-group label {
            font-weight: bold;
            color: #333;
        }
        .form-group input[type="text"] {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <%
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    Statement smt = con.createStatement();
    String sql = "SELECT * FROM personal_information LEFT JOIN gender ON personal_information.gendercode = gender.gendercode WHERE memberId ='" + request.getParameter("memberId") + "'";
    ResultSet rs = smt.executeQuery(sql);
    
    // 獲取第一行數據
    rs.next();
    String profilePic = rs.getString("pic");
    String nickName = rs.getString("nickName");
    String gender = rs.getString("gender");
    String genderCode = rs.getString("gendercode");
    String born = rs.getString("born");
    String email = rs.getString("Email");
%>
<div class="container">
    <div class="profile-container">
        <form action="memberEdit_DBUpdate_info.jsp?memberId=<%=request.getParameter("memberId")%>" method="post" name="form">
            <div class="profile-image">
                <img src="<%=profilePic %>" alt="Profile Picture">
            </div>
            <h2><%=nickName %></h2>
            
            <p><b>個人資料：</b></p>
            <ul>
                <li><b>性別：</b><%=gender %></li>
                <%
if (born != null && born.contains(" ")) {
    born = born.split(" ")[0]; // 只保留日期部分
}
if (born != null) {
%>
    <li><b>生日：</b><%= born %></li>
<% 
}
%>

                
                <% if (email != null) { %>
                    <li><b>電子信箱：</b><%=email %></li>
                <% } %>
            </ul>
            <p>修改個人資料：</p>
            <div class="form-group">
                <label for="gender">性別</label>
                <select name="gender" id="gender">
                    <option value="<%=genderCode %>" style="display: none"><%=gender %></option>
                    <% 
                        // 再次執行查詢獲取所有性別選項
                        sql = "SELECT * FROM gender";
                        rs = smt.executeQuery(sql);
                        while (rs.next()) { 
                    %>
                        <option value="<%=rs.getString("gendercode") %>"><%=rs.getString("gender") %></option>
                    <% } %>
                </select>
            </div>
       
        
        <div class="form-group">
                    <label for="born">生日</label>
                    <input type="date" id="born" name="born" value="<%=born %>">
                </div>
                <div class="form-group">
                    <label for="email">電子信箱</label>
                    <input type="text" id="email" name="Email" value="<%=email%>">
                </div>
                <div class="form-group">
                    <input type="submit" name="submitButton" class="btn btn-style" value="確認修改">
                </div>
         

    </div>
</div>

                
       
</body>
</html>
