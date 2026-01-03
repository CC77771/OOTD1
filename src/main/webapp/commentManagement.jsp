<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*, java.text.*, java.sql.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />

<%!
    // 資料庫連線方法
    public Connection getConnection(String dbPath) throws Exception {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        return DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
    }
%>

<%
    String dbPath = objDBConfig.FilePath();
    
//============ 處理 AJAX 請求 ============
String ajaxAction = request.getParameter("ajax");
if("true".equals(ajaxAction)) {
    // 清除輸出緩衝區
    out.clearBuffer();
    
    String commentId = request.getParameter("commentId");
    String action = request.getParameter("action");
    
    String message = "";
    boolean success = false;
    
    if(commentId != null && action != null && !commentId.trim().isEmpty()) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = getConnection(dbPath);
            String sql = "";
            
            if("approve".equals(action)) {
                sql = "UPDATE personal_wear SET post_state = True WHERE postid = ?";
                message = "評論已通過";
            } else if("reject".equals(action)) {
                sql = "UPDATE personal_wear SET post_state = False WHERE postid = ?";
                message = "評論已拒絕";
            } else if("delete".equals(action)) {
                sql = "DELETE FROM personal_wear WHERE postid = ?";
                message = "評論已刪除";
            } else {
                message = "無效的操作";
            }
            
            if(!sql.isEmpty()) {
                pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(commentId));
                
                int result = pstmt.executeUpdate();
                
                if(result > 0) {
                    success = true;
                } else {
                    message = "找不到該評論";
                }
            }
            
        } catch(NumberFormatException e) {
            message = "評論ID格式錯誤";
            e.printStackTrace();
        } catch(Exception e) {
            message = "系統錯誤: " + e.getMessage();
            e.printStackTrace();
        } finally {
            try {
                if(pstmt != null) pstmt.close();
                if(con != null) con.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        message = "參數錯誤";
    }
    
    // 回傳 JSON
    response.setContentType("application/json; charset=utf-8");
    out.print("{\"success\":" + success + ",\"message\":\"" + message + "\"}");
    out.flush();
    return; // 重要：結束處理，不繼續執行下面的 HTML
}

// 正常顯示時才引入 menu
%>
<%@include file="menu.jsp" %>
<%
    
    // ============ 讀取評論資料 ============
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    StringBuilder commentsJSON = new StringBuilder("[");
    int pendingCount = 0;
    int totalComments = 0;
    
    try {
        conn = getConnection(dbPath);
        String sql = "SELECT postid, memberid, message, post_state, pic FROM personal_wear ORDER BY postid DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        boolean first = true;
        while(rs.next()) {
            String message = rs.getString("message");
            
            // 如果評論內容為空或只有空白，跳過此筆資料
            if(message == null || message.trim().isEmpty()) {
                continue;
            }
            
            totalComments++;
            boolean postState = rs.getBoolean("post_state");
            if(!postState) pendingCount++;
            
            if(!first) commentsJSON.append(",");
            
            String status = postState ? "approved" : "rejected";
            
            commentsJSON.append("{");
            commentsJSON.append("id:").append(rs.getInt("postid")).append(",");
            commentsJSON.append("commenter:'").append(rs.getString("memberid") != null ? rs.getString("memberid") : "匿名").append("',");
            commentsJSON.append("postTitle:'穿搭分享',");
            
            // 處理評論內容
            message = message.replace("'", "\\'").replace("\n", "\\n").replace("\r", "").replace("\"", "\\\"");
            commentsJSON.append("content:'").append(message).append("',");
            
            String pic = rs.getString("pic");
            if(pic != null && !pic.trim().isEmpty()) {
                commentsJSON.append("pic:'").append(pic.replace("\\", "\\\\")).append("',");
            }
            
            commentsJSON.append("status:'").append(status).append("'");
            commentsJSON.append("}");
            
            first = false;
        }
    } catch(Exception e) {
        out.println("<!-- 資料庫錯誤: " + e.getMessage() + " -->");
        e.printStackTrace();
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    commentsJSON.append("]");
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String currentDate = sdf.format(new java.util.Date());
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>評論審核管理 - CZ_OOTD</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;700&display=swap" rel="stylesheet">

<style>
/* Tabs 容器 - 置中 & 下移 & 緊湊 */
#adminTab {
    display: flex !important;          
    justify-content: center !important; 
    flex-wrap: wrap;                   
    gap: 30px;                         
    margin: 50px auto 20px auto;       
}

