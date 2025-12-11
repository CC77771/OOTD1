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
            
            if("delete".equals(action)) {
                sql = "DELETE FROM personal_wear WHERE postid = ?";
                message = "貼文已刪除";
            } else if("toggleState".equals(action)) {
                // 先查詢當前狀態
                sql = "SELECT post_state FROM personal_wear WHERE postid = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(postId));
                ResultSet rs = pstmt.executeQuery();
                
                if(rs.next()) {
                    boolean currentState = rs.getBoolean("post_state");
                    rs.close();
                    pstmt.close();
                    
                    // 切換狀態
                    sql = "UPDATE personal_wear SET post_state = ? WHERE postid = ?";
                    pstmt = con.prepareStatement(sql);
                    pstmt.setBoolean(1, !currentState);
                    pstmt.setInt(2, Integer.parseInt(postId));
                    
                    int result = pstmt.executeUpdate();
                    if(result > 0) {
                        success = true;
                        message = !currentState ? "貼文已啟用" : "貼文已停用";
                    }
                } else {
                    message = "找不到該貼文";
                }
            } else {
                message = "無效的操作";
            }
            
            if("delete".equals(action) && !sql.isEmpty()) {
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
    
    if(postId != null && wearId != null) {
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            con = getConnection(dbPath);
            String sql = "UPDATE personal_wear SET wearId = ? WHERE postid = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, wearId);
            pstmt.setInt(2, Integer.parseInt(postId));
            
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
    int activeCount = 0;
    int inactiveCount = 0;
    int totalPosts = 0;
    
    try {
        conn = getConnection(dbPath);
        String sql = "SELECT postid, memberid, wearId, view, post_state, post_date, pic FROM personal_wear ORDER BY postid DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        boolean first = true;
        while(rs.next()) {
            totalPosts++;
            boolean postState = rs.getBoolean("post_state");
            if(postState) activeCount++;
            else inactiveCount++;
            
            if(!first) postsJSON.append(",");
            
            String status = postState ? "active" : "inactive";
            
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
            
            postsJSON.append("views:").append(rs.getInt("view")).append(",");
            
            String postDate = "";
            if(rs.getTimestamp("post_date") != null) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                postDate = sdf.format(rs.getTimestamp("post_date"));
            }
            postsJSON.append("date:'").append(postDate).append("',");
            
            String pic = rs.getString("pic");
            if(pic != null && !pic.trim().isEmpty()) {
                postsJSON.append("pic:'").append(pic.replace("\\", "\\\\")).append("',");
            }
            
            postsJSON.append("status:'").append(status).append("'");
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
    
    // === 如果沒有資料，加入假資料 ===
    if(totalPosts == 0) {
        postsJSON = new StringBuilder("[");
        postsJSON.append("{id:1,author:'user001',title:'秋冬穿搭分享 - 簡約風格',views:1250,date:'2024-12-10 14:30',pic:'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=60&h=60&fit=crop',status:'active'},");
        postsJSON.append("{id:2,author:'fashionista',title:'聖誕派對穿搭推薦',views:890,date:'2024-12-09 10:15',pic:'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=60&h=60&fit=crop',status:'active'},");
        postsJSON.append("{id:3,author:'user002',title:'週末輕鬆穿搭',views:650,date:'2024-12-08 16:45',pic:'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=60&h=60&fit=crop',status:'inactive'},");
        postsJSON.append("{id:4,author:'stylequeen',title:'上班族OL穿搭日記',views:2100,date:'2024-12-07 09:20',pic:'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=60&h=60&fit=crop',status:'active'},");
        postsJSON.append("{id:5,author:'user003',title:'冬季大衣穿搭技巧',views:1580,date:'2024-12-06 13:50',pic:'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=60&h=60&fit=crop',status:'active'},");
        postsJSON.append("{id:6,author:'trendygirl',title:'復古風格穿搭',views:420,date:'2024-12-05 11:30',pic:'https://images.unsplash.com/photo-1445205170230-053b83016050?w=60&h=60&fit=crop',status:'inactive'},");
        postsJSON.append("{id:7,author:'user004',title:'運動休閒風穿搭',views:980,date:'2024-12-04 15:00',pic:'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=60&h=60&fit=crop',status:'active'},");
        postsJSON.append("{id:8,author:'fashionblogger',title:'約會穿搭靈感',views:1750,date:'2024-12-03 12:40',pic:'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=60&h=60&fit=crop',status:'active'},");
        postsJSON.append("{id:9,author:'user005',title:'學生族平價穿搭',views:560,date:'2024-12-02 10:10',pic:'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=60&h=60&fit=crop',status:'inactive'},");
        postsJSON.append("{id:10,author:'stylelover',title:'韓系穿搭分享',views:2350,date:'2024-12-01 14:25',pic:'https://images.unsplash.com/photo-1467632499275-7a693a761056?w=60&h=60&fit=crop',status:'active'}");
        postsJSON.append("]");
        
        totalPosts = 10;
        activeCount = 7;
        inactiveCount = 3;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>貼文管理 - CZ_OOTD</title>
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
    background: #ffffff;
    color: #333 !important;
    border: 1px solid #ddd;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transform: none;
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
            <a class="nav-link active" href="postManagement.jsp">📝 貼文審核</a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="userManagement.jsp">👥 使用者管理</a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="analytics.jsp">📊 點擊率分析</a>
        </li>
    </ul>

    <!-- 統計卡片 -->
    <div class="row mb-4">
        <div class="col-md-12">
            <div class="stats-card">
                <p>總貼文數</p>
                <h3 id="statTotal"><%= totalPosts %></h3>
            </div>
        </div>
    </div>

    <!-- 貼文列表 -->
    <div class="content-card">
        <div class="d-flex justify-content-between mb-3">
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
                        <th>作者</th>
                        <th>瀏覽數</th>
                        <th>發布時間</th>
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
    document.getElementById('statTotal').textContent = total;
}

// 渲染貼文表格
function renderPosts() {
    var tbody = document.getElementById('postTable');
    tbody.innerHTML = '';
    
    if(posts.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">沒有貼文資料</td></tr>';
        return;
    }
    
    posts.forEach(function(post) {
        var actionButtons = '<button class="btn btn-primary btn-action" onclick="editPost(' + post.id + ')">修改</button>' +
                          '<button class="btn btn-danger btn-action" onclick="deletePost(' + post.id + ')">刪除</button>';
        
        // 圖片欄位
        var imageCell = '';
        if(post.pic) {
            imageCell = '<img src="' + post.pic + '" alt="圖片" onclick="showImage(\'' + post.pic + '\')">';
        } else {
            imageCell = '<span class="text-muted">無圖片</span>';
        }
            
        var row = '<tr>' +
            '<td>' + String(post.id).padStart(3, '0') + '</td>' +
            '<td>' + imageCell + '</td>' +
            '<td>' + (post.title.length > 30 ? post.title.substring(0, 30) + '...' : post.title) + '</td>' +
            '<td>' + post.author + '</td>' +
            '<td><strong>' + post.views.toLocaleString() + '</strong></td>' +
            '<td>' + post.date + '</td>' +
            '<td>' + actionButtons + '</td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
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
        document.getElementById('editAuthor').value = post.author;
        
        var modal = new bootstrap.Modal(document.getElementById('editModal'));
        modal.show();
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