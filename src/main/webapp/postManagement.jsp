<%@ page language="java" pageEncoding="utf-8"%>
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
    
    String postId = request.getParameter("postId");
    String action = request.getParameter("action");
    
    String message = "";
    boolean success = false;
    
    if(postId != null && action != null && !postId.trim().isEmpty()) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = getConnection(dbPath);
            String sql = "";
            
            if("approve".equals(action)) {
                sql = "UPDATE personal_wear SET post_state = True WHERE postid = ?";
                message = "貼文已通過";
            } else if("reject".equals(action)) {
                sql = "UPDATE personal_wear SET post_state = False WHERE postid = ?";
                message = "貼文已拒絕";
            } else if("delete".equals(action)) {
                sql = "DELETE FROM personal_wear WHERE postid = ?";
                message = "貼文已刪除";
            } else {
                message = "無效的操作";
            }
            
            if(!sql.isEmpty()) {
                pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(postId));
                
                int result = pstmt.executeUpdate();
                
                if(result > 0) {
                    success = true;
                } else {
                    message = "找不到該貼文";
                }
            }
            
        } catch(NumberFormatException e) {
            message = "貼文ID格式錯誤";
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
    return;
}

//============ 處理修改貼文 ============
if("update".equals(request.getParameter("action"))) {
    String postId = request.getParameter("postId");
    String wearId = request.getParameter("wearId");
    String tags = request.getParameter("tags");
    
    if(postId != null && wearId != null) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = getConnection(dbPath);
            String sql = "UPDATE personal_wear SET wearId = ?, tags = ? WHERE postid = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, wearId);
            pstmt.setString(2, tags);
            pstmt.setInt(3, Integer.parseInt(postId));
            
            int result = pstmt.executeUpdate();
            
            if(result > 0) {
                response.sendRedirect("postManagement.jsp?message=" + java.net.URLEncoder.encode("貼文已更新", "UTF-8") + "&success=true");
                return;
            }
            
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if(con != null) try { con.close(); } catch(Exception e) {}
        }
    }
}

// 正常顯示時才引入 menu
%>
<%@include file="menu.jsp" %>
<%
    
    // ============ 讀取貼文資料 ============
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    StringBuilder postsJSON = new StringBuilder("[");
    int totalPosts = 0;
    int pendingPosts = 0;
    int approvedPosts = 0;
    
    try {
        conn = getConnection(dbPath);
        
        // 使用 GROUP BY 確保每個貼文只出現一次
        String sql = "SELECT p.postid, " +
                     "       MAX(p.memberid) as memberid, " +
                     "       MAX(p.wearId) as wearId, " +
                     "       MAX(p.view) as view, " +
                     "       MAX(p.post_state) as post_state, " +
                     "       MAX(p.pic) as pic, " +
                     "       MAX(p.tags) as tags, " +
                     "       MAX(p.[like]) as likeCount, " +
                     "       SUM(CASE WHEN p.message IS NOT NULL AND p.message <> '' THEN 1 ELSE 0 END) as commentCount " +
                     "FROM personal_wear p " +
                     "GROUP BY p.postid " +
                     "ORDER BY p.postid DESC";
        
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        boolean first = true;
        while(rs.next()) {
            totalPosts++;
            boolean postState = rs.getBoolean("post_state");
            if(postState) {
                approvedPosts++;
            } else {
                pendingPosts++;
            }
            
            if(!first) postsJSON.append(",");
            
            String status = postState ? "approved" : "rejected";
            
            postsJSON.append("{");
            postsJSON.append("id:").append(rs.getInt("postid")).append(",");
            postsJSON.append("author:'").append(rs.getString("memberid") != null ? rs.getString("memberid") : "匿名").append("',");
            
            String wearId = rs.getString("wearId");
            if(wearId != null) {
                wearId = wearId.replace("'", "\\'").replace("\n", "\\n").replace("\r", "").replace("\"", "\\\"");
            } else {
                wearId = "無標題";
            }
            postsJSON.append("title:'").append(wearId).append("',");
            
            String tags = rs.getString("tags");
            if(tags != null) {
                tags = tags.replace("'", "\\'").replace("\n", "\\n").replace("\r", "").replace("\"", "\\\"");
            } else {
                tags = "";
            }
            postsJSON.append("tags:'").append(tags).append("',");
            
            postsJSON.append("views:").append(rs.getInt("view")).append(",");
            postsJSON.append("likes:").append(rs.getInt("likeCount")).append(",");
            postsJSON.append("comments:").append(rs.getInt("commentCount")).append(",");
            postsJSON.append("status:'").append(status).append("',");
            
            String pic = rs.getString("pic");
            if(pic != null && !pic.trim().isEmpty()) {
                postsJSON.append("pic:'").append(pic.replace("\\", "\\\\").replace("'", "\\'")).append("'");
            } else {
                postsJSON.append("pic:''");
            }
            
            postsJSON.append("}");
            
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
    
    postsJSON.append("]");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>貼文審核 - CZ_OOTD</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;700&display=swap" rel="stylesheet">

<style>
body {
    background-color: #f8f9fa;
    font-family: 'Jost', sans-serif;
}

/* Tabs 容器 */
#adminTab {
    display: flex !important;          
    justify-content: center !important; 
    flex-wrap: wrap;                   
    gap: 30px;                         
    margin: 50px auto 20px auto;       
}

/* Tab 按鈕 */
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

.nav-tabs .nav-link:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.15);
    background: #f9f9f9;
}

