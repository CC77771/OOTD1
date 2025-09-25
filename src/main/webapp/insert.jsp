<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<title>新增會員資料</title>
</head>
<style>
body {font-family: Arial, Helvetica, sans-serif;}
form {border: 3px solid #f1f1f1;}

input[type=text], input[type=password] {
  width: 100%;
  padding: 12px 20px;
  margin: 8px 0;
  display: inline-block;
  border: 1px solid #ccc;
  box-sizing: border-box;
}

button {
  background-color: #8B8378;
  color: white;
  padding: 14px 20px;
  margin: 8px 0;
  border: none;
  cursor: pointer;
  width: 100%;
}

button:hover {
  opacity: 0.8;
}

.container {
  padding: 16px;
}

span.memberpwd {
  float: right;
  padding-top: 16px;
}

</style>
<body>
<form action="insert_DB.jsp" method="post" style="border:1px solid #ccc">
  <div class="container">
    <h1>新增會員資料</h1>
    <hr>
    <label for="stuID"><b>帳號</b></label>
    <input type="text" placeholder="memberid" name="memberid" required>

    <label for="stuPersonName"><b>姓名</b></label>
    <input type="text" placeholder="nickname" name="nickname" required>

  <label for="stuAddress"><b>Email</b></label>
    <input type="text" placeholder="email" name="email" required>


    <div class="clearfix">
      <button type="submit" class="signupbtn">新增</button>
      <button type="reset" class="cancelbtn">取消</button>
    </div>
  </div>
</form>
</body>
</html>