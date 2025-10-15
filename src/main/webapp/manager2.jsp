<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // === 模擬 Session 登入資料 ===
    String admin = "AdminUser";
    String role = "Administrator";

    // === 模擬查詢結果（假資料，可改成資料庫連線） ===
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
.nav-tabs {
    border-bottom: 2px solid #a89f91;
    margin-bottom: 30px;
}
.nav-tabs .nav-link {
    color: #666;
    border: none;
    padding: 12px 25px;
    font-weight: 500;
    transition: all 0.3s ease;
}
.nav-tabs .nav-link.active {
    color: #a89f91;
    background-color: white;
    border-bottom: 3px solid #a89f91;
}
.stats-card {
    background: white;
    padding: 25px;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    margin-bottom: 20px;
}
.stats-card h3 {
    font-size: 36px;
    font-weight: 700;
    color: #a89f91;
    margin: 10px 0;
}
table img {
    border-radius: 8px;
    width: 60px;
    height: 60px;
    object-fit: cover;
}
.btn-action {
    padding: 5px 10px;
    font-size: 14px;
    margin: 1px;
}
.search-box input {
    width: 300px;
    border: 2px solid #ddd;
    border-radius: 8px;
    padding: 6px 10px;
}
</style>
</head>

<body>
<div class="admin-container">
    <div class="admin-header">
        <h1>🛠️ 管理者控制台</h1>
        <p>歡迎回來，<%= admin %> | 管理 CZ_OOTD 平台內容與使用者</p>
    </div>

    <!-- 統計卡片 -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <p>待審核貼文</p>
                <h3><%= pendingCount %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>總使用者數</p>
                <h3><%= userCount %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>待處理回饋</p>
                <h3><%= feedbackCount %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>總貼文數</p>
                <h3><%= postCount %></h3>
            </div>
        </div>
    </div>

    <!-- 分頁導航 -->
    <ul class="nav nav-tabs" id="adminTab" role="tablist">
        <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#posts">📝 貼文審核</button></li>
        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#users">👥 使用者管理</button></li>
        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#feedback">💬 客服支援</button></li>
    </ul>

    <div class="tab-content" id="adminTabContent">

        <!-- 貼文審核 -->
        <div class="tab-pane fade show active" id="posts">
            <div class="search-box mb-3">
                <input type="text" id="postSearch" placeholder="搜尋貼文...">
            </div>
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>縮圖</th><th>標題</th><th>作者</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="postTable">
                    <tr><td>001</td><td><img src="https://picsum.photos/80/80?1"></td><td>秋季OOTD分享</td><td>user_01</td><td><span class="badge bg-warning">待審核</span></td><td>
                        <button class="btn btn-success btn-action" onclick="approvePost('001')">通過</button>
                        <button class="btn btn-danger btn-action" onclick="rejectPost('001')">拒絕</button>
                    </td></tr>
                    <tr><td>002</td><td><img src="https://picsum.photos/80/80?2"></td><td>街頭風穿搭</td><td>user_02</td><td><span class="badge bg-success">已通過</span></td><td>
                        <button class="btn btn-secondary btn-action" onclick="deletePost('002')">刪除</button>
                    </td></tr>
                </tbody>
            </table>
        </div>

        <!-- 使用者管理 -->
        <div class="tab-pane fade" id="users">
            <div class="search-box mb-3">
                <input type
