<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file = "menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>CZ Web</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f0; 
            color: #333;
        }

        .container {
            max-width: 900px;
            margin: 40px auto;
            background: #fff;
            border-radius: 10px;
            padding: 40px 30px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            border: 1px solid #e0e0e0;
        }

        h1, h3 {
            font-size: 28px;
            font-weight: 600;
            color: #333;
        }

        h3 {
            font-size: 22px;
            margin-bottom: 20px;
        }

        .info {
            text-align: center; 
            margin-bottom: 30px;
        }

        .info span {
            font-size: 16px;
            color: #666;
            margin-top: 10px;
            display: block;
        }

        /* 头像 */
        .profile-image {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }

        .profile-image img {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            border: 3px solid #a89f91; /* 修改為 #a89f91 */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        
        .form-section {
            margin-top: 30px;
        }

        .form-section input[type="text"],
        .form-section select,
        .form-section input[type="file"],
        .form-section button {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border-radius: 8px;
            border: 1px solid #ddd;
            margin-bottom: 20px;
            box-sizing: border-box;
        }

        .form-section input[type="text"],
        .form-section select {
            background-color: #f9f9f9; 
        }

        .form-section button {
            background: #a89f91; 
            color: white;
            border: none;
            cursor: pointer;
        }

        .form-section button:hover {
            background: #8b8d7a;
        }

        /* 下拉選單 */
        .dropdown {
            position: relative;
            display: inline-block;
        }

        .dropdown button {
            background: #a89f91; 
            color: #fff;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
        }

        .dropdown-content {
            display: none;
            position: absolute;
            background-color: #fff;
            min-width: 160px;
            box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.2);
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #ddd;
        }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        .dropdown-content select {
            background-color: #fff;
            border: 1px solid #ddd;
            font-size: 16px;
            padding: 12px;
            border-radius: 8px;
            width: 100%;
        }

        .dropdown-content button {
            background: #a89f91;
            color: white;
            font-size: 16px;
            padding: 12px;
            cursor: pointer;
            border-radius: 8px;
            width: 100%;
            margin-top: 10px;
        }

        .dropdown-content button:hover {
            background: #8b8d7a; 
        }

        /* 響應式設計 */
        @media screen and (max-width: 600px) {
            .container {
                margin: 10px;
                padding: 20px;
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
.custom-button {
    background-color: #a89f91;
    color: #fff;
    border: none;
    padding: 10px 30px;
    border-radius: 5px;
    text-decoration: none;
    cursor: pointer;
    display: inline-block;
    text-align: center;
}

    </style>
</head>
<body>
<%
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	//out.println("Con= "+con);
	Statement smt= con.createStatement();
	String sql = "SELECT * FROM personal_information " +
            "LEFT JOIN position ON personal_information.positionId = position.positionId " +
            "LEFT JOIN gender ON personal_information.gendercode = gender.gendercode " + 
            "WHERE memberId = '" + session.getAttribute("accessId") + "'";
	
	ResultSet rs = smt.executeQuery(sql);
	rs.next();
	%>
    <div class="container">
         <%
        // 假設資料庫查詢結果
        String name = rs.getString("nickName");
        String position = rs.getString("positionName");

        // 新增從資料庫提取的 researchFields 資訊
        String gender = rs.getString("gender");  // 假設資料庫中有 gender 欄位
        String birthdate = rs.getString("born");
        if (birthdate != null && birthdate.contains(" ")) {
            birthdate = birthdate.split(" ")[0]; // 只保留日期部分
        }

        String email = rs.getString("Email");
        if (email != null) {
            // 移除多餘的部分
            email = email.split("#")[0];
        }


        // 拼接 researchFields
        String researchFields = gender + ", " + birthdate + ", " + email;
    %>
    


        <!-- Profile Section -->
        <div class="profile-image">
            <img src="<%=rs.getString("pic") %>?t=<%= System.currentTimeMillis() %>" alt="Profile Picture"> <!-- 替換成實際圖片路徑 -->
        </div>
        <div class="info">
        <h1><%= name %></h1> <!-- 顯示 Nickname -->
        <h3><%= position %></h3>
    </div>

        <!-- Research Fields Section -->
        <div class="form-section">
            <h3>個人資料：</h3>
            <ul>
                <% for (String field : researchFields.split(",")) { %>
                    <li><%= field.trim() %></li>
                <% } %>
            </ul>
        </div>
      
<form name="form" action="memberEdit_DBUpdate_pic.jsp" method="post" enctype="multipart/form-data">
    <input type="file" name="theFirstFile" />
     <input type="hidden" name="memberId" value="<%=rs.getString("memberId")%> " />
  <button type="submit" value="上傳圖片" name="submitButton" style="background-color: #a89f91; color: #fff; border: none; padding: 10px 30px; border-radius: 5px; cursor: pointer;">
修改圖片
</button>
</form>

<a href="memberEdit1.jsp?memberId=<%=rs.getString("memberId")%>"  class="custom-button">編輯</a>

 
</div>

</body>
</html>
