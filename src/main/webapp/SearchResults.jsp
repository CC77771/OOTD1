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

// 存儲搜索結果 - 使用 LinkedHashMap 確保不重複
Map<String, Map<String, Object>> uniqueResults = new LinkedHashMap<>();
int totalResults = 0;

if(!keyword.isEmpty()) {
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // ✅ 簡化查詢 - 先取得符合條件的 postid，再用 MAX 取得其他欄位
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
                     "AND (tags LIKE ? OR wearId LIKE ?) " +
                     "GROUP BY postid " +
                     "ORDER BY MAX([view]) DESC, postid DESC";
        
        PreparedStatement pstmt = con.prepareStatement(sql);
        String searchPattern = "%" + keyword + "%";
        pstmt.setString(1, searchPattern);
        pstmt.setString(2, searchPattern);
        
        System.out.println("=== 搜索關鍵字: [" + keyword + "] ===");
        System.out.println("=== 搜索模式: [" + searchPattern + "] ===");
        
        ResultSet rs = pstmt.executeQuery();
        
        while(rs.next()) {
            String postid = rs.getString("postid");
            
            // 使用 postid 作為 key，確保不重複
            if(!uniqueResults.containsKey(postid)) {
                Map<String, Object> post = new HashMap<>();
                post.put("postid", postid);
                post.put("wearId", rs.getString("wearId"));
                post.put("pic", rs.getString("pic"));
                post.put("like", rs.getInt("like"));
                post.put("collect", rs.getInt("collect"));
                post.put("view", rs.getInt("view"));
                post.put("memberId", rs.getString("memberId"));
                post.put("tags", rs.getString("tags"));
                
                uniqueResults.put(postid, post);
                System.out.println("✅ 找到: " + postid + " | 標籤: " + rs.getString("tags"));
            }
        }
        
        totalResults = uniqueResults.size();
        System.out.println("📊 總計: " + totalResults + " 筆（已去重）");
        
        rs.close();
        pstmt.close();
        con.close();
        
    } catch(Exception e) {
        e.printStackTrace();
        System.out.println("❌ 錯誤: " + e.getMessage());
    }
}

// 轉換為 List 供 JSP 使用
List<Map<String, Object>> searchResults = new ArrayList<>(uniqueResults.values());
%>

