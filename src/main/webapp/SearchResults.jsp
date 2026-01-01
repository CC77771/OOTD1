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
        
        // ✅ 修正：移除 member 表的 JOIN，直接使用 personal_wear 的資料
        String sql = "SELECT postid, " +
                     "       MAX(memberId) as memberId, " +
                     "       MAX(wearId) as wearId, " +
                     "       MAX(pic) as pic, " +
                     "       MAX([like]) as [like], " +
                     "       MAX(collect) as collect, " +
                     "       MAX(view) as view, " +
                     "       MAX(tags) as tags " +
                     "FROM personal_wear " +
                     "WHERE post_state = True " +
                     "AND (" +
                     "    tags = ? " +                              // 1. 完全匹配單一標籤
                     "    OR tags LIKE ? " +                        // 2. 標籤在開頭 "韓系,..."
                     "    OR tags LIKE ? " +                        // 3. 標籤在結尾 "...,韓系"
                     "    OR tags LIKE ? " +                        // 4. 標籤在中間 "...,韓系,..."
                     "    OR wearId LIKE ? " +                      // 5. 內容匹配
                     ") " +
                     "GROUP BY postid " +
                     "ORDER BY MAX([view]) DESC, postid DESC";      // 按瀏覽數和發布時間排序
        
        PreparedStatement pstmt = con.prepareStatement(sql);
        
        // 設置參數
        pstmt.setString(1, keyword);                           // 完全匹配
        pstmt.setString(2, keyword + ",%");                    // 開頭匹配
        pstmt.setString(3, "%," + keyword);                    // 結尾匹配
        pstmt.setString(4, "%," + keyword + ",%");             // 中間匹配
        pstmt.setString(5, "%" + keyword + "%");               // 內容模糊匹配
        
        System.out.println("=== 搜索除錯資訊 ===");
        System.out.println("搜索關鍵字: [" + keyword + "]");
        
        ResultSet rs = pstmt.executeQuery();
        
        while(rs.next()) {
            Map<String, Object> post = new HashMap<>();
            post.put("postid", rs.getString("postid"));
            post.put("wearId", rs.getString("wearId"));
            post.put("pic", rs.getString("pic"));
            post.put("like", rs.getInt("like"));
            post.put("collect", rs.getInt("collect"));
            post.put("view", rs.getInt("view"));
            post.put("memberId", rs.getString("memberId"));
            post.put("tags", rs.getString("tags"));
            
            // ✅ 計算相關度分數
            String tags = rs.getString("tags");
            int relevanceScore = 0;
            if(tags != null) {
                if(tags.equals(keyword)) {
                    relevanceScore = 100; // 完全匹配
                } else if(tags.contains("," + keyword + ",") || 
                         tags.startsWith(keyword + ",") || 
                         tags.endsWith("," + keyword)) {
                    relevanceScore = 80; // 精確標籤匹配
                } else if(tags.contains(keyword)) {
                    relevanceScore = 60; // 部分匹配
                }
            }
            String content = rs.getString("wearId");
            if(content != null && content.contains(keyword)) {
                relevanceScore += 20; // 內容匹配加分
            }
            post.put("relevanceScore", relevanceScore);
            
            searchResults.add(post);
            
            System.out.println("✅ 找到貼文 ID: " + rs.getString("postid") + 
                             ", 標籤: [" + tags + "]" +
                             ", 相關度: " + relevanceScore);
        }
        
        // ✅ 按相關度排序
        searchResults.sort((a, b) -> {
            int scoreA = (Integer) a.get("relevanceScore");
            int scoreB = (Integer) b.get("relevanceScore");
            if(scoreA != scoreB) {
                return scoreB - scoreA;
            }
            return ((Integer) b.get("view")) - ((Integer) a.get("view"));
        });
        
        totalResults = searchResults.size();
        System.out.println("📊 總共找到: " + totalResults + " 個結果");
        
        rs.close();
        pstmt.close();
        con.close();
        
    } catch(Exception e) {
        e.printStackTrace();
        System.out.println("❌ 搜索錯誤: " + e.getMessage());
        request.setAttribute("errorMessage", "搜索時發生錯誤: " + e.getMessage());
    }
}
%>

