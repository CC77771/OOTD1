<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>

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
        <div class="col-md-3">
            <div class="stats-card">
                <p>總評論數</p>
                <h3 id="statPosts"><%= postCount %></h3>
            </div>
        </div>
    </div>

    <!-- 分頁導航 -->
    <ul class="nav nav-tabs" id="adminTab" role="tablist">
        <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#comments">💬 評論審核</button></li>
        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#users">👥 使用者管理</button></li>
        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#analytics">📊 點擊率分析</button></li>
    </ul>

    <div class="tab-content" id="adminTabContent">

        <!-- 評論審核 -->
        <div class="tab-pane fade show active" id="comments">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>評論者</th><th>貼文標題</th><th>評論內容</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="commentTable"></tbody>
            </table>
        </div>

        <!-- 使用者管理 -->
        <div class="tab-pane fade" id="users">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>使用者名稱</th><th>電子郵件</th><th>註冊日期</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="userTable"></tbody>
            </table>
        </div>

        <!-- 點擊率分析 -->
        <div class="tab-pane fade" id="analytics">
            <div class="row">
                <div class="col-md-6">
                    <div class="analytics-card">
                        <h5>📈 每日點擊趨勢</h5>
                        <div class="chart-container">
                            <canvas id="dailyClickChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="analytics-card">
                        <h5>🏷️ 熱門標籤分析</h5>
                        <div class="chart-container">
                            <canvas id="tagsChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="analytics-card">
                        <h5>📊 點擊率數據總覽</h5>
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>貼文ID</th>
                                    <th>標題</th>
                                    <th>發布者</th>
                                    <th>總點擊</th>
                                    <th>今日點擊</th>
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

<!-- Toast 容器 -->
<div class="toast-container"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
<script>
// 從 JSP 傳入的當前日期
var currentDate = '<%= currentDate %>';

// 資料儲存
var comments = [];
var users = [];
var analyticsData = [];

// 圖表實例
var dailyClickChart = null;
var tagsChart = null;

// 初始化資料 - 狀態預設為 approved (已通過)
function initData() {
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

    // 點擊率分析模擬數據
    analyticsData = [
        {id: 1, title: '秋季OOTD分享', author: 'user_01', totalClicks: 2580, todayClicks: 156},
        {id: 2, title: '街頭風穿搭', author: 'user_02', totalClicks: 1920, todayClicks: 98},
        {id: 3, title: '冬季大衣推薦', author: 'user_03', totalClicks: 3150, todayClicks: 203},
        {id: 4, title: '極簡風格穿搭', author: 'user_01', totalClicks: 1650, todayClicks: 87},
        {id: 5, title: '約會穿搭分享', author: 'user_04', totalClicks: 2340, todayClicks: 142},
        {id: 6, title: '韓系穿搭教學', author: 'user_02', totalClicks: 2890, todayClicks: 178},
        {id: 7, title: '復古風搭配', author: 'user_03', totalClicks: 1480, todayClicks: 76},
        {id: 8, title: '運動休閒風', author: 'user_01', totalClicks: 2120, todayClicks: 125},
        {id: 9, title: '職場穿搭分享', author: 'user_04', totalClicks: 1850, todayClicks: 95},
        {id: 10, title: '夏日清新風格', author: 'user_02', totalClicks: 3420, todayClicks: 215}
    ];

    renderAll();
    initCharts();
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
    
    document.getElementById('statPending').textContent = pendingComments;
    document.getElementById('statUsers').textContent = users.length;
    document.getElementById('statPosts').textContent = comments.length;
}

// 渲染所有表格
function renderAll() {
    renderComments();
    renderUsers();
    renderAnalytics();
    updateStats();
}

// 渲染評論表格 - 根據狀態顯示對應按鈕
function renderComments() {
    var tbody = document.getElementById('commentTable');
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
    var tbody = document.getElementById('userTable');
    tbody.innerHTML = '';
    
    users.forEach(function(user) {
        var statusBadge = user.suspended ? 
            '<span class="badge bg-danger">已停權</span>' : 
            '<span class="badge bg-success">正常</span>';
            
        var row = '<tr>' +
            '<td>' + String(user.id).padStart(3, '0') + '</td>' +
            '<td>' + user.username + '</td>' +
            '<td>' + user.email + '</td>' +
            '<td>' + user.joinDate + '</td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' +
            '<button class="btn btn-warning btn-action" onclick="warnUser(' + user.id + ')">警告</button>' +
            '<button class="btn ' + (user.suspended ? 'btn-success' : 'btn-danger') + ' btn-action" onclick="toggleSuspendUser(' + user.id + ')">' +
            (user.suspended ? '解除停權' : '停權') + '</button>' +
            '</td></tr>';
        tbody.innerHTML += row;
    });
}

// 渲染點擊率分析
function renderAnalytics() {
    // 渲染數據表格
    var tbody = document.getElementById('analyticsTable');
    tbody.innerHTML = '';
    
    analyticsData.forEach(function(data) {
        var row = '<tr>' +
            '<td>' + String(data.id).padStart(3, '0') + '</td>' +
            '<td>' + data.title + '</td>' +
            '<td>' + data.author + '</td>' +
            '<td><strong>' + data.totalClicks.toLocaleString() + '</strong></td>' +
            '<td><span class="badge bg-info">' + data.todayClicks + '</span></td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
}

// 初始化圖表
function initCharts() {
    // 每日點擊趨勢圖
    var ctx1 = document.getElementById('dailyClickChart');
    if (ctx1) {
        var last7Days = [];
        var clickData = [];
        
        for (var i = 6; i >= 0; i--) {
            var date = new Date();
            date.setDate(date.getDate() - i);
            last7Days.push((date.getMonth() + 1) + '/' + date.getDate());
            clickData.push(Math.floor(Math.random() * 500) + 800);
        }
        
        dailyClickChart = new Chart(ctx1, {
            type: 'line',
            data: {
                labels: last7Days,
                datasets: [{
                    label: '每日點擊數',
                    data: clickData,
                    borderColor: '#a89f91',
                    backgroundColor: 'rgba(168, 159, 145, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

    // 熱門標籤圖表
    var ctx2 = document.getElementById('tagsChart');
    if (ctx2) {
        tagsChart = new Chart(ctx2, {
            type: 'doughnut',
            data: {
                labels: ['#OOTD', '#街頭風', '#韓系', '#極簡', '#復古', '#休閒'],
                datasets: [{
                    data: [450, 320, 280, 240, 180, 150],
                    backgroundColor: [
                        '#a89f91',
                        '#8f8c7f',
                        '#c4b5a0',
                        '#9d8f7f',
                        '#b5a99a',
                        '#d4c8b8'
                    ],
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            padding: 15,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                var label = context.label || '';
                                var value = context.parsed || 0;
                                return label + ': ' + value + ' 次使用';
                            }
                        }
                    }
                }
            }
        });
    }
}

// === 評論功能 - 通過、拒絕、刪除 ===
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
function warnUser(userId) {
    var user = users.find(function(u) { return u.id === userId; });
    if (user) {
        var reason = prompt('請輸入警告原因：', '違反社群規範');
        if (reason && reason.trim()) {
            showToast('已對使用者「' + user.username + '」發送警告：' + reason, 'warning');
        }
    }
}

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

// 初始化
initData();
</script>

</body>
</html>