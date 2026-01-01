<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />

<%
// 獲取搜索關鍵字
String keyword = request.getParameter("keyword");
if(keyword == null) keyword = "";
keyword = keyword.trim();

// 存儲搜索結果
List<Map<String, Object>> searchResults = new ArrayList<>();
int totalResults = 0;

if(!keyword.isEmpty()) {
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 搜索貼文 - 在 wearId (文字描述) 或 tags 欄位中搜尋關鍵字
        String sql = "SELECT pw.*, m.name as memberName " +
                     "FROM personal_wear pw " +
                     "LEFT JOIN member m ON pw.memberId = m.memberId " +
                     "WHERE pw.post_state = True " +
                     "AND (pw.wearId LIKE ? OR pw.tags LIKE ?) " +
                     "ORDER BY pw.wearId DESC";
        
        PreparedStatement pstmt = con.prepareStatement(sql);
        String searchPattern = "%" + keyword + "%";
        pstmt.setString(1, searchPattern);
        pstmt.setString(2, searchPattern);
        
        ResultSet rs = pstmt.executeQuery();
        
        while(rs.next()) {
            Map<String, Object> post = new HashMap<>();
            post.put("wearId", rs.getString("wearId"));
            post.put("pic", rs.getString("pic"));
            post.put("like", rs.getInt("like"));
            post.put("collect", rs.getInt("collect"));
            post.put("view", rs.getInt("view"));
            post.put("memberId", rs.getString("memberId"));
            post.put("memberName", rs.getString("memberName"));
            post.put("tags", rs.getString("tags"));
            searchResults.add(post);
        }
        
        totalResults = searchResults.size();
        
        rs.close();
        pstmt.close();
        con.close();
        
    } catch(Exception e) {
        e.printStackTrace();
    }
}
%>

