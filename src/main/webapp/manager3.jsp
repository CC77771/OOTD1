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
    
    // === 資料庫連線 ===
    String dbPath = objDBConfig.FilePath();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // 儲存資料的 ArrayList
    ArrayList<Map<String, Object>> analyticsDataList = new ArrayList<>();
    
    try {
        conn = getConnection(dbPath);
        
        // 使用 GROUP BY 確保每個貼文只出現一次，同時統計留言數
        String sql = "SELECT p.postid, " +
                     "       MAX(p.memberid) as memberid, " +
                     "       MAX(p.wearId) as wearId, " +
                     "       MAX(p.view) as view, " +
                     "       SUM(CASE WHEN p.message IS NOT NULL AND p.message <> '' THEN 1 ELSE 0 END) as commentCount " +
                     "FROM personal_wear p " +
                     "WHERE p.post_state = True " +
                     "GROUP BY p.postid " +
                     "ORDER BY MAX(p.view) DESC";
        
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while(rs.next()) {
            Map<String, Object> data = new HashMap<>();
            
            data.put("id", rs.getInt("postid"));
            data.put("title", rs.getString("wearId"));
            data.put("author", rs.getString("memberid"));
            data.put("totalClicks", rs.getInt("view"));
            data.put("totalComments", rs.getInt("commentCount"));
            
            analyticsDataList.add(data);
        }
        
    } catch(Exception e) {
        out.println("<div class='alert alert-danger'>資料庫錯誤: " + e.getMessage() + "</div>");
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

/* 移除 Active 卡片的特殊樣式，讓它跟其他的一樣 */
.nav-tabs .nav-link.active {
    background: #ffffff;
    color: #333 !important;
    border: 1px solid #ddd;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transform: none;
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
            <a class="nav-link" href="userManagement.jsp">👥 使用者管理</a>
        </li>
        
		<li class="nav-item">
    <a class="nav-link active" style="background-color: #0d6efd; color: #000;">
        📊 點擊率分析
    </a>
</li>

    </ul>

    <!-- 點擊率分析內容 -->
    <div class="analytics-content">
        <!-- 第一行：熱門貼文排行 -->
        <div class="row">
            <div class="col-md-12">
                <div class="analytics-card">
                    <h5>🏆 熱門貼文排行 TOP 10</h5>
                    <div id="topPostsRanking"></div>
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
        String title = data.get("title") != null ? data.get("title").toString().replace("'", "\\'").replace("\n", " ").replace("\r", " ") : "";
    %>
    {
        id: <%= data.get("id") %>,
        title: '<%= title %>',
        author: '<%= data.get("author") %>',
        totalClicks: <%= data.get("totalClicks") %>,
        totalComments: <%= data.get("totalComments") %>
    }<%= (i < analyticsDataList.size() - 1) ? "," : "" %>
    <%
    }
    %>
];

console.log('從資料庫載入 ' + analyticsData.length + ' 筆資料');

// 渲染點擊率分析
function renderAnalytics() {
    console.log('開始渲染點擊率分析...');
    
 // 檢查是否有資料
    if(analyticsData.length === 0) {
        console.log('沒有資料可以渲染');
        return;
    }
    
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
            '<td><span class="badge bg-primary">' + data.totalComments + '</span></td>' +
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

    if(topPosts.length === 0) {
        topPostsDiv.innerHTML = '<div style="text-align:center;padding:40px;color:#6c757d;">目前沒有貼文資料</div>';
        return;
    }

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
}

//頁面載入時初始化
console.log('準備初始化...');
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderAnalytics);
} else {
    renderAnalytics();
}
</script>
</body>
</html>