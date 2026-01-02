<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*, java.text.*, java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.DriverManager" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />

<%!
    // 資料庫連線方法
    public Connection getConnection(String dbPath) throws Exception {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        return DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
    }
%>

<%
    // === 模擬 Session 登入資料 ===
    String admin = "AdminUser";
    String role = "Administrator";

    // 取得當前日期
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String currentDate = sdf.format(new Date());
    
    // === 資料庫連線 - 直接指定路徑 ===
    // 如果 DBConfig 的 FilePath() 沒有正確回傳,可以直接指定
    String dbPath = "C:/Users/user/Documents/OOTD1/src/main/webapp/OOTD1.accdb";
    
    // 或者使用 DBConfig (如果它有正確設定)
    // String dbPath = objDBConfig.FilePath();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // 儲存資料的 ArrayList
    ArrayList<Map<String, Object>> analyticsDataList = new ArrayList<>();
    
    try {
        conn = getConnection(dbPath);
        
        // 查詢語句 - 從 personal_wear 資料表取得貼文資料
        // 注意:Access 資料庫的 GROUP BY 語法可能需要調整
        String sql = "SELECT postid, memberid, wearId, view " +
                     "FROM personal_wear " +
                     "WHERE post_state = True " +
                     "ORDER BY view DESC";
        
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        // 用來統計每個貼文的留言數
        Map<Integer, Integer> commentCountMap = new HashMap<>();
        
        while(rs.next()) {
            int postId = rs.getInt("postid");
            
            // 如果這個 postid 還沒處理過
            if(!commentCountMap.containsKey(postId)) {
                Map<String, Object> data = new HashMap<>();
                
                data.put("id", postId);
                data.put("title", rs.getString("wearId") != null ? rs.getString("wearId") : "未命名");
                data.put("author", rs.getString("memberid") != null ? rs.getString("memberid") : "未知");
                data.put("totalClicks", rs.getInt("view"));
                
                // 計算留言數 - 需要額外查詢
                int commentCount = 0;
                try {
                    PreparedStatement pstmt2 = conn.prepareStatement(
                        "SELECT COUNT(*) as cnt FROM personal_wear " +
                        "WHERE postid = ? AND message IS NOT NULL AND message <> ''"
                    );
                    pstmt2.setInt(1, postId);
                    ResultSet rs2 = pstmt2.executeQuery();
                    if(rs2.next()) {
                        commentCount = rs2.getInt("cnt");
                    }
                    rs2.close();
                    pstmt2.close();
                } catch(Exception e2) {
                    // 如果留言查詢失敗,設為 0
                    commentCount = 0;
                }
                
                data.put("totalComments", commentCount);
                
                analyticsDataList.add(data);
                commentCountMap.put(postId, 1);
            }
        }
        
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>資料庫錯誤: " + e.getMessage() + "</div>");
        out.println("<div class='alert alert-warning'>資料庫路徑: " + dbPath + "</div>");
        e.printStackTrace();
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<%@include file ="menu.jsp" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>CZ_OOTD 管理者頁面 - 點擊率分析</title>
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

/* 移除 Active 卡片的特殊樣式,讓它跟其他的一樣 */
.nav-tabs .nav-link.active {
    background: #0d6efd;
    color: white !important;
    border: 1px solid #0d6efd;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
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

    <!-- 分頁導航 -->
    <ul class="nav nav-tabs" id="adminTab" role="tablist">
        <li class="nav-item">
            <a class="nav-link" href="commentManagement.jsp">💬 評論審核</a>
        </li>
        
        <li class="nav-item">
            <a class="nav-link" href="postManagement.jsp">📝 貼文管理</a>
        </li>

        <li class="nav-item">
            <a class="nav-link" href="userManagement.jsp">👥 一般會員管理</a>
        </li>
        
        <li class="nav-item">
            <a class="nav-link active">📊 點擊率分析</a>
        </li>
    </ul>

    <!-- 點擊率分析內容 -->
    <div class="analytics-content">
        <!-- 第一行:熱門貼文排行 -->
        <div class="row">
            <div class="col-md-12">
                <div class="analytics-card">
                    <h5>🏆 熱門貼文排行 TOP 10</h5>
                    <div id="topPostsRanking"></div>
                </div>
            </div>
        </div>
        
        <!-- 第二行:點擊率數據總覽獨立展開 -->
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
                                    <th>總留言數</th>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// 從資料庫獲取的真實數據
var analyticsData = [
    <%
    for(int i = 0; i < analyticsDataList.size(); i++) {
        Map<String, Object> data = analyticsDataList.get(i);
        String title = data.get("title") != null ? data.get("title").toString().replace("'", "\\'").replace("\n", " ").replace("\r", " ") : "未命名";
        String author = data.get("author") != null ? data.get("author").toString().replace("'", "\\'") : "未知";
    %>
    {
        id: <%= data.get("id") %>,
        title: '<%= title %>',
        author: '<%= author %>',
        totalClicks: <%= data.get("totalClicks") %>,
        totalComments: <%= data.get("totalComments") %>
    }<%= (i < analyticsDataList.size() - 1) ? "," : "" %>
    <%
    }
    %>
];

console.log('從資料庫載入 ' + analyticsData.length + ' 筆資料');
console.log('資料內容:', analyticsData);

// 渲染點擊率分析
function renderAnalytics() {
    console.log('開始渲染點擊率分析...');
    
    // 檢查是否有資料
    if(analyticsData.length === 0) {
        console.log('沒有資料可以渲染');
        document.getElementById('analyticsTable').innerHTML = 
            '<tr><td colspan="5" style="text-align:center;padding:40px;color:#6c757d;">目前沒有資料</td></tr>';
        document.getElementById('topPostsRanking').innerHTML = 
            '<div style="text-align:center;padding:40px;color:#6c757d;">目前沒有貼文資料</div>';
        return;
    }
    
    // 渲染數據表格
    var tbody = document.getElementById('analyticsTable');
    if (!tbody) {
        console.error('找不到 analyticsTable 元素!');
        return;
    }
    console.log('找到 analyticsTable,準備渲染 ' + analyticsData.length + ' 筆資料');
    tbody.innerHTML = '';
    
    analyticsData.forEach(function(data) {
        var row = '<tr>' +
            '<td>' + String(data.id).padStart(3, '0') + '</td>' +
            '<td>' + data.title + '</td>' +
            '<td>' + data.author + '</td>' +
            '<td><strong>' + data.totalClicks.toLocaleString() + '</strong></td>' +
            '<td><span class="badge bg-primary">' + data.totalComments + '</span></td>' +
            '</tr>';
        tbody.innerHTML += row;
    });
    console.log('數據表格渲染完成!');

    // 渲染熱門貼文排行
    var topPostsDiv = document.getElementById('topPostsRanking');
    if (!topPostsDiv) {
        console.error('找不到 topPostsRanking 元素!');
        return;
    }
    
    var topPosts = analyticsData.slice().sort(function(a, b) { return b.totalClicks - a.totalClicks; }).slice(0, 10);

    if(topPosts.length === 0) {
        topPostsDiv.innerHTML = '<div style="text-align:center;padding:40px;color:#6c757d;">目前沒有貼文資料</div>';
        return;
    }

    var maxClicks = topPosts[0].totalClicks;
    var topPostsHTML = '';
    
    topPosts.forEach(function(post, index) {
        var percentage = maxClicks > 0 ? (post.totalClicks / maxClicks * 100).toFixed(1) : 0;
        topPostsHTML += '<div class="rank-item">' +
        '<div class="rank-number">' + (index + 1) + '</div>' +
        '<div class="rank-info">' +
        '<div><strong>' + post.title + '</strong> <small class="text-muted">by ' + post.author + '</small></div>' +
        '<div class="rank-bar"><div class="rank-bar-fill" style="width: ' + percentage + '%"></div></div>' +
        '<small class="text-muted">' + post.totalClicks.toLocaleString() + ' 次點擊 • ' + post.totalComments + ' 則留言</small>' +
        '</div></div>';
    });
    topPostsDiv.innerHTML = topPostsHTML;
    console.log('熱門貼文排行渲染完成!');
}

// 頁面載入時初始化
console.log('準備初始化...');
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderAnalytics);
} else {
    renderAnalytics();
}
</script>
</body>
</html>