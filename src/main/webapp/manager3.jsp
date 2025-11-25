<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@include file ="menu.jsp" %>

<%
    // === 模擬 Session 登入資料 ===
    String admin = "AdminUser";
    String role = "Administrator";

    // 取得當前日期
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String currentDate = sdf.format(new Date());
%>

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

/* Active 卡片 */
.nav-tabs .nav-link.active {
    background: #0d6efd;
    color: #fff !important;
    border: 1px solid #0d6efd;
    box-shadow: 0 8px 16px rgba(0,0,0,0.2);
    transform: translateY(-5px);
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
            <a class="nav-link" href="userManagement.jsp">👥 使用者管理</a>
        </li>

        <li class="nav-item">
            <a class="nav-link active" href="analytics.jsp">📊 點擊率分析</a>
        </li>
    </ul>

    <!-- 點擊率分析內容 -->
    <div class="analytics-content">
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// 從 JSP 傳入的當前日期
var currentDate = '<%= currentDate %>';

// 資料儲存
var analyticsData = [];

// 初始化資料
function initData() {
    console.log('開始初始化資料...');

    // 點擊率分析模擬數據
    analyticsData = [
        {id: 1, title: '秋季OOTD分享', author: 'user_01', totalClicks: 2580, todayClicks: 156, avgTime: '2:45', engagement: '8.5%'},
        {id: 2, title: '街頭風穿搭', author: 'user_02', totalClicks: 1920, todayClicks: 98, avgTime: '2:12', engagement: '6.8%'},
        {id: 3, title: '冬季衣服推薦', author: 'user_03', totalClicks: 3150, todayClicks: 203, avgTime: '3:20', engagement: '9.2%'},
        {id: 4, title: '極簡風格穿搭', author: 'user_01', totalClicks: 1650, todayClicks: 87, avgTime: '1:55', engagement: '5.4%'},
        {id: 5, title: '約會穿搭分享', author: 'user_04', totalClicks: 2340, todayClicks: 142, avgTime: '2:30', engagement: '7.6%'},
        {id: 6, title: '韓系穿搭教學', author: 'user_02', totalClicks: 2890, todayClicks: 178, avgTime: '2:58', engagement: '8.9%'},
        {id: 7, title: '復古風搭配', author: 'user_03', totalClicks: 1480, todayClicks: 76, avgTime: '1:48', engagement: '5.1%'},
        {id: 8, title: '運動休閒風', author: 'user_01', totalClicks: 2120, todayClicks: 125, avgTime: '2:22', engagement: '7.2%'},
        {id: 9, title: '職場穿搭分享', author: 'user_04', totalClicks: 1850, todayClicks: 95, avgTime: '2:05', engagement: '6.3%'},
        {id: 10, title: '夏日清新風格', author: 'user_02', totalClicks: 3420, todayClicks: 215, avgTime: '3:35', engagement: '9.8%'}
    ];
    console.log('點擊率資料:', analyticsData);

    renderAnalytics();
    console.log('初始化完成！');
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

// 頁面載入時初始化
console.log('準備初始化...');
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initData);
} else {
    initData();
}
</script>
</body>
</html>