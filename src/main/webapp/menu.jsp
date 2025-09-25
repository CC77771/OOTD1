<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="BIG5">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>CZ Web</title>
  <!-- Template CSS -->
  <link rel="stylesheet" href="webapp/style.css">
  <meta name="keywords" content="CZ">
  <meta name="description" content="This is for example.">
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="format-detection" content="telephone=no">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="author" content="TemplatesJungle">
  <meta name="keywords" content="ecommerce,fashion,store">
  <meta name="description" content="Bootstrap 5 Fashion Store HTML CSS Template">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ" crossorigin="anonymous">
  <link rel="stylesheet" type="text/css" href="css/vendor.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.css" />
  <link rel="stylesheet" type="text/css" href="style.css">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link
    href="https://fonts.googleapis.com/css2?family=Jost:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Marcellus&display=swap"
    rel="stylesheet">
</head>
<body>
  <!-- Header -->
  <!-- Header -->
<form method="post" action="logout.jsp">
  <header class="w3l-header">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg bg-light text-uppercase fs-6 p-3 border-bottom align-items-center">
      <div class="container-fluid">
        <div class="row justify-content-between align-items-center w-100">
          <!-- Logo -->
          <div class="col-auto">
            <a class="navbar-brand text-white" href="index1.jsp">
              <img src="images/main-logo.png" width="220" height="40" alt="Main Logo">
            </a>
          </div>

          <!-- Navbar Toggler and Offcanvas -->
          <div class="col-auto">
            <button class="navbar-toggler" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasNavbar" aria-controls="offcanvasNavbar">
              <span class="navbar-toggler-icon"></span>
            </button>
            <div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel">
              <div class="offcanvas-header">
                <h5 class="offcanvas-title" id="offcanvasNavbarLabel">Menu</h5>
                <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
              </div>
              <div class="offcanvas-body">
                <ul class="navbar-nav justify-content-end flex-grow-1 gap-1 gap-md-5 pe-3">
                  <!-- Body Type Suggestions -->
                  <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle active" href="#" id="dropdownBodyTypeSuggestions" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">體型建議</a>
                    <ul class="dropdown-menu" aria-labelledby="dropdownBodyTypeSuggestions">
                      <li><a href="index1.jsp#Inverted_Triangle" class="dropdown-item">倒三角型</a></li>
                      <li><a href="index1.jsp#Rectangle" class="dropdown-item">矩型</a></li>
                      <li><a href="index1.jsp#Apple" class="dropdown-item">蘋果型</a></li>
                      <li><a href="index1.jsp#Pear" class="dropdown-item">梨型</a></li>
                      <li><a href="index1.jsp#Hourglass" class="dropdown-item">沙漏型</a></li>
                    </ul>
                  </li>                  

                  <!-- Wear Exhibition Area -->
                  <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="dropdownWearExhibitionArea" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">穿搭展示區</a>
                    <ul class="dropdown-menu" aria-labelledby="dropdownWearExhibitionArea">
                    <li><a href="Posts.jsp" class="dropdown-item">上傳貼文</a></li>
                      <li><a href="index1.jsp#Posts" class="dropdown-item">貼文</a></li>
                      <li><a href="index1.jsp#Same style" class="dropdown-item">同款服飾</a></li>
                    </ul>
                  </li>

                  <!-- Reward -->
                  <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="dropdownReward" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">穿搭分享獎勵</a>
                    <ul class="dropdown-menu" aria-labelledby="dropdownReward">
                      <li><a href="index1.jsp#Reward&Method" class="dropdown-item">活動方法</a></li>
                      <li><a href="index1.jsp#Reward&Method" class="dropdown-item">活動獎勵</a></li>
                    </ul>
                  </li>
                  
            <div class="ml-lg-3">
            <li class="nav-item dropdown"> 
             <a class="nav-link" href="member.jsp?memberId=<%=session.getAttribute("accessId")%>">
                           <%
					if(session.getAttribute("accessId") == null){
						out.println("");
					}else{
						out.println(session.getAttribute("accessId"));
					}
			 %></a>
                                                    
          <%if(session.getAttribute("accessId") != null){%>          
          	<input type="submit" value="登出" name="login" class="btn btn-style btn-effect">          	 
		  <%}else{%>
		  <a class="text-uppercase mx-3 align-items-center" href="login.jsp">登入</a>                
	  	  <%}%>    
           </li>
          </div>                 
              </div>
            </div>
          </div>

          <!-- Icons and Search -->          
          <div class="col-auto d-flex align-items-center">
            
            <a href="#search" class="search-button mx-2">
              <svg width="24" height="24" viewBox="0 0 24 24">
                <use xlink:href="#search"></use>   
              </svg>
            </a>
          </div>

        </div>
      </div>
    </nav>
  </header>
</form>
<script src="js/jquery.min.js"></script>
  <script src="js/plugins.js"></script>
  <script src="js/SmoothScroll.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"
    integrity="sha384-ENjdO4Dr2bkBIFxQpeoTz1HIcje39Wm4jDKdf19U8gI4ddQ3GYNS7NTKfAdVQSZe"
    crossorigin="anonymous"></script>
  <script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>
  <script src="js/script.min.js"></script>
</body>
</html>