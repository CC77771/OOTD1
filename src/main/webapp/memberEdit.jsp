<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<%@include file = "menu.jsp" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>LeeLab Web</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
  <link href="//fonts.googleapis.com/css2?family=Merriweather:wght@300;400;700;900&amp;display=swap" rel="stylesheet">
  <link href="//fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900&amp;display=swap" rel="stylesheet">
  <!-- Template CSS -->
  <link rel="stylesheet" href="assets/css/style-starter.css">
  <meta name="keywords" content="leelab">
  <meta name="description" content="This is for example.">
</head>
<body>
	<%
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String sql = "SELECT * FROM personal_information left join gender on personal_information.gendercode=gender.gendercode WHERE memberId ='" +request.getParameter("memberId")+"'";
	String option="SELECT * FROM gender";
	ResultSet rs = smt.executeQuery(sql);
	ResultSet rs2 = smt.executeQuery(option);
	rs.next();
	%>
 <form action="memberEdit_DBUpdate_info.jsp?memberId=<%=request.getParameter("memberId")%>" method="post" name="form" >
  <section class="w3l-aboutblock py-5" id="about">
    <div class="midd-w3">
      <div class="container py-lg-5 py-md-3">
        <div class="row">
          <div class="col-lg-4 left-wthree-img text-righ">
            <div class="position-relative">
            <img src="<%=rs.getString("pic") %>" alt="">
            <h3>選擇要上傳的文件:</h3>
            <input type="file" name="theFirstFile" size="50" />
            <input type="button" onClick="javascript:del();" name=submitButton value="上傳" />
			<script language="javascript">  
			//點選提交按鈕觸發下面的函式
			function del(){  
				document.form.action="memberEdit_DBUpdate_pic.jsp";
				document.form.enctype="multipart/form-data";
				document.form.submit();
			}  
			</script>         
         </div>
          </div>
          <div class="col-lg-8 mt-lg-0 mt-5 about-right-faq align-self">
          <h3 class="title-big"><%=rs.getString("nickName") %></h3>
            <p><%=rs.getString("positionName") %></p>
           
            <p class="mt-4"><b>個人資料：</b></p>
            <ol class="w3l-right mt-4">
             <select name="gender" class="btn btn-select">
            	<li><option value="<%=rs.getString("gendercode") %>" style="display: none"></option>
            	<%  while(rs2.next()){ %>
            	<option value="<%=rs2.getString("gendercode")%>"><%=rs2.getString("gender")%></option></li>
        		<% } %>
            </select>              
              <%if (rs.getString("born")== null){
            	  }else{%><li><%=rs.getString("born") %></li>
              <%} %>
              <%if (rs.getString("Email")== null){
            	  }else{%><li><%=rs.getString("Email") %></li>
              <%} %>
            </ol>
            <p>修改個人資料：</p>
            <input type="text" name="gender" value="<%=rs.getString("gender") %>" /><br>
            <input type="text" name="born" value="<%=rs.getString("born") %>"/><br>
            <input type="text" name="Email" value="<%=rs.getString("Email") %>"/><br><br>
            <input type="submit" name=submitButton class="btn btn-style btn-effect" value="確認修改" />
          </div>
        </div>
      </div>
    </div>
  </section>
</form>
  
 
  </body>
</html>