<%@include file="menu.jsp" %>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>搜索結果 - <%= keyword %></title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Arial', 'Microsoft JhengHei', sans-serif;
            background-color: #f8f8f8;
            padding-top: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* 搜索結果統計 */
        .search-stats {
            text-align: center;
            margin: 20px 0;
            color: #666;
            font-size: 18px;
        }

        .search-stats .keyword {
            color: #a89f91;
            font-weight: bold;
            font-size: 20px;
        }

        .search-stats .count {
            color: #8d7c70;
            font-weight: bold;
        }

        /* 熱門標籤 */
        .popular-tags {
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .popular-tags h3 {
            color: #555;
            margin-bottom: 15px;
            font-size: 16px;
        }

        .tag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .tag-item {
            padding: 8px 16px;
            background-color: #e8e0d5;
            color: #555;
            border-radius: 20px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .tag-item:hover {
            background-color: #a89f91;
            color: white;
            transform: translateY(-2px);
        }

        .tag-item.active {
            background-color: #a89f91;
            color: white;
        }

        /* 貼文網格 */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .post-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }

        .post-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
        }

        .post-image {
            width: 100%;
            height: 280px;
            object-fit: cover;
            background-color: #f0f0f0;
        }

        .post-content {
            padding: 15px;
        }

        .post-description {
            color: #333;
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 10px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            min-height: 42px;
        }

        .post-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 10px;
            min-height: 24px;
        }

        .post-tag {
            background-color: #e8e0d5;
            color: #666;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
        }

        .post-tag.highlight {
            background-color: #a89f91;
            color: white;
            font-weight: bold;
        }

        .post-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 10px;
            border-top: 1px solid #eee;
        }

        .post-author {
            color: #666;
            font-size: 13px;
        }

        .post-stats {
            display: flex;
            gap: 15px;
            color: #999;
            font-size: 13px;
        }

        .post-stats span {
            display: flex;
            align-items: center;
            gap: 3px;
        }

        /* 空狀態 */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .empty-state-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }

        .empty-state h2 {
            color: #555;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #999;
            font-size: 16px;
        }

        /* 響應式設計 */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }

            .posts-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 10px;
            }

            .post-image {
                height: 200px;
            }

            .post-content {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <% if(!keyword.isEmpty()) { %>
            <!-- 搜索結果統計 -->
            <div class="search-stats">
                搜索 "<span class="keyword"><%= keyword %></span>" 找到 <span class="count"><%= totalResults %></span> 個結果
            </div>

            <!-- 熱門標籤 -->
            <div class="popular-tags">
                <h3>🔥 熱門標籤</h3>
                <div class="tag-list">
                    <a href="SearchResults.jsp?keyword=休閒風" class="tag-item <%= "休閒風".equals(keyword) ? "active" : "" %>">#休閒風</a>
                    <a href="SearchResults.jsp?keyword=正式風" class="tag-item <%= "正式風".equals(keyword) ? "active" : "" %>">#正式風</a>
                    <a href="SearchResults.jsp?keyword=韓系" class="tag-item <%= "韓系".equals(keyword) ? "active" : "" %>">#韓系</a>
                    <a href="SearchResults.jsp?keyword=日系" class="tag-item <%= "日系".equals(keyword) ? "active" : "" %>">#日系</a>
                    <a href="SearchResults.jsp?keyword=復古風" class="tag-item <%= "復古風".equals(keyword) ? "active" : "" %>">#復古風</a>
                    <a href="SearchResults.jsp?keyword=運動風" class="tag-item <%= "運動風".equals(keyword) ? "active" : "" %>">#運動風</a>
                    <a href="SearchResults.jsp?keyword=甜美風" class="tag-item <%= "甜美風".equals(keyword) ? "active" : "" %>">#甜美風</a>
                    <a href="SearchResults.jsp?keyword=簡約風" class="tag-item <%= "簡約風".equals(keyword) ? "active" : "" %>">#簡約風</a>
                </div>
            </div>

            <% if(totalResults > 0) { %>
                <!-- 貼文網格 -->
                <div class="posts-grid">
                    <% for(Map<String, Object> post : searchResults) { 
                        String tags = (String) post.get("tags");
                        String[] tagArray = tags != null ? tags.split(",") : new String[0];
                    %>
                    <div class="post-card" onclick="viewPost('<%= post.get("wearId") %>')">
                        <img src="<%= post.get("pic") %>" alt="貼文圖片" class="post-image" 
                             onerror="this.src='images/default-post.jpg'">
                        <div class="post-content">
                            <div class="post-description">
                                <%= post.get("wearId") != null ? post.get("wearId") : "無描述" %>
                            </div>
                            
                            <% if(tagArray.length > 0) { %>
                            <div class="post-tags">
                                <% for(String tag : tagArray) { 
                                    tag = tag.trim();
                                    boolean isHighlight = tag.toLowerCase().contains(keyword.toLowerCase());
                                %>
                                    <span class="post-tag <%= isHighlight ? "highlight" : "" %>"><%= tag %></span>
                                <% } %>
                            </div>
                            <% } %>
                            
                            <div class="post-meta">
                                <div class="post-author">
                                    👤 <%= post.get("memberName") != null ? post.get("memberName") : "匿名用戶" %>
                                </div>
                                <div class="post-stats">
                                    <span>❤️ <%= post.get("like") %></span>
                                    <span>👁️ <%= post.get("view") %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else { %>
                <!-- 空狀態 -->
                <div class="empty-state">
                    <div class="empty-state-icon">🔍</div>
                    <h2>找不到相關貼文</h2>
                    <p>試試搜索其他關鍵字，或瀏覽熱門標籤</p>
                </div>
            <% } %>
        <% } else { %>
            <!-- 初始狀態 -->
            <div class="empty-state">
                <div class="empty-state-icon">✨</div>
                <h2>開始搜索</h2>
                <p>輸入關鍵字來搜索你喜歡的服飾風格</p>
            </div>
            
            <!-- 熱門標籤 -->
            <div class="popular-tags" style="margin-top: 30px;">
                <h3>🔥 熱門標籤</h3>
                <div class="tag-list">
                    <a href="SearchResults.jsp?keyword=休閒風" class="tag-item">#休閒風</a>
                    <a href="SearchResults.jsp?keyword=正式風" class="tag-item">#正式風</a>
                    <a href="SearchResults.jsp?keyword=韓系" class="tag-item">#韓系</a>
                    <a href="SearchResults.jsp?keyword=日系" class="tag-item">#日系</a>
                    <a href="SearchResults.jsp?keyword=復古風" class="tag-item">#復古風</a>
                    <a href="SearchResults.jsp?keyword=運動風" class="tag-item">#運動風</a>
                    <a href="SearchResults.jsp?keyword=甜美風" class="tag-item">#甜美風</a>
                    <a href="SearchResults.jsp?keyword=簡約風" class="tag-item">#簡約風</a>
                    <a href="SearchResults.jsp?keyword=波西米亞" class="tag-item">#波西米亞</a>
                    <a href="SearchResults.jsp?keyword=龐克風" class="tag-item">#龐克風</a>
                    <a href="SearchResults.jsp?keyword=學院風" class="tag-item">#學院風</a>
                    <a href="SearchResults.jsp?keyword=嘻哈風" class="tag-item">#嘻哈風</a>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        function viewPost(wearId) {
            // 導向到貼文詳細頁面（你需要創建這個頁面）
            window.location.href = 'PostDetail.jsp?wearId=' + encodeURIComponent(wearId);
        }

        // 高亮搜索關鍵字（可選功能）
        function highlightKeyword() {
            const keyword = '<%= keyword %>';
            if(!keyword) return;
            
            const descriptions = document.querySelectorAll('.post-description');
            descriptions.forEach(desc => {
                const text = desc.textContent;
                const regex = new RegExp(`(${keyword})`, 'gi');
                desc.innerHTML = text.replace(regex, '<mark style="background-color: #fff3cd;">$1</mark>');
            });
        }

        // 頁面載入後執行
        window.onload = function() {
            highlightKeyword();
        };
    </script>
</body>
</html>