<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // === 模擬 Session 登入資料 ===
    String admin = "AdminUser";
    String role = "Administrator";

    // === 模擬查詢結果（不連資料庫） ===
    int pendingCount = 5;
    int userCount = 128;
    int feedbackCount = 3;
    int postCount = 240;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>CZ_OOTD 管理者頁面</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;700&display=swap" rel="stylesheet">

<style>
body {
    background-color: #f8f9fa;
    font-family: 'Jost', sans-serif;
}
.admin-container {
    max-width: 1400px;
    margin: 30px auto;
    padding: 0 20px;
}
.admin-header {
    background: linear-gradient(135deg, #a89f91 0%, #8f8c7f 100%);
    color: white;
    padding: 30px;
    border-radius: 15px;
    margin-bottom: 30px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.1);
}
.admin-header h1 {
    margin: 0;
    font-size: 32px;
    font-weight: 600;
}
.stats-card {
    background: white;
    padding: 25px;
    border-radius: 15px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    margin-bottom: 25px;
    transition: all 0.3s ease;
}
.stats-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 4px 15px rgba(0,0,0,0.15);
}
.stats-card h3 {
    font-size: 36px;
    font-weight: 700;
    color: #a89f91;
    margin: 10px 0;
}
.stats-card .btn {
    background-color: #a89f91;
    border: none;
    color: white;
    margin-top: 10px;
    transition: 0.3s;
}
.stats-card .btn:hover {
    background-color: #8f8c7f;
}
footer {
    text-align: center;
    padding: 20px;
    color: #777;
    font-size: 14px;
}
</style>
</head>

<body>
<div class="admin-container">
    <div class="admin-header">
        <h1>🛠️ 管理者控制台</h1>
        <p>歡迎回來，<%= admin %> | 管理 CZ_OOTD 平台內容與使用者</p>
    </div>

    <!-- 統計卡片區塊 -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <p>待審核貼文</p>
                <h3><%= pendingCount %></h3>
                <a href="review.jsp" class="btn btn-sm">前往審核 →</a>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>使用者管理</p>
                <h3><%= userCount %></h3>
                <a href="users.jsp" class="btn btn-sm">前往管理 →</a>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>客服支援</p>
                <h3><%= feedbackCount %></h3>
                <a href="support.jsp" class="btn btn-sm">查看訊息 →</a>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>貼文總覽</p>
                <h3><%= postCount %></h3>
                <a href="posts.jsp" class="btn btn-sm">檢視全部 →</a>
            </div>
        </div>
    </div>

    <!-- 下方導覽區 -->
    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-light border">
                <strong>📂 快速導覽：</strong>
                <a href="review.jsp" class="mx-2">貼文審核</a> |
                <a href="users.jsp" class="mx-2">使用者管理</a> |
                <a href="support.jsp" class="mx-2">客服中心</a> |
                <a href="posts.jsp" class="mx-2">貼文總覽</a> |
                <a href="logout.jsp" class="mx-2 text-danger">登出系統</a>
            </div>
        </div>
    </div>
</div>

<footer>
    <p>© 2025 CZ_OOTD Admin Panel | Designed by <%= admin %></p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