<%@include file="menu.jsp" %>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>搜索結果 - <%= keyword.isEmpty() ? "所有貼文" : keyword %></title>
    
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

        /* 搜索統計樣式 */
        .search-stats {
            text-align: center;
            margin: 30px 0;
            padding: 25px;
            background: linear-gradient(135deg, #fff 0%, #f8f5f0 100%);
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        }

        .search-stats .keyword {
            color: #a89f91;
            font-weight: bold;
            font-size: 28px;
            display: inline-block;
            padding: 5px 20px;
            background: linear-gradient(120deg, #f0ebe5 0%, #e8e0d5 100%);
            border-radius: 25px;
            margin: 0 10px;
            animation: highlight-pulse 2s ease-in-out infinite;
        }

        @keyframes highlight-pulse {
            0%, 100% {
                box-shadow: 0 2px 10px rgba(168, 159, 145, 0.2);
            }
            50% {
                box-shadow: 0 4px 20px rgba(168, 159, 145, 0.4);
            }
        }

        .search-stats .count {
            color: #8d7c70;
            font-weight: bold;
            font-size: 24px;
        }

        .search-stats .info-text {
            color: #666;
            font-size: 16px;
            margin: 10px 0;
        }

        /* 熱門標籤 */
        .popular-tags {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }

        .popular-tags h3 {
            color: #555;
            margin-bottom: 15px;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .popular-tags h3::before {
            content: '🔥';
            font-size: 24px;
        }

        .tag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }

        .tag-item {
            padding: 10px 20px;
            background-color: #e8e0d5;
            color: #555;
            border-radius: 25px;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            border: 2px solid transparent;
        }

        .tag-item:hover {
            background-color: #a89f91;
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(168, 159, 145, 0.3);
        }

        .tag-item.active {
            background-color: #a89f91;
            color: white;
            border-color: #8d7c70;
            box-shadow: 0 4px 15px rgba(168, 159, 145, 0.4);
        }

        /* 貼文網格 */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 30px;
            margin-top: 20px;
        }

        .post-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            cursor: pointer;
        }

        .post-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }

        .post-image {
            width: 100%;
            height: 400px;
            object-fit: cover;
            background-color: #f0f0f0;
        }

        .post-content {
            padding: 20px;
        }

        .post-header {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .post-author-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #a89f91;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 12px;
            font-size: 18px;
        }

        .post-author-info {
            flex: 1;
        }

        .post-author-name {
            font-weight: 600;
            color: #333;
            font-size: 15px;
            margin-bottom: 3px;
        }

        .post-time {
            font-size: 12px;
            color: #999;
        }

        .post-description {
            color: #333;
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            min-height: 72px;
        }

        /* 標籤樣式 */
        .post-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 15px;
            min-height: 32px;
        }

        .post-tag {
            background-color: #f0ebe5;
            color: #6b5d52;
            padding: 6px 14px;
            border-radius: 18px;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.3s ease;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .post-tag:hover {
            background-color: #d4c4b0;
            transform: translateY(-2px);
        }

        .post-tag.highlight {
            background: linear-gradient(135deg, #a89f91 0%, #9b8e82 100%);
            color: white;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(168, 159, 145, 0.4);
            position: relative;
            animation: tag-glow 2s ease-in-out infinite;
        }

        .post-tag.highlight::after {
            content: '✓';
            margin-left: 5px;
            font-weight: bold;
        }

        @keyframes tag-glow {
            0%, 100% {
                box-shadow: 0 4px 12px rgba(168, 159, 145, 0.4);
                transform: scale(1);
            }
            50% {
                box-shadow: 0 6px 20px rgba(168, 159, 145, 0.6);
                transform: scale(1.05);
            }
        }

        .post-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 15px;
            border-top: 1px solid #f0f0f0;
        }

        .action-buttons {
            display: flex;
            gap: 20px;
        }

        .action-button {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #666;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .action-button:hover {
            color: #a89f91;
        }

        .action-button svg {
            width: 20px;
            height: 20px;
            stroke: currentColor;
        }

        .view-count {
            display: flex;
            align-items: center;
            gap: 5px;
            color: #999;
            font-size: 13px;
        }

        /* 空狀態 */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        }

        .empty-state-icon {
            font-size: 100px;
            margin-bottom: 30px;
            animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-20px); }
        }

        .empty-state h2 {
            color: #555;
            margin-bottom: 15px;
            font-size: 26px;
        }

        .empty-state p {
            color: #999;
            font-size: 16px;
            margin-bottom: 30px;
        }

        .search-suggestions {
            margin-top: 30px;
            background: #f8f5f0;
            padding: 25px;
            border-radius: 15px;
        }

        .search-suggestions p {
            color: #666;
            margin-bottom: 12px;
            font-size: 15px;
        }

        .search-suggestions p:first-child {
            font-weight: bold;
            color: #a89f91;
            font-size: 16px;
        }

        /* 錯誤訊息樣式 */
        .error-message {
            background: #fff3cd;
            border: 2px solid #ffc107;
            color: #856404;
            padding: 15px 20px;
            border-radius: 10px;
            margin: 20px 0;
            text-align: left;
            font-size: 14px;
            line-height: 1.6;
        }

        .error-message strong {
            display: block;
            margin-bottom: 8px;
            font-size: 16px;
        }

        /* 響應式設計 */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }

            .posts-grid {
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 20px;
            }

            .post-image {
                height: 350px;
            }

            .search-stats .keyword {
                font-size: 22px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <% if(request.getAttribute("errorMessage") != null) { %>
            <div class="error-message">
                <strong>⚠️ 發生錯誤</strong>
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <% if(!keyword.isEmpty()) { %>
            <!-- 搜索結果統計 -->
            <div class="search-stats">
                <div class="info-text">搜索</div>
                <span class="keyword">#<%= keyword %></span>
                <div class="info-text" style="margin-top: 15px;">
                    找到 <span class="count"><%= totalResults %></span> 個相關貼文
                </div>
            </div>

            <!-- 熱門標籤 -->
            <div class="popular-tags">
                <h3>熱門標籤</h3>
                <div class="tag-list">
                    <a href="SearchResults.jsp?keyword=休閒風" class="tag-item <%= "休閒風".equals(keyword) ? "active" : "" %>">休閒風</a>
                    <a href="SearchResults.jsp?keyword=正式風" class="tag-item <%= "正式風".equals(keyword) ? "active" : "" %>">正式風</a>
                    <a href="SearchResults.jsp?keyword=韓系" class="tag-item <%= "韓系".equals(keyword) ? "active" : "" %>">韓系</a>
                    <a href="SearchResults.jsp?keyword=日系" class="tag-item <%= "日系".equals(keyword) ? "active" : "" %>">日系</a>
                    <a href="SearchResults.jsp?keyword=復古風" class="tag-item <%= "復古風".equals(keyword) ? "active" : "" %>">復古風</a>
                    <a href="SearchResults.jsp?keyword=運動風" class="tag-item <%= "運動風".equals(keyword) ? "active" : "" %>">運動風</a>
                    <a href="SearchResults.jsp?keyword=甜美風" class="tag-item <%= "甜美風".equals(keyword) ? "active" : "" %>">甜美風</a>
                    <a href="SearchResults.jsp?keyword=簡約風" class="tag-item <%= "簡約風".equals(keyword) ? "active" : "" %>">簡約風</a>
                    <a href="index1.jsp" class="tag-item" style="background-color: #ddd;">← 返回首頁</a>
                </div>
            </div>

            <% if(totalResults > 0) { %>
                <!-- 貼文網格 -->
                <div class="posts-grid">
                    <% for(Map<String, Object> post : searchResults) { 
                        String tags = (String) post.get("tags");
                        String[] tagArray = tags != null ? tags.split(",") : new String[0];
                        String memberId = (String) post.get("memberId");
                        String firstLetter = memberId != null ? memberId.substring(0, 1).toUpperCase() : "U";
                    %>
                    <div class="post-card" onclick="window.location.href='index1.jsp#post-<%= post.get("postid") %>'">
                        <img src="<%= post.get("pic") %>" alt="貼文圖片" class="post-image" 
                             onerror="this.src='images/default-post.jpg'">
                        <div class="post-content">
                            <!-- 發布者資訊 -->
                            <div class="post-header">
                                <div class="post-author-avatar"><%= firstLetter %></div>
                                <div class="post-author-info">
                                    <div class="post-author-name"><%= memberId != null ? memberId : "匿名用戶" %></div>
                                    <div class="post-time">今日OOTD</div>
                                </div>
                            </div>
                            
                            <!-- 貼文描述 -->
                            <div class="post-description">
                                <%= post.get("wearId") != null && !post.get("wearId").toString().trim().isEmpty() 
                                    ? post.get("wearId") 
                                    : "分享今日的穿搭風格 ✨" %>
                            </div>
                            
                            <!-- 標籤顯示 -->
                            <% if(tagArray.length > 0) { %>
                            <div class="post-tags">
                                <% for(String tag : tagArray) { 
                                    tag = tag.trim();
                                    if(!tag.isEmpty()) {
                                        boolean isHighlight = tag.equalsIgnoreCase(keyword);
                                %>
                                    <a href="SearchResults.jsp?keyword=<%= java.net.URLEncoder.encode(tag, "UTF-8") %>" 
                                       class="post-tag <%= isHighlight ? "highlight" : "" %>"
                                       onclick="event.stopPropagation()">
                                        #<%= tag %>
                                    </a>
                                <% 
                                    }
                                } %>
                            </div>
                            <% } %>
                            
                            <!-- 互動按鈕 -->
                            <div class="post-actions">
                                <div class="action-buttons">
                                    <div class="action-button">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                                        </svg>
                                        <span><%= post.get("like") %></span>
                                    </div>
                                    <div class="action-button">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                                        </svg>
                                        <span>0</span>
                                    </div>
                                    <div class="action-button">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>
                                        </svg>
                                        <span><%= post.get("collect") %></span>
                                    </div>
                                </div>
                                <div class="view-count">
                                    👁️ <%= post.get("view") %>
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
                    <h2>找不到 "#<%= keyword %>" 的相關貼文</h2>
                    <p>沒有貼文包含此標籤或關鍵字</p>
                    <div class="search-suggestions">
                        <p>💡 搜索建議：</p>
                        <p>• 檢查關鍵字拼寫是否正確</p>
                        <p>• 嘗試使用更通用的關鍵字</p>
                        <p>• 瀏覽上方的熱門標籤</p>
                        <p>• <a href="index1.jsp" style="color: #a89f91; text-decoration: underline;">返回首頁</a> 查看所有貼文</p>
                    </div>
                </div>
            <% } %>
        <% } else { %>
            <!-- 初始狀態 -->
            <div class="empty-state">
                <div class="empty-state-icon">✨</div>
                <h2>開始搜索</h2>
                <p>輸入關鍵字或標籤來搜索你喜歡的服飾風格</p>
            </div>
            
            <!-- 熱門標籤 -->
            <div class="popular-tags" style="margin-top: 30px;">
                <h3>熱門標籤</h3>
                <div class="tag-list">
                    <a href="SearchResults.jsp?keyword=休閒風" class="tag-item">休閒風</a>
                    <a href="SearchResults.jsp?keyword=正式風" class="tag-item">正式風</a>
                    <a href="SearchResults.jsp?keyword=韓系" class="tag-item">韓系</a>
                    <a href="SearchResults.jsp?keyword=日系" class="tag-item">日系</a>
                    <a href="SearchResults.jsp?keyword=復古風" class="tag-item">復古風</a>
                    <a href="SearchResults.jsp?keyword=運動風" class="tag-item">運動風</a>
                    <a href="SearchResults.jsp?keyword=甜美風" class="tag-item">甜美風</a>
                    <a href="SearchResults.jsp?keyword=簡約風" class="tag-item">簡約風</a>
                </div>
            </div>
        <% } %>
    </div>

    <script>
        // 高亮搜索關鍵字
        function highlightKeyword() {
            const keyword = '<%= keyword %>';
            if(!keyword) return;
            
            const descriptions = document.querySelectorAll('.post-description');
            descriptions.forEach(desc => {
                const text = desc.innerHTML;
                const regex = new RegExp(`(${keyword})`, 'gi');
                desc.innerHTML = text.replace(regex, '<mark style="background-color: #fff3cd; padding: 2px 4px; border-radius: 3px; font-weight: 600;">$1</mark>');
            });
        }

        window.onload = function() {
            highlightKeyword();
            
            document.querySelectorAll('.post-tag:not(.highlight)').forEach(tag => {
                tag.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-3px) scale(1.05)';
                });
                tag.addEventListener('mouseleave', function() {
                    this.style.transform = '';
                });
            });
        };
    </script>
</body>
</html>