/* Tab 按鈕美化 - 卡片風格 */
.nav-tabs .nav-link {
    font-size: 35px;          
    padding: 15px 30px;       
    font-weight: 600;
    color: #333;
    border-radius: 15px;
    text-align: center;
    background: #ffffff;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    border: 1px solid #ddd;
    transition: all 0.3s ease;
    text-decoration: none;
}

/* Hover 效果 */
.nav-tabs .nav-link:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    background: #f9f9f9;
}

/* Active 卡片 - 藍色背景 */
.nav-tabs .nav-link.active {
    background: #0d6efd !important;
    color: #ffffff !important;
    border: 1px solid #0d6efd;
    box-shadow: 0 6px 15px rgba(13,110,253,0.3);
    transform: translateY(-3px);
}

/* 移除底線 */
.nav-tabs {
    border-bottom: none !important;
}

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
.back-btn {
    background: white;
    color: #a89f91;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-weight: 500;
    transition: all 0.3s;
    text-decoration: none;
    display: inline-block;
}
.back-btn:hover {
    background: #f0f0f0;
    transform: translateY(-2px);
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
.content-card {
    background: white;
    padding: 25px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
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
    padding: 8px 15px;
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
.filter-buttons {
    margin-bottom: 20px;
}
.filter-buttons .btn {
    margin-right: 10px;
}
.modal-content {
    border-radius: 15px;
}
.modal-header {
    background: linear-gradient(135deg, #a89f91 0%, #8f8c7f 100%);
    color: white;
    border-radius: 15px 15px 0 0;
}
.image-preview {
    max-width: 100%;
    max-height: 400px;
    border-radius: 10px;
}
</style>
</head>

<body>
<div class="admin-container">
  <div class="admin-header">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1>🛠️ 管理者控制台</h1>
                <p>歡迎回來 | 管理 CZ_OOTD 平台內容與使用者</p>
            </div>
            <a href="manager3.jsp" class="back-btn">← 返回控制台</a>
        </div>
    </div>
    <!-- 分頁導航 -->
    <ul class="nav nav-tabs" id="adminTab" role="tablist">
        <li class="nav-item">
            <a class="nav-link active">💬 評論審核</a>
        </li>
        
        <li class="nav-item">
            <a class="nav-link" href="postManagement.jsp">📝 貼文審核</a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="userManagement.jsp">👥 一般會員管理</a>
        </li>
        
    </ul>

    <!-- 統計卡片 -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="stats-card">
                <p>總評論數</p>
                <h3 id="statTotal"><%= totalComments %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stats-card">
                <p>待審核評論</p>
                <h3 id="statPending" style="color: #dc3545;"><%= pendingCount %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stats-card">
                <p>已通過評論</p>
                <h3 id="statApproved" style="color: #28a745;"><%= totalComments - pendingCount %></h3>
            </div>
        </div>
    </div>

    <!-- 評論列表 -->
    <div class="content-card">
        <div class="d-flex justify-content-between mb-3">
            <div class="filter-buttons">
                <button class="btn btn-outline-secondary active" onclick="filterComments('all')">全部</button>
                <button class="btn btn-outline-warning" onclick="filterComments('pending')">待審核</button>
                <button class="btn btn-outline-success" onclick="filterComments('approved')">已通過</button>
                <button class="btn btn-outline-danger" onclick="filterComments('rejected')">已拒絕</button>
            </div>
            <div class="search-box">
                <input type="text" id="commentSearch" placeholder="🔍 搜尋評論內容或使用者...">
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>編號</th>
                        <th>圖片</th>
                        <th>評論者</th>
                        <th>評論內容</th>
                        <th>狀態</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="commentTable"></tbody>
            </table>
        </div>
    </div>
</div>

<!-- 查看圖片 Modal -->
<div class="modal fade" id="imageModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">圖片預覽</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <img id="modalImage" src="" class="image-preview" alt="圖片預覽">
            </div>
        </div>
    </div>
</div>

<!-- Toast 容器 -->
<div class="toast-container"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// 從 JSP 載入評論資料
var comments = <%= commentsJSON.toString() %>;
var currentFilter = 'all';

// 初始化
function init() {
    renderComments();
    updateStats();
}

// 顯示 Toast 訊息
function showToast(message, type) {
    type = type || 'success';
    var toastContainer = document.querySelector('.toast-container');
    var toastId = 'toast-' + Date.now();
    
    var bgColor = type === 'success' ? 'bg-success' : type === 'danger' ? 'bg-danger' : 'bg-warning';
    
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
    var total = comments.length;
    var pending = comments.filter(function(c) { return c.status === 'rejected'; }).length;
    var approved = comments.filter(function(c) { return c.status === 'approved'; }).length;
    
    document.getElementById('statTotal').textContent = total;
    document.getElementById('statPending').textContent = pending;
    document.getElementById('statApproved').textContent = approved;
}

// 渲染評論表格
function renderComments() {
    var tbody = document.getElementById('commentTable');
    tbody.innerHTML = '';
    
    var filteredComments = comments;
    if(currentFilter !== 'all') {
        filteredComments = comments.filter(function(c) { 
            if(currentFilter === 'pending') return c.status === 'rejected';
            return c.status === currentFilter; 
        });
    }
    
    if(filteredComments.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted">沒有符合條件的評論</td></tr>';
        return;
    }
    
    filteredComments.forEach(function(comment) {
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
        
        // 圖片欄位
        var imageCell = '';
        if(comment.pic) {
            imageCell = '<img src="' + comment.pic + '" alt="圖片" onclick="showImage(\'' + comment.pic + '\')">';
        } else {
            imageCell = '<span class="text-muted">無圖片</span>';
        }
            
        var row = '<tr>' +
            '<td>' + String(comment.id).padStart(3, '0') + '</td>' +
            '<td>' + imageCell + '</td>' +
            '<td>' + comment.commenter + '</td>' +          
            '<td>' + (comment.content.length > 50 ? comment.content.substring(0, 50) + '...' : comment.content) + '</td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' + actionButtons + '</td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
}

// 篩選評論
function filterComments(filter) {
    currentFilter = filter;
    
    // 更新按鈕狀態
    document.querySelectorAll('.filter-buttons .btn').forEach(function(btn) {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    renderComments();
}

// 搜尋功能
document.getElementById('commentSearch').addEventListener('input', function(e) {
    var searchText = e.target.value.toLowerCase();
    var rows = document.querySelectorAll('#commentTable tr');
    rows.forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchText) ? '' : 'none';
    });
});

// 顯示圖片
function showImage(imageSrc) {
    document.getElementById('modalImage').src = imageSrc;
    var modal = new bootstrap.Modal(document.getElementById('imageModal'));
    modal.show();
}

// 通過評論
function approveComment(commentId) {
    if(confirm('確定要通過此評論嗎？')) {
        updateCommentStatus(commentId, 'approve');
    }
}

// 拒絕評論
function rejectComment(commentId) {
    if (confirm('確定要拒絕此評論嗎？')) {
        updateCommentStatus(commentId, 'reject');
    }
}

// 刪除評論
function deleteComment(commentId) {
    if (confirm('確定要刪除此評論嗎？此操作無法復原！')) {
        updateCommentStatus(commentId, 'delete');
    }
}

// 更新評論狀態
function updateCommentStatus(commentId, action) {
    // 顯示載入中
    showToast('處理中...', 'info');
    
    // 發送 AJAX 請求
    fetch('commentManagement.jsp?ajax=true&commentId=' + commentId + '&action=' + action)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                showToast(data.message, 'success');
                // 重新載入頁面
                setTimeout(function() {
                    location.reload();
                }, 1000);
            } else {
                showToast(data.message, 'danger');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showToast('操作失敗：' + error, 'danger');
        });
}

// 頁面載入完成後執行
window.onload = function() {
    init();
    
    // 檢查是否有操作結果訊息
    const urlParams = new URLSearchParams(window.location.search);
    const message = urlParams.get('message');
    const success = urlParams.get('success');
    
    if(message) {
        showToast(decodeURIComponent(message), success === 'true' ? 'success' : 'danger');
    }
};
</script>

</body>
</html>