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
.status-toggle {
    display: flex;
    gap: 5px;
    justify-content: center;
}
.status-toggle .btn {
    min-width: 45px;
    padding: 5px 12px;
    font-size: 14px;
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
                <p>待審核貼文</p>
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
                <p>待處理回饋</p>
                <h3 id="statFeedback"><%= feedbackCount %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card">
                <p>總貼文數</p>
                <h3 id="statPosts"><%= postCount %></h3>
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
            <div class="d-flex justify-content-between mb-3">
                <div class="search-box">
                    <input type="text" id="postSearch" placeholder="搜尋貼文...">
                </div>
                <button class="btn btn-primary" onclick="addNewPost()">➕ 新增測試貼文</button>
            </div>
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>縮圖</th><th>標題</th><th>作者</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="postTable"></tbody>
            </table>
        </div>

        <!-- 使用者管理 -->
        <div class="tab-pane fade" id="users">
            <div class="d-flex justify-content-between mb-3">
                <div class="search-box">
                    <input type="text" id="userSearch" placeholder="搜尋使用者...">
                </div>
                <button class="btn btn-primary" onclick="addNewUser()">➕ 新增使用者</button>
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
                <button class="btn btn-primary" onclick="addNewFeedback()">➕ 新增測試回饋</button>
            </div>
            <table class="table table-hover">
                <thead class="table-light">
                    <tr><th>編號</th><th>使用者</th><th>問題類型</th><th>內容</th><th>狀態</th><th>操作</th></tr>
                </thead>
                <tbody id="feedbackTable"></tbody>
            </table>
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
<script>
// 從 JSP 傳入的當前日期
var currentDate = '<%= currentDate %>';

// 資料儲存
var posts = [];
var users = [];
var feedbacks = [];

// 初始化資料
function initData() {
    // 可以透過 AJAX 從後端載入資料
    // 目前使用前端模擬資料
    posts = [
        {id: 1, image: 'https://picsum.photos/80/80?1', title: '秋季OOTD分享', author: 'user_01', status: 'pending'},
        {id: 2, image: 'https://picsum.photos/80/80?2', title: '街頭風穿搭', author: 'user_02', status: 'approved'},
        {id: 3, image: 'https://picsum.photos/80/80?3', title: '冬季大衣推薦', author: 'user_03', status: 'pending'},
        {id: 4, image: 'https://picsum.photos/80/80?4', title: '極簡風格穿搭', author: 'user_01', status: 'rejected'},
        {id: 5, image: 'https://picsum.photos/80/80?5', title: '約會穿搭分享', author: 'user_04', status: 'pending'}
    ];

    users = [
        {id: 1, username: 'user_01', email: 'user01@example.com', joinDate: '2024-01-15', suspended: false},
        {id: 2, username: 'user_02', email: 'user02@example.com', joinDate: '2024-02-20', suspended: false},
        {id: 3, username: 'user_03', email: 'user03@example.com', joinDate: '2024-03-10', suspended: false},
        {id: 4, username: 'user_04', email: 'user04@example.com', joinDate: '2024-04-05', suspended: true}
    ];

    feedbacks = [
        {id: 1, user: 'user_03', type: '技術問題', content: '無法上傳圖片', status: 'pending', reply: ''},
        {id: 2, user: 'user_04', type: '帳號問題', content: '忘記密碼', status: 'completed', reply: '已透過郵件發送重設連結'},
        {id: 3, user: 'user_01', type: '功能建議', content: '希望新增服飾標籤功能', status: 'pending', reply: ''}
    ];

    renderAll();
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
    var pendingPosts = posts.filter(function(p) { return p.status === 'pending'; }).length;
    var pendingFeedbacks = feedbacks.filter(function(f) { return f.status === 'pending'; }).length;
    
    document.getElementById('statPending').textContent = pendingPosts;
    document.getElementById('statUsers').textContent = users.length;
    document.getElementById('statFeedback').textContent = pendingFeedbacks;
    document.getElementById('statPosts').textContent = posts.length;
}

// 渲染所有表格
function renderAll() {
    renderPosts();
    renderUsers();
    renderFeedbacks();
    updateStats();
}

// 渲染貼文表格
function renderPosts() {
    var tbody = document.getElementById('postTable');
    tbody.innerHTML = '';
    
    posts.forEach(function(post) {
        var statusBadge = post.status === 'pending' ? 
            '<span class="badge bg-warning">待審核</span>' :
            post.status === 'approved' ? 
            '<span class="badge bg-success">已通過</span>' :
            '<span class="badge bg-danger">已拒絕</span>';
            
        var row = '<tr>' +
            '<td>' + String(post.id).padStart(3, '0') + '</td>' +
            '<td><img src="' + post.image + '" alt="post"></td>' +
            '<td>' + post.title + '</td>' +
            '<td>' + post.author + '</td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' +
            (post.status === 'pending' ? 
                '<button class="btn btn-success btn-action" onclick="approvePost(' + post.id + ')">通過</button>' +
                '<button class="btn btn-danger btn-action" onclick="rejectPost(' + post.id + ')">拒絕</button>' : '') +
            '<button class="btn btn-secondary btn-action" onclick="deletePost(' + post.id + ')">刪除</button>' +
            '</td></tr>';
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
            '<button class="btn btn-warning btn-action" onclick="editUser(' + user.id + ')">編輯</button>' +
            '<button class="btn ' + (user.suspended ? 'btn-success' : 'btn-danger') + ' btn-action" onclick="toggleSuspendUser(' + user.id + ')">' +
            (user.suspended ? '解除停權' : '停權') + '</button>' +
            '</td></tr>';
        tbody.innerHTML += row;
    });
}

// 渲染回饋表格
function renderFeedbacks() {
    var tbody = document.getElementById('feedbackTable');
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

// === 貼文功能 ===
function approvePost(postId) {
    var post = posts.find(function(p) { return p.id === postId; });
    if (post) {
        post.status = 'approved';
        renderAll();
        showToast('貼文「' + post.title + '」已通過審核', 'success');
        
        // TODO: 可在此處加入 AJAX 呼叫後端 API 更新資料庫
        // $.ajax({ url: 'approvePost.jsp', data: {id: postId}, method: 'POST' });
    }
}

function rejectPost(postId) {
    if (confirm('確定要拒絕此貼文嗎？')) {
        var post = posts.find(function(p) { return p.id === postId; });
        if (post) {
            post.status = 'rejected';
            renderAll();
            showToast('貼文「' + post.title + '」已被拒絕', 'danger');
        }
    }
}

function deletePost(postId) {
    if (confirm('確定要刪除此貼文嗎？此操作無法復原！')) {
        var index = posts.findIndex(function(p) { return p.id === postId; });
        if (index !== -1) {
            var title = posts[index].title;
            posts.splice(index, 1);
            renderAll();
            showToast('貼文「' + title + '」已刪除', 'info');
        }
    }
}

function addNewPost() {
    var newId = Math.max.apply(Math, posts.map(function(p) { return p.id; })) + 1;
    var randomNum = Math.floor(Math.random() * 1000);
    posts.push({
        id: newId,
        image: 'https://picsum.photos/80/80?' + randomNum,
        title: '測試貼文 ' + newId,
        author: 'user_' + String(newId).padStart(2, '0'),
        status: 'pending'
    });
    renderAll();
    showToast('新貼文已新增', 'success');
}

// === 使用者功能 ===
function editUser(userId) {
    var user = users.find(function(u) { return u.id === userId; });
    if (user) {
        document.getElementById('editUserId').value = user.id;
        document.getElementById('editUsername').value = user.username;
        document.getElementById('editEmail').value = user.email;
        
        var modal = new bootstrap.Modal(document.getElementById('editUserModal'));
        modal.show();
    }
}

function saveUserEdit() {
    var userId = parseInt(document.getElementById('editUserId').value);
    var user = users.find(function(u) { return u.id === userId; });
    
    if (user) {
        user.username = document.getElementById('editUsername').value;
        user.email = document.getElementById('editEmail').value;
        
        renderAll();
        bootstrap.Modal.getInstance(document.getElementById('editUserModal')).hide();
        showToast('使用者「' + user.username + '」資料已更新', 'success');
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

function addNewUser() {
    var newId = Math.max.apply(Math, users.map(function(u) { return u.id; })) + 1;
    users.push({
        id: newId,
        username: 'user_' + String(newId).padStart(2, '0'),
        email: 'user' + String(newId).padStart(2, '0') + '@example.com',
        joinDate: currentDate,
        suspended: false
    });
    renderAll();
    showToast('新使用者已新增', 'success');
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

function addNewFeedback() {
    var newId = Math.max.apply(Math, feedbacks.map(function(f) { return f.id; })) + 1;
    var types = ['技術問題', '帳號問題', '功能建議', '其他'];
    feedbacks.push({
        id: newId,
        user: 'user_' + String(newId).padStart(2, '0'),
        type: types[Math.floor(Math.random() * types.length)],
        content: '測試回饋內容 ' + newId,
        status: 'pending',
        reply: ''
    });
    renderAll();
    showToast('新回饋已新增', 'success');
}

// === 搜尋功能 ===
document.getElementById('postSearch').addEventListener('input', function(e) {
    var searchText = e.target.value.toLowerCase();
    var rows = document.querySelectorAll('#postTable tr');
    rows.forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchText) ? '' : 'none';
    });
});

document.getElementById('userSearch').addEventListener('input', function(e) {
    var searchText = e.target.value.toLowerCase();
    var rows = document.querySelectorAll('#userTable tr');
    rows.forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchText) ? '' : 'none';
    });
});

document.getElementById('feedbackSearch').addEventListener('input', function(e) {
    var searchText = e.target.value.toLowerCase();
    var rows = document.querySelectorAll('#feedbackTable tr');
    rows.forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchText) ? '' : 'none';
    });
});

// 初始化
initData();
</script>

</body>
</html>