<%@include file="menu.jsp" %>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>搜索 - <%= keyword.isEmpty() ? "所有貼文" : keyword %></title>
    
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
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        /* 🔍 搜索統計區 */
        .search-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .search-keyword {
            display: inline-block;
            font-size: 32px;
            font-weight: bold;
            color: #a89f91;
            padding: 15px 30px;
            background: linear-gradient(135deg, #f0ebe5 0%, #e8e0d5 100%);
            border-radius: 30px;
            margin-bottom: 15px;
            box-shadow: 0 4px 15px rgba(168, 159, 145, 0.2);
        }

        .search-count {
            font-size: 18px;
            color: #666;
        }

        .search-count strong {
            color: #a89f91;
            font-size: 24px;
        }

        /* 🔥 熱門標籤 */
        .tags-section {
            background: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
        }

        .tags-title {
            font-size: 16px;
            color: #555;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .tags-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .tag-btn {
            padding: 8px 18px;
            background: #e8e0d5;
            color: #555;
            border-radius: 20px;
            text-decoration: none;
            font-size: 14px;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .tag-btn:hover {
            background: #a89f91;
            color: white;
            transform: translateY(-2px);
        }

        .tag-btn.active {
            background: #a89f91;
            color: white;
            border-color: #8d7c70;
        }

        /* 📱 像參考圖片一樣整齊的卡片 */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
        }

        .post-card {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            cursor: pointer;
            display: flex;
            flex-direction: column;
        }

        .post-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }

        /* 圖片區域 - 正方形 */
        .post-image-wrapper {
            width: 100%;
            padding-bottom: 100%; /* 1:1 正方形 */
            position: relative;
            overflow: hidden;
            background: #f5f5f5;
        }

        .post-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        /* 內容區域 - 緊湊設計 */
        .post-content {
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        /* 用戶資訊 - 簡潔版 */
        .post-author {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .author-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #b5a89a, #9b8e82);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 14px;
            flex-shrink: 0;
        }

        .author-info {
            flex: 1;
            min-width: 0;
        }

        .author-name {
            font-weight: 600;
            color: #333;
            font-size: 13px;
            line-height: 1.3;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .author-name .id {
            font-weight: 700;
        }

        .post-date {
            font-size: 11px;
            color: #999;
            margin-top: 2px;
        }

        /* 標籤 - 只顯示一個標籤，淺黃色背景 */
        .post-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .post-tag {
            padding: 8px 16px;
            background: #fff9e6;
            color: #666;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            white-space: nowrap;
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .post-tag::before {
            content: '#';
            color: #999;
        }

        .post-tag:hover {
            background: #fff3cd;
            transform: translateY(-1px);
        }

        /* 互動按鈕 - 緊湊排列 */
        .post-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 8px;
            border-top: 1px solid #f0f0f0;
        }

        .action-btns {
            display: flex;
            gap: 12px;
        }

        .action-btn {
            display: flex;
            align-items: center;
            gap: 4px;
            color: #666;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .action-btn:hover {
            color: #a89f91;
        }

        .action-btn svg {
            width: 16px;
            height: 16px;
        }

        .view-count {
            display: flex;
            align-items: center;
            gap: 3px;
            color: #999;
            font-size: 11px;
        }

        /* 空狀態 */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        }

        .empty-icon {
            font-size: 100px;
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

        /* 響應式 */
        @media (max-width: 1200px) {
            .posts-grid {
                grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            }
        }

        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }

            .posts-grid {
                grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                gap: 15px;
            }

            .search-keyword {
                font-size: 24px;
                padding: 10px 20px;
            }

            .post-content {
                padding: 10px;
            }
        }

        @media (max-width: 480px) {
            .posts-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <% if(!keyword.isEmpty()) { %>
            <!-- 🔍 搜索標題 -->
            <div class="search-header">
                <div class="search-keyword">#<%= keyword %></div>
                <div class="search-count">
                    找到 <strong><%= totalResults %></strong> 個相關貼文
                </div>
            </div>

            <!-- 🔥 熱門標籤 -->
            <div class="tags-section">
                <div class="tags-title">🔥 熱門標籤</div>
                <div class="tags-list">
                    <a href="SearchResults.jsp?keyword=休閒" class="tag-btn <%= keyword.contains("休閒") ? "active" : "" %>">休閒</a>
                    <a href="SearchResults.jsp?keyword=正式" class="tag-btn <%= keyword.contains("正式") ? "active" : "" %>">正式</a>
                    <a href="SearchResults.jsp?keyword=韓系" class="tag-btn <%= keyword.contains("韓系") ? "active" : "" %>">韓系</a>
                    <a href="SearchResults.jsp?keyword=日系" class="tag-btn <%= keyword.contains("日系") ? "active" : "" %>">日系</a>
                    <a href="SearchResults.jsp?keyword=復古" class="tag-btn <%= keyword.contains("復古") ? "active" : "" %>">復古</a>
                    <a href="SearchResults.jsp?keyword=運動" class="tag-btn <%= keyword.contains("運動") ? "active" : "" %>">運動</a>
                    <a href="SearchResults.jsp?keyword=甜美" class="tag-btn <%= keyword.contains("甜美") ? "active" : "" %>">甜美</a>
                    <a href="SearchResults.jsp?keyword=簡約" class="tag-btn <%= keyword.contains("簡約") ? "active" : "" %>">簡約</a>
                    <a href="index1.jsp" class="tag-btn" style="background: #ddd;">← 返回</a>
                </div>
            </div>

            <% if(totalResults > 0) { %>
                <!-- 📱 貼文網格 -->
                <div class="posts-grid">
                    <% for(Map<String, Object> post : searchResults) { 
                        String tags = (String) post.get("tags");
                        String[] tagArray = tags != null ? tags.split(",") : new String[0];
                        String memberId = (String) post.get("memberId");
                        String firstLetter = memberId != null && !memberId.isEmpty() 
                            ? memberId.substring(0, 1).toUpperCase() : "U";
                        
                        // 從 wearId 獲取文案，如果為空則使用預設值
                        String description = (String) post.get("wearId");
                        if(description == null || description.trim().isEmpty()) {
                            description = "今日OOTD";
                        }
                    %>
                    <div class="post-card" onclick="window.location.href='index1.jsp#post-<%= post.get("postid") %>'">
                        <!-- 圖片 -->
                        <div class="post-image-wrapper">
                            <img src="<%= post.get("pic") %>" alt="貼文" class="post-image" 
                                 onerror="this.src='images/default-post.jpg'">
                        </div>

                        <!-- 內容 -->
                        <div class="post-content">
                            <!-- 用戶資訊 - 簡潔版 -->
                            <div class="post-author">
                                <div class="author-avatar"><%= firstLetter %></div>
                                <div class="author-info">
                                    <div class="author-name">
                                        <span class="id"><%= memberId != null ? memberId : "匿名" %></span>
                                        <span class="post-date"><%= description %></span>
                                    </div>
                                </div>
                            </div>

                            <!-- 標籤 - 只顯示第一個匹配的標籤 -->
                            <div class="post-tags">
                                <% 
                                // 優先顯示匹配的標籤，如果沒有則顯示第一個標籤
                                String displayTag = null;
                                
                                // 先找匹配的標籤
                                for(String tag : tagArray) { 
                                    tag = tag.trim();
                                    if(!tag.isEmpty() && tag.toLowerCase().contains(keyword.toLowerCase())) {
                                        displayTag = tag;
                                        break;
                                    }
                                }
                                
                                // 如果沒有匹配的，取第一個標籤
                                if(displayTag == null && tagArray.length > 0) {
                                    displayTag = tagArray[0].trim();
                                }
                                
                                // 顯示標籤
                                if(displayTag != null && !displayTag.isEmpty()) {
                                %>
                                    <a href="SearchResults.jsp?keyword=<%= java.net.URLEncoder.encode(displayTag, "UTF-8") %>" 
                                       class="post-tag"
                                       onclick="event.stopPropagation()">
                                        <%= displayTag %>
                                    </a>
                                <% 
                                }
                                %>
                            </div>

                            <!-- 互動按鈕 -->
                            <div class="post-actions">
                                <div class="action-btns">
                                    <div class="action-btn">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                                        </svg>
                                        <span><%= post.get("like") %></span>
                                    </div>
                                    <div class="action-btn">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M21 11.5a8.5 8.5 0 1 0-13.971 6.607l-3.75 3.75a1 1 0 0 0-.23 1.082A1 1 0 0 0 4 21h4.582a8.5 8.5 0 0 0 12.418-9.5z"/>
                                        </svg>
                                        <span>0</span>
                                    </div>
                                    <div class="action-btn">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>
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
                    <div class="empty-icon">🔍</div>
                    <h2>找不到包含 "<%= keyword %>" 的相關貼文</h2>
                    <p>試試其他關鍵字或瀏覽熱門標籤</p>
                </div>
            <% } %>
        <% } else { %>
            <!-- 初始狀態 -->
            <div class="empty-state">
                <div class="empty-icon">✨</div>
                <h2>開始搜索</h2>
                <p>輸入關鍵字來搜索你喜歡的穿搭風格</p>
            </div>

            <div class="tags-section" style="margin-top: 30px;">
                <div class="tags-title">🔥 熱門標籤</div>
                <div class="tags-list">
                    <a href="SearchResults.jsp?keyword=休閒" class="tag-btn">休閒</a>
                    <a href="SearchResults.jsp?keyword=正式" class="tag-btn">正式</a>
                    <a href="SearchResults.jsp?keyword=韓系" class="tag-btn">韓系</a>
                    <a href="SearchResults.jsp?keyword=日系" class="tag-btn">日系</a>
                    <a href="SearchResults.jsp?keyword=復古" class="tag-btn">復古</a>
                    <a href="SearchResults.jsp?keyword=運動" class="tag-btn">運動</a>
                    <a href="SearchResults.jsp?keyword=甜美" class="tag-btn">甜美</a>
                    <a href="SearchResults.jsp?keyword=簡約" class="tag-btn">簡約</a>
                </div>
            </div>
        <% } %>
    </div>
</body>
</html>