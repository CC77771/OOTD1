<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@include file ="menu.jsp" %>

<%
    // === 模擬 Session 登入資料 ===
    String admin = "AdminUser";
    String role = "Administrator";

    // === 模擬查詢結果(假資料,可改成資料庫連線) ===
    // 這些數據會由前端 JavaScript 動態更新
    int pendingCount = 5;
    int userCount = 128;
    int feedbackCount = 3;
    int postCount = 240;
    
    // 取得當前日期
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String currentDate = sdf.format(new Date());
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
    transition: transform 0.2s;
}
.stats-card:hover {
    transform: translateY(-5px);
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
    cursor: pointer;
    transition: transform 0.2s;
}
table img:hover {
    transform: scale(1.1);
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
.modal-content {
    border-radius: 15px;
}
.modal-header {
    background: linear-gradient(135deg, #a89f91 0%, #8f8c7f 100%);
    color: white;
    border-radius: 15px 15px 0 0;
}
.toast-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 9999;
}
.custom-toast {
    min-width: 300px;
    border-radius: 10px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}
.analytics-card {
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
    margin-bottom: 20px;
}
.analytics-card h5 {
    color: #a89f91;
    font-weight: 600;
    margin-bottom: 15px;
}
.chart-container {
    position: relative;
    height: 300px;
}
.rank-item {
    display: flex;
    align-items: center;
    padding: 10px;
    border-bottom: 1px solid #eee;
}
.rank-number {
    font-size: 24px;
    font-weight: 700;
    color: #a89f91;
    width: 40px;
}
.rank-info {
    flex: 1;
    margin-left: 15px;
}
.rank-bar {
    height: 8px;
    background: #e9ecef;
    border-radius: 10px;
    margin-top: 5px;
    overflow: hidden;
}
.rank-bar-fill {
    height: 100%;
    background: linear-gradient(135deg, #a89f91 0%, #8f8c7f 100%);
    transition: width 0.3s ease;
}
</style>
</head>

<body>
<div class="admin-container">
    <div class="admin-header">
        <h1>🛠️ 管理者控制台</h1>
        <p>歡迎回來,<%= admin %> | 管理 CZ_OOTD 平台內容與使用者</p>
    </div>

    <!-- 統計卡片 -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stats-card">
                <p>待審核評論</p>
                <h3 id="statPending"><%= pendingCount %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>總使用者數</p>
                <h3 id="statUsers"><%= userCount %></h3>
            </div>
        </div>
        <!--<div class="col-md-3">
            <div class="stats-card">
                <p>待處理回饋</p>
                <h3 id="statFeedback"><%= feedbackCount %></h3>
            </div>
        </div>-->
        <div class="col-md-3">
            <div class="stats-card">
                <p>總評論數</p>
                <h3 id="statPosts"><%= postCount %></h3>
            </div>
        </div>
    </div>

    <!-- 分頁導航 -->
    <ul class="nav nav-tabs" id="adminTab" role="tablist">
    <li class="nav-item">
       <a class="nav-link" href="commentManagement.jsp">💬 評論審核</a>
    </li>
    <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#users">👥 使用者管理</button></li>
    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#analytics">📊 點擊率分析</button></li>
</ul>

  <div class="tab-content" id="adminTabContent">

        <!-- 評論審核
        <div class="tab-pane fade show active" id="comments">
            <div class="d-flex justify-content-between mb-3">
                <div class="search-box">
                    <input type="text" id="commentSearch" placeholder="搜尋評論...">
                </div>
            </div>
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>評論者</th><th>貼文標題</th><th>評論內容</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="commentTable"></tbody>
            </table>
        </div>-->

        <!-- 使用者管理 -->
       <div class="tab-pane fade show active" id="users">
            <div class="d-flex justify-content-between mb-3">
                <div class="search-box">
                    <input type="text" id="userSearch" placeholder="搜尋使用者...">
                </div>
            </div>
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>使用者名稱</th><th>電子郵件</th><th>註冊日期</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="userTable"></tbody>
            </table>
        </div>

        <!-- 客服支援 -->
        <div class="tab-pane fade" id="feedback">
            <div class="d-flex justify-content-between mb-3">
                <div class="search-box">
                    <input type="text" id="feedbackSearch" placeholder="搜尋回饋...">
                </div>
            </div>
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>使用者</th><th>問題類型</th><th>內容</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="feedbackTable"></tbody>
            </table>
        </div>

<!-- 點擊率分析 -->
<div class="tab-pane fade" id="analytics">
    <!-- 第一行：兩個排行榜並排 -->
    <div class="row">
        <div class="col-md-6">
            <div class="analytics-card">
                <h5>🏆 熱門貼文排行 TOP 10</h5>
                <div id="topPostsRanking"></div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="analytics-card">
                <h5>👤 活躍用戶排行 TOP 10</h5>
                <div id="topUsersRanking"></div>
            </div>
        </div>
    </div>
    
    <!-- 第二行：點擊率數據總覽獨立展開 -->
    <div class="row">
        <div class="col-md-12">
            <div class="analytics-card">
                <h5>📊 點擊率數據總覽</h5>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>貼文ID</th>
                                <th>標題</th>
                                <th>發布者</th>
                                <th>總點擊</th>
                                <th>今日點擊</th>
                                <th>平均停留時間</th>
                                <th>互動率</th>
                            </tr>
                        </thead>
                        <tbody id="analyticsTable"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<!-- 編輯使用者 Modal -->
<div class="modal fade" id="editUserModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">編輯使用者</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="editUserId">
                <div class="mb-3">
                    <label class="form-label">使用者名稱</label>
                    <input type="text" class="form-control" id="editUsername">
                </div>
                <div class="mb-3">
                    <label class="form-label">電子郵件</label>
                    <input type="email" class="form-control" id="editEmail">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" onclick="saveUserEdit()">儲存變更</button>
            </div>
        </div>
    </div>
</div>

<!-- 回覆回饋 Modal -->
<div class="modal fade" id="replyFeedbackModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">回覆客服回饋</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="replyFeedbackId">
                <div class="mb-3">
                    <label class="form-label">原始問題</label>
                    <p id="originalFeedback" class="form-control-plaintext bg-light p-2 rounded"></p>
                </div>
                <div class="mb-3">
                    <label class="form-label">回覆內容</label>
                    <textarea class="form-control" id="replyContent" rows="4" placeholder="輸入回覆內容..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" onclick="sendReply()">送出回覆</button>
            </div>
        </div>
    </div>
</div>

<!-- 查看回饋 Modal -->
<div class="modal fade" id="viewFeedbackModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">回饋詳情</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label"><strong>使用者</strong></label>
                    <p id="viewUser" class="form-control-plaintext"></p>
                </div>
                <div class="mb-3">
                    <label class="form-label"><strong>問題類型</strong></label>
                    <p id="viewType" class="form-control-plaintext"></p>
                </div>
                <div class="mb-3">
                    <label class="form-label"><strong>問題內容</strong></label>
                    <p id="viewContent" class="form-control-plaintext bg-light p-3 rounded"></p>
                </div>
                <div class="mb-3">
                    <label class="form-label"><strong>回覆內容</strong></label>
                    <p id="viewReply" class="form-control-plaintext bg-success bg-opacity-10 p-3 rounded"></p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">關閉</button>
            </div>
        </div>
    </div>
</div>

<!-- Toast 容器 -->
<div class="toast-container"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
<script>
// 從 JSP 傳入的當前日期
var currentDate = '<%= currentDate %>'; // 請改回你的 JSP 變數: '<%= currentDate %>'

// 資料儲存
var comments = [];
var users = [];
var feedbacks = [];
var analyticsData = [];

// 圖表實例
var dailyClickChart = null;
var tagsChart = null;

// 初始化資料
function initData() {
    console.log('開始初始化資料...');
    
    comments = [
        {id: 1, commenter: 'user_01', postTitle: '秋季OOTD分享', content: '超級好看！想知道外套哪裡買的', status: 'approved'},
        {id: 2, commenter: 'user_02', postTitle: '街頭風穿搭', content: '配色很棒，學起來了', status: 'approved'},
        {id: 3, commenter: 'user_03', postTitle: '冬季大衣推薦', content: '這件大衣質感真的很好', status: 'approved'},
        {id: 4, commenter: 'user_01', postTitle: '極簡風格穿搭', content: '簡約又有質感', status: 'approved'},
        {id: 5, commenter: 'user_04', postTitle: '約會穿搭分享', content: '太美了！可以請問鞋子品牌嗎', status: 'approved'}
    ];

    users = [
        {id: 1, username: 'user_01', email: 'user01@example.com', joinDate: '2024-01-15', suspended: false},
        {id: 2, username: 'user_02', email: 'user02@example.com', joinDate: '2024-02-20', suspended: false},
        {id: 3, username: 'user_03', email: 'user03@example.com', joinDate: '2024-03-10', suspended: false},
        {id: 4, username: 'user_04', email: 'user04@example.com', joinDate: '2024-04-05', suspended: true}
    ];
    console.log('使用者資料:', users);

    feedbacks = [
        {id: 1, user: 'user_03', type: '技術問題', content: '無法上傳圖片', status: 'pending', reply: ''},
        {id: 2, user: 'user_04', type: '帳號問題', content: '忘記密碼', status: 'completed', reply: '已透過郵件發送重設連結'},
        {id: 3, user: 'user_01', type: '功能建議', content: '希望新增服飾標籤功能', status: 'pending', reply: ''}
    ];

    // 點擊率分析模擬數據
    analyticsData = [
        {id: 1, title: '秋季OOTD分享', author: 'user_01', totalClicks: 2580, todayClicks: 156, avgTime: '2:45', engagement: '8.5%'},
        {id: 2, title: '街頭風穿搭', author: 'user_02', totalClicks: 1920, todayClicks: 98, avgTime: '2:12', engagement: '6.8%'},
        {id: 3, title: '冬季大衣推薦', author: 'user_03', totalClicks: 3150, todayClicks: 203, avgTime: '3:20', engagement: '9.2%'},
        {id: 4, title: '極簡風格穿搭', author: 'user_01', totalClicks: 1650, todayClicks: 87, avgTime: '1:55', engagement: '5.4%'},
        {id: 5, title: '約會穿搭分享', author: 'user_04', totalClicks: 2340, todayClicks: 142, avgTime: '2:30', engagement: '7.6%'},
        {id: 6, title: '韓系穿搭教學', author: 'user_02', totalClicks: 2890, todayClicks: 178, avgTime: '2:58', engagement: '8.9%'},
        {id: 7, title: '復古風搭配', author: 'user_03', totalClicks: 1480, todayClicks: 76, avgTime: '1:48', engagement: '5.1%'},
        {id: 8, title: '運動休閒風', author: 'user_01', totalClicks: 2120, todayClicks: 125, avgTime: '2:22', engagement: '7.2%'},
        {id: 9, title: '職場穿搭分享', author: 'user_04', totalClicks: 1850, todayClicks: 95, avgTime: '2:05', engagement: '6.3%'},
        {id: 10, title: '夏日清新風格', author: 'user_02', totalClicks: 3420, todayClicks: 215, avgTime: '3:35', engagement: '9.8%'}
    ];
    console.log('點擊率資料:', analyticsData);

    renderAll();
    initCharts();
    console.log('初始化完成！');
}

// 顯示提示訊息
function showToast(message, type) {
    type = type || 'success';
    var toastContainer = document.querySelector('.toast-container');
    var toastId = 'toast-' + Date.now();
    
    var bgColor = type === 'success' ? 'bg-success' : type === 'danger' ? 'bg-danger' : 'bg-info';
    
    var toastHTML = '<div id="' + toastId + '" class="toast custom-toast align-items-center text-white ' + bgColor + ' border-0" role="alert">' +
        '<div class="d-flex">' +
        '<div class="toast-body">' + message + '</div>' +
        '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>' +
        '</div></div>';
    
    toastContainer.insertAdjacentHTML('beforeend', toastHTML);
    var toastElement = document.getElementById(toastId);
    var toast = new bootstrap.Toast(toastElement, {delay: 3000});
    toast.show();
    
    toastElement.addEventListener('hidden.bs.toast', function() {
        toastElement.remove();
    });
}

// 更新統計數據
function updateStats() {
    var pendingComments = comments.filter(function(c) { return c.status === 'pending'; }).length;
    var pendingFeedbacks = feedbacks.filter(function(f) { return f.status === 'pending'; }).length;
    
    document.getElementById('statPending').textContent = pendingComments;
    document.getElementById('statUsers').textContent = users.length;
    document.getElementById('statPosts').textContent = comments.length;
}

// 渲染所有表格
function renderAll() {
    console.log('開始渲染所有表格...');
    renderComments();
    renderUsers();
    renderFeedbacks();
    renderAnalytics();
    updateStats();
}

// 渲染評論表格
function renderComments() {
    var tbody = document.getElementById('commentTable');
    if (!tbody) {
        console.log('找不到 commentTable 元素');
        return;
    }
    tbody.innerHTML = '';
    
    comments.forEach(function(comment) {
        var statusBadge = '';
        var actionButtons = '';
        
        if (comment.status === 'approved') {
            statusBadge = '<span class="badge bg-success">已通過</span>';
            actionButtons = '<button class="btn btn-danger btn-action" onclick="rejectComment(' + comment.id + ')">拒絕</button>' +
                          '<button class="btn btn-secondary btn-action" onclick="deleteComment(' + comment.id + ')">刪除</button>';
        } else if (comment.status === 'rejected') {
            statusBadge = '<span class="badge bg-danger">已拒絕</span>';
            actionButtons = '<button class="btn btn-success btn-action" onclick="approveComment(' + comment.id + ')">通過</button>' +
                          '<button class="btn btn-secondary btn-action" onclick="deleteComment(' + comment.id + ')">刪除</button>';
        } else {
            statusBadge = '<span class="badge bg-warning">待審核</span>';
            actionButtons = '<button class="btn btn-success btn-action" onclick="approveComment(' + comment.id + ')">通過</button>' +
                          '<button class="btn btn-danger btn-action" onclick="rejectComment(' + comment.id + ')">拒絕</button>' +
                          '<button class="btn btn-secondary btn-action" onclick="deleteComment(' + comment.id + ')">刪除</button>';
        }
            
        var row = '<tr>' +
            '<td>' + String(comment.id).padStart(3, '0') + '</td>' +
            '<td>' + comment.commenter + '</td>' +
            '<td>' + comment.postTitle + '</td>' +
            '<td>' + (comment.content.length > 30 ? comment.content.substring(0, 30) + '...' : comment.content) + '</td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' + actionButtons + '</td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
}

// 渲染使用者表格
function renderUsers() {
    console.log('開始渲染使用者表格...');
    var tbody = document.getElementById('userTable');
    if (!tbody) {
        console.error('找不到 userTable 元素！');
        return;
    }
    console.log('找到 userTable，準備渲染 ' + users.length + ' 個使用者');
    tbody.innerHTML = '';
    
    users.forEach(function(user) {
        var statusBadge = user.suspended ? 
            '<span class="badge bg-danger">已停權</span>' : 
            '<span class="badge bg-success">正常</span>';
            
        var actionBtn = user.suspended ? 
            '<button class="btn btn-success btn-action" onclick="toggleSuspendUser(' + user.id + ')">解除停權</button>' :
            '<button class="btn btn-danger btn-action" onclick="toggleSuspendUser(' + user.id + ')">停權</button>';
            
        var row = '<tr>' +
            '<td>' + String(user.id).padStart(3, '0') + '</td>' +
            '<td>' + user.username + '</td>' +
            '<td>' + user.email + '</td>' +
            '<td>' + user.joinDate + '</td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' + actionBtn + '</td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
    console.log('使用者表格渲染完成！');
}

// 渲染回饋表格
function renderFeedbacks() {
    var tbody = document.getElementById('feedbackTable');
    if (!tbody) {
        console.log('找不到 feedbackTable 元素');
        return;
    }
    tbody.innerHTML = '';
    
    feedbacks.forEach(function(fb) {
        var statusBadge = fb.status === 'pending' ? 
            '<span class="badge bg-warning">待處理</span>' : 
            '<span class="badge bg-success">已處理</span>';
            
        var row = '<tr>' +
            '<td>' + String(fb.id).padStart(3, '0') + '</td>' +
            '<td>' + fb.user + '</td>' +
            '<td>' + fb.type + '</td>' +
            '<td>' + fb.content + '</td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' +
            (fb.status === 'pending' ? 
                '<button class="btn btn-primary btn-action" onclick="replyFeedback(' + fb.id + ')">回覆</button>' +
                '<button class="btn btn-success btn-action" onclick="completeFeedback(' + fb.id + ')">完成</button>' :
                '<button class="btn btn-secondary btn-action" onclick="viewFeedback(' + fb.id + ')">查看</button>') +
            '</td></tr>';
        tbody.innerHTML += row;
    });
}

// 渲染點擊率分析
function renderAnalytics() {
    console.log('開始渲染點擊率分析...');
    
    // 渲染數據表格
    var tbody = document.getElementById('analyticsTable');
    if (!tbody) {
        console.error('找不到 analyticsTable 元素！');
        return;
    }
    console.log('找到 analyticsTable，準備渲染 ' + analyticsData.length + ' 筆資料');
    tbody.innerHTML = '';
    
    analyticsData.forEach(function(data) {
        var row = '<tr>' +
            '<td>' + String(data.id).padStart(3, '0') + '</td>' +
            '<td>' + data.title + '</td>' +
            '<td>' + data.author + '</td>' +
            '<td><strong>' + data.totalClicks.toLocaleString() + '</strong></td>' +
            '<td><span class="badge bg-info">' + data.todayClicks + '</span></td>' +
            '<td>' + data.avgTime + '</td>' +
            '<td><span class="badge bg-success">' + data.engagement + '</span></td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
    console.log('數據表格渲染完成！');

    // 渲染熱門貼文排行
    var topPostsDiv = document.getElementById('topPostsRanking');
    if (!topPostsDiv) {
        console.error('找不到 topPostsRanking 元素！');
        return;
    }
    
    var topPosts = analyticsData.slice().sort(function(a, b) { return b.totalClicks - a.totalClicks; }).slice(0, 10);
    var maxClicks = topPosts[0].totalClicks;
    var topPostsHTML = '';
    
    topPosts.forEach(function(post, index) {
        var percentage = (post.totalClicks / maxClicks * 100).toFixed(1);
        topPostsHTML += '<div class="rank-item">' +
            '<div class="rank-number">' + (index + 1) + '</div>' +
            '<div class="rank-info">' +
            '<div><strong>' + post.title + '</strong></div>' +
            '<div class="rank-bar"><div class="rank-bar-fill" style="width: ' + percentage + '%"></div></div>' +
            '<small class="text-muted">' + post.totalClicks.toLocaleString() + ' 次點擊</small>' +
            '</div></div>';
    });
    topPostsDiv.innerHTML = topPostsHTML;
    console.log('熱門貼文排行渲染完成！');

    // 渲染活躍用戶排行
    var topUsersDiv = document.getElementById('topUsersRanking');
    if (!topUsersDiv) {
        console.error('找不到 topUsersRanking 元素！');
        return;
    }
    
    var userClicks = {};
    analyticsData.forEach(function(data) {
        if (!userClicks[data.author]) {
            userClicks[data.author] = 0;
        }
        userClicks[data.author] += data.totalClicks;
    });
    
    var topUsers = Object.keys(userClicks).map(function(username) {
        return {username: username, clicks: userClicks[username]};
    }).sort(function(a, b) { return b.clicks - a.clicks; }).slice(0, 10);
    
    var maxUserClicks = topUsers[0].clicks;
    var topUsersHTML = '';
    
    topUsers.forEach(function(user, index) {
        var percentage = (user.clicks / maxUserClicks * 100).toFixed(1);
        topUsersHTML += '<div class="rank-item">' +
            '<div class="rank-number">' + (index + 1) + '</div>' +
            '<div class="rank-info">' +
            '<div><strong>' + user.username + '</strong></div>' +
            '<div class="rank-bar"><div class="rank-bar-fill" style="width: ' + percentage + '%"></div></div>' +
            '<small class="text-muted">' + user.clicks.toLocaleString() + ' 總點擊</small>' +
            '</div></div>';
    });
    topUsersDiv.innerHTML = topUsersHTML;
    console.log('活躍用戶排行渲染完成！');
}

// 初始化圖表
function initCharts() {
    console.log('初始化圖表...');
    // 圖表程式碼保持不變（如果需要可以之後加上）
}

// === 評論功能 ===
function approveComment(commentId) {
    var comment = comments.find(function(c) { return c.id === commentId; });
    if (comment) {
        comment.status = 'approved';
        renderAll();
        showToast('評論已通過', 'success');
    }
}

function rejectComment(commentId) {
    if (confirm('確定要拒絕此評論嗎？')) {
        var comment = comments.find(function(c) { return c.id === commentId; });
        if (comment) {
            comment.status = 'rejected';
            renderAll();
            showToast('評論已被拒絕', 'danger');
        }
    }
}

function deleteComment(commentId) {
    if (confirm('確定要刪除此評論嗎？此操作無法復原！')) {
        var index = comments.findIndex(function(c) { return c.id === commentId; });
        if (index !== -1) {
            comments.splice(index, 1);
            renderAll();
            showToast('評論已刪除', 'info');
        }
    }
}

// === 使用者功能 ===
function toggleSuspendUser(userId) {
    var user = users.find(function(u) { return u.id === userId; });
    if (user) {
        var action = user.suspended ? '解除停權' : '停權';
        if (confirm('確定要' + action + '使用者「' + user.username + '」嗎？')) {
            user.suspended = !user.suspended;
            renderAll();
            showToast('使用者「' + user.username + '」已' + action, user.suspended ? 'danger' : 'success');
        }
    }
}

// === 回饋功能 ===
function replyFeedback(feedbackId) {
    var fb = feedbacks.find(function(f) { return f.id === feedbackId; });
    if (fb) {
        document.getElementById('replyFeedbackId').value = fb.id;
        document.getElementById('originalFeedback').textContent = fb.content;
        document.getElementById('replyContent').value = '';
        
        var modal = new bootstrap.Modal(document.getElementById('replyFeedbackModal'));
        modal.show();
    }
}

function sendReply() {
    var feedbackId = parseInt(document.getElementById('replyFeedbackId').value);
    var replyContent = document.getElementById('replyContent').value;
    
    if (!replyContent.trim()) {
        showToast('請輸入回覆內容', 'danger');
        return;
    }
    
    var fb = feedbacks.find(function(f) { return f.id === feedbackId; });
    if (fb) {
        fb.reply = replyContent;
        fb.status = 'completed';
        
        renderAll();
        bootstrap.Modal.getInstance(document.getElementById('replyFeedbackModal')).hide();
        showToast('回覆已送出', 'success');
    }
}

function completeFeedback(feedbackId) {
    if (confirm('確定將此回饋標記為已完成嗎？')) {
        var fb = feedbacks.find(function(f) { return f.id === feedbackId; });
        if (fb) {
            fb.status = 'completed';
            if (!fb.reply) {
                fb.reply = '已處理完成';
            }
            renderAll();
            showToast('回饋已標記為完成', 'success');
        }
    }
}

function viewFeedback(feedbackId) {
    var fb = feedbacks.find(function(f) { return f.id === feedbackId; });
    if (fb) {
        document.getElementById('viewUser').textContent = fb.user;
        document.getElementById('viewType').textContent = fb.type;
        document.getElementById('viewContent').textContent = fb.content;
        document.getElementById('viewReply').textContent = fb.reply || '無回覆內容';
        
        var modal = new bootstrap.Modal(document.getElementById('viewFeedbackModal'));
        modal.show();
    }
}

// === 搜尋功能 ===
var userSearchInput = document.getElementById('userSearch');
if (userSearchInput) {
    userSearchInput.addEventListener('input', function(e) {
        var searchText = e.target.value.toLowerCase();
        var rows = document.querySelectorAll('#userTable tr');
        rows.forEach(function(row) {
            var text = row.textContent.toLowerCase();
            row.style.display = text.includes(searchText) ? '' : 'none';
        });
    });
}

var feedbackSearchInput = document.getElementById('feedbackSearch');
if (feedbackSearchInput) {
    feedbackSearchInput.addEventListener('input', function(e) {
        var searchText = e.target.value.toLowerCase();
        var rows = document.querySelectorAll('#feedbackTable tr');
        rows.forEach(function(row) {
            var text = row.textContent.toLowerCase();
            row.style.display = text.includes(searchText) ? '' : 'none';
        });
    });
}

// 頁面載入時初始化
console.log('準備初始化...');
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initData);
} else {
    initData();
}ata();
</script>

</body>
</html>