.nav-tabs .nav-link.active {
    background: #0d6efd !important;
    color: #ffffff !important;
    border: 1px solid #0d6efd;
    box-shadow: 0 6px 15px rgba(13,110,253,0.3);
    transform: translateY(-3px);
}

.nav-tabs {
    border-bottom: none !important;
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
    color: #a89f91;
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
    margin: 2px;
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
            <a class="nav-link" href="commentManagement.jsp">💬 評論審核</a>
        </li>
        
        <li class="nav-item">
            <a class="nav-link active">📝 貼文審核</a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="userManagement.jsp">👥 一般會員管理</a>
        </li>
               
    </ul>

    <!-- 統計卡片 -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="stats-card">
                <p>總貼文數</p>
                <h3 id="statTotal"><%= totalPosts %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stats-card">
                <p>待審核貼文</p>
                <h3 id="statPending" style="color: #dc3545;"><%= pendingPosts %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stats-card">
                <p>已通過貼文</p>
                <h3 id="statApproved" style="color: #28a745;"><%= approvedPosts %></h3>
            </div>
        </div>
    </div>

<!-- 貼文列表 -->
    <div class="content-card">
        <div class="d-flex justify-content-end mb-3">
            <div class="search-box">
                <input type="text" id="postSearch" placeholder="🔍 搜尋貼文標題或作者...">
            </div>
        </div>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>編號</th>
                        <th>圖片</th>
                        <th>標題</th>
                        <th>標籤</th>
                        <th>作者</th>
                        <th>瀏覽數</th>
                        <th>按讚數</th>
                        <th>留言數</th>
                        <th>狀態</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody id="postTable"></tbody>
            </table>
        </div>
    </div>
</div>

<!-- 修改貼文 Modal -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">✏️ 修改貼文</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="postManagement.jsp">
                <div class="modal-body">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="postId" id="editPostId">
                    
                    <div class="mb-3">
                        <label class="form-label">貼文編號</label>
                        <input type="text" class="form-control" id="editPostIdDisplay" readonly>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">標題</label>
                        <input type="text" class="form-control" name="wearId" id="editTitle" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">標籤 (以逗號分隔)</label>
                        <input type="text" class="form-control" name="tags" id="editTags" placeholder="例: 休閒,簡約,秋冬">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">作者</label>
                        <input type="text" class="form-control" id="editAuthor" readonly>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                    <button type="submit" class="btn btn-primary">儲存變更</button>
                </div>
            </form>
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
// 從 JSP 載入貼文資料
var posts = <%= postsJSON.toString() %>;
var currentFilter = 'all';

// 初始化
function init() {
    renderPosts();
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
    var total = posts.length;
    var pending = posts.filter(function(p) { return p.status === 'rejected'; }).length;
    var approved = posts.filter(function(p) { return p.status === 'approved'; }).length;
    
    document.getElementById('statTotal').textContent = total;
    document.getElementById('statPending').textContent = pending;
    document.getElementById('statApproved').textContent = approved;
}

// 渲染貼文表格
function renderPosts() {
    var tbody = document.getElementById('postTable');
    tbody.innerHTML = '';
    
    var filteredPosts = posts;
    if(currentFilter !== 'all') {
        filteredPosts = posts.filter(function(p) { 
            if(currentFilter === 'pending') return p.status === 'rejected';
            return p.status === currentFilter; 
        });
    }
    
    if(filteredPosts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10" class="text-center text-muted">沒有符合條件的貼文</td></tr>';
        return;
    }
    
    filteredPosts.forEach(function(post) {
        var statusBadge = '';
        var actionButtons = '';
        
        if (post.status === 'approved') {
            statusBadge = '<span class="badge bg-success">已通過</span>';
            actionButtons = '<button class="btn btn-primary btn-action" onclick="editPost(' + post.id + ')">修改</button>' +
                          '<button class="btn btn-danger btn-action" onclick="rejectPost(' + post.id + ')">拒絕</button>' +
                          '<button class="btn btn-secondary btn-action" onclick="deletePost(' + post.id + ')">刪除</button>';
        } else if (post.status === 'rejected') {
            statusBadge = '<span class="badge bg-danger">已拒絕</span>';
            actionButtons = '<button class="btn btn-success btn-action" onclick="approvePost(' + post.id + ')">通過</button>' +
                          '<button class="btn btn-secondary btn-action" onclick="deletePost(' + post.id + ')">刪除</button>';
        } else {
            statusBadge = '<span class="badge bg-warning">待審核</span>';
            actionButtons = '<button class="btn btn-success btn-action" onclick="approvePost(' + post.id + ')">通過</button>' +
                          '<button class="btn btn-danger btn-action" onclick="rejectPost(' + post.id + ')">拒絕</button>' +
                          '<button class="btn btn-secondary btn-action" onclick="deletePost(' + post.id + ')">刪除</button>';
        }
        
        // 圖片欄位
        var imageCell = '';
        if(post.pic) {
            imageCell = '<img src="' + post.pic + '" alt="圖片" onclick="showImage(\'' + post.pic + '\')">';
        } else {
            imageCell = '<span class="text-muted">無圖片</span>';
        }
        
        // 標籤欄位
        var tagsCell = '';
        if(post.tags && post.tags.trim() !== '') {
            var tagArray = post.tags.split(',');
            tagsCell = tagArray.map(function(tag) {
                return '<span class="badge bg-secondary me-1">' + tag.trim() + '</span>';
            }).join('');
        } else {
            tagsCell = '<span class="text-muted">無標籤</span>';
        }
            
        var row = '<tr>' +
            '<td>' + String(post.id).padStart(3, '0') + '</td>' +
            '<td>' + imageCell + '</td>' +
            '<td>' + (post.title.length > 20 ? post.title.substring(0, 20) + '...' : post.title) + '</td>' +
            '<td>' + tagsCell + '</td>' +
            '<td>' + post.author + '</td>' +
            '<td><strong>' + post.views.toLocaleString() + '</strong></td>' +
            '<td><span class="badge bg-danger">' + post.likes + '</span></td>' +
            '<td><span class="badge bg-primary">' + post.comments + '</span></td>' +
            '<td>' + statusBadge + '</td>' +
            '<td>' + actionButtons + '</td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
}

// 篩選貼文
function filterPosts(filter) {
    currentFilter = filter;
    
    // 更新按鈕狀態
    document.querySelectorAll('.filter-buttons .btn').forEach(function(btn) {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    renderPosts();
}

// 搜尋功能
document.getElementById('postSearch').addEventListener('input', function(e) {
    var searchText = e.target.value.toLowerCase();
    var rows = document.querySelectorAll('#postTable tr');
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

// 修改貼文
function editPost(postId) {
    var post = posts.find(function(p) { return p.id === postId; });
    if(post) {
        document.getElementById('editPostId').value = post.id;
        document.getElementById('editPostIdDisplay').value = String(post.id).padStart(3, '0');
        document.getElementById('editTitle').value = post.title;
        document.getElementById('editTags').value = post.tags || '';
        document.getElementById('editAuthor').value = post.author;
        
        var modal = new bootstrap.Modal(document.getElementById('editModal'));
        modal.show();
    }
}

// 通過貼文
function approvePost(postId) {
    if(confirm('確定要通過此貼文嗎？')) {
        updatePostStatus(postId, 'approve');
    }
}

// 拒絕貼文
function rejectPost(postId) {
    if (confirm('確定要拒絕此貼文嗎？拒絕後該貼文將不會顯示在前台！')) {
        updatePostStatus(postId, 'reject');
    }
}

// 刪除貼文
function deletePost(postId) {
    if (confirm('確定要刪除此貼文嗎？此操作無法復原！')) {
        updatePostStatus(postId, 'delete');
    }
}

// 更新貼文狀態
function updatePostStatus(postId, action) {
    showToast('處理中...', 'info');
    
    fetch('postManagement.jsp?ajax=true&postId=' + postId + '&action=' + action)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                showToast(data.message, 'success');
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