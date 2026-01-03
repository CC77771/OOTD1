<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file = "menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>我的收藏 - CZ Web</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f0;
            color: #333;
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
        }

        .header {
            background: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
            text-align: center;
        }

        .header h1 {
            font-size: 32px;
            color: #333;
            margin: 0;
        }

        .tabs {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 20px;
        }

        .tab-button {
            background-color: #e0e0e0;
            color: #333;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s;
        }

        .tab-button.active {
            background-color: #a89f91;
            color: #fff;
        }

        .tab-button:hover {
            background-color: #8b8d7a;
            color: #fff;
        }

        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }

        .post-card {
            background: #fff;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
        }

        .post-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
        }

        .post-image {
            width: 100%;
            height: auto; 
            max-height: 400px;  
            object-fit: contain;
            background-color: #f5f5f5;
        }

        .post-content {
            padding: 15px;
            background-color: #f5f5f5;
        }

        .post-author {
            font-size: 14px;
            color: #666;
            margin-bottom: 5px;
        }

        .post-theme {
            font-size: 15px;
            color: #333;
            margin-bottom: 10px;
            font-weight: 500;
        }

        .tags-container {
            margin-bottom: 10px;
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
        }

        .post-tags {
            display: inline-block;
            background-color: transparent;
            color: #666;
            padding: 0;
            font-size: 13px;
        }

        .post-stats {
            display: flex;
            justify-content: flex-start;
            gap: 15px;
            font-size: 14px;
            color: #666;
            border-top: 1px solid #e0e0e0;
            padding-top: 10px;
        }

        .stat-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .stat-item:hover {
            transform: scale(1.1);
        }

        .stat-item i {
            font-size: 20px;
        }

        .stat-count {
            font-size: 13px;
        }

        /* 按讚和收藏的狀態 */
        .like-icon[data-liked="true"] path {
            fill: red !important;
            stroke: red;
        }

        .star-icon[data-collected="true"] path {
            fill: yellow !important;
            stroke: #333;
        }

        .empty-message {
            text-align: center;
            padding: 60px 20px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .empty-message i {
            font-size: 64px;
            color: #ccc;
            margin-bottom: 20px;
        }

        .empty-message p {
            font-size: 18px;
            color: #666;
        }

        /* 留言模態框樣式 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: #fff;
            margin: 0 auto;
            padding: 25px;
            border-radius: 15px;
            width: 80%;
            max-width: 600px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-height: 80vh;
            overflow-y: auto;
        }

        .close {
            color: #555;
            font-size: 30px;
            font-weight: bold;
            position: absolute;
            top: 10px;
            right: 20px;
            cursor: pointer;
        }

        .close:hover {
            color: #000;
        }

        .comment-display {
            margin-bottom: 20px;
            text-align: left;
            font-size: 14px;
            color: #555;
        }

        .comment-display h3 {
            font-size: 18px;
            color: #333;
        }

        #commentList {
            list-style-type: none;
            padding-left: 0;
        }

        #commentList li {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            margin-bottom: 10px;
            text-align: left;
            line-height: 1.6;
        }

        #commentList li strong {
            margin-right: 8px;
            color: #a89f91;
        }

        #commentText {
            width: 100%;
            height: 80px;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            border: 1px solid #ddd;
            font-size: 14px;
        }

        .modal button {
            padding: 10px 20px;
            background-color: #a89f91;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        .modal button:hover {
            background-color: #8f8c7f;
        }

        @media screen and (max-width: 768px) {
            .posts-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 15px;
            }

            .post-image {
                height: auto;
                max-height: 250px; 
            }

            .tabs {
                flex-direction: column;
                gap: 10px;
            }

            .tab-button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<%
    String currentMemberId = (String) session.getAttribute("accessId");
    String activeTab = request.getParameter("tab");
    if (activeTab == null) {
        activeTab = "likes";
    }

    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    Statement smt = con.createStatement();
    
    // 建立留言資料的 JavaScript
    StringBuilder commentsDataJS = new StringBuilder();
    commentsDataJS.append("var allComments = {");
%>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-heart"></i> 我的收藏與按讚</h1>
        <div class="tabs">
            <button class="tab-button <%= activeTab.equals("likes") ? "active" : "" %>" 
                    onclick="location.href='myFavorites.jsp?tab=likes'">
                <i class="fas fa-heart"></i> 我按讚的 (<%= getCount(con, "user_likes", currentMemberId) %>)
            </button>
            <button class="tab-button <%= activeTab.equals("collects") ? "active" : "" %>" 
                    onclick="location.href='myFavorites.jsp?tab=collects'">
                <i class="fas fa-star"></i> 我收藏的 (<%= getCount(con, "user_collects", currentMemberId) %>)
            </button>
        </div>
    </div>

    <div class="posts-grid">
    <%
        // 除錯：顯示當前使用者ID
        out.println("<!-- 當前使用者: " + currentMemberId + " -->");
        out.println("<!-- 當前分頁: " + activeTab + " -->");
        
        String sql = "";
        if (activeTab.equals("likes")) {
            sql = "SELECT pw.postid, " +
                  "       FIRST(pw.memberId) as memberId, " +
                  "       FIRST(pw.wearId) as wearId, " +
                  "       FIRST(pw.pic) as pic, " +
                  "       MAX(pw.[like]) as [like], " +
                  "       MAX(pw.collect) as collect, " +
                  "       MAX(pw.view) as view, " +
                  "       FIRST(pw.tags) as tags " +
                  "FROM personal_wear pw " +
                  "INNER JOIN user_likes ul ON pw.postId = ul.postId " +
                  "WHERE ul.memberId = '" + currentMemberId + "' AND pw.post_state = True " +
                  "GROUP BY pw.postid " +
                  "ORDER BY pw.postid DESC";
        } else {
            sql = "SELECT pw.postid, " +
                  "       FIRST(pw.memberId) as memberId, " +
                  "       FIRST(pw.wearId) as wearId, " +
                  "       FIRST(pw.pic) as pic, " +
                  "       MAX(pw.[like]) as [like], " +
                  "       MAX(pw.collect) as collect, " +
                  "       MAX(pw.view) as view, " +
                  "       FIRST(pw.tags) as tags " +
                  "FROM personal_wear pw " +
                  "INNER JOIN user_collects uc ON pw.postId = uc.postId " +
                  "WHERE uc.memberId = '" + currentMemberId + "' AND pw.post_state = True " +
                  "GROUP BY pw.postid " +
                  "ORDER BY pw.postid DESC";
        }
        
        out.println("<!-- SQL: " + sql + " -->");

        ResultSet rs = smt.executeQuery(sql);
        boolean hasResults = false;
        int count = 0;

        while (rs.next()) {
            hasResults = true;
            count++;
            String postid = rs.getString("postid");
            String memberId = rs.getString("memberId");
            String theme = rs.getString("wearId");
            String pic = rs.getString("pic");
            String tags = rs.getString("tags");
            int likes = rs.getInt("like");
            int collects = rs.getInt("collect");
            int views = rs.getInt("view");
            
            // 查詢當前會員是否已按讚
            boolean isLiked = false;
            String checkLikeSql = "SELECT COUNT(*) as cnt FROM user_likes WHERE memberId = ? AND postid = ?";
            PreparedStatement pstmtLike = con.prepareStatement(checkLikeSql);
            pstmtLike.setString(1, currentMemberId);
            pstmtLike.setString(2, postid);
            ResultSet rsLike = pstmtLike.executeQuery();
            if(rsLike.next() && rsLike.getInt("cnt") > 0) {
                isLiked = true;
            }
            rsLike.close();
            pstmtLike.close();
            
            // 查詢當前會員是否已收藏
            boolean isCollected = false;
            String checkCollectSql = "SELECT COUNT(*) as cnt FROM user_collects WHERE memberId = ? AND postid = ?";
            PreparedStatement pstmtCollect = con.prepareStatement(checkCollectSql);
            pstmtCollect.setString(1, currentMemberId);
            pstmtCollect.setString(2, postid);
            ResultSet rsCollect = pstmtCollect.executeQuery();
            if(rsCollect.next() && rsCollect.getInt("cnt") > 0) {
                isCollected = true;
            }
            rsCollect.close();
            pstmtCollect.close();
            
            // 查詢留言
            String commentQuery = "SELECT message, memberId FROM personal_wear WHERE postid = ? AND message IS NOT NULL AND TRIM(message) != '' ORDER BY recordid ASC";
            PreparedStatement pstmtComment = con.prepareStatement(commentQuery);
            pstmtComment.setString(1, postid);
            ResultSet rsComment = pstmtComment.executeQuery();
            
            commentsDataJS.append("'").append(postid).append("': [");
            boolean hasComment = false;
            while(rsComment.next()) {
                if(hasComment) commentsDataJS.append(",");
                String message = rsComment.getString("message");
                String commentMemberId = rsComment.getString("memberId");
                message = message.replace("'", "\\'").replace("\n", "\\n").replace("\r", "");
                commentMemberId = commentMemberId.replace("'", "\\'");
                commentsDataJS.append("{member:'").append(commentMemberId).append("',message:'").append(message).append("'}");
                hasComment = true;
            }
            commentsDataJS.append("],");
            rsComment.close();
            pstmtComment.close();
            
            // 查詢留言數
            String messageQuery = "SELECT COUNT(*) AS message_count FROM personal_wear WHERE postid = ? AND message IS NOT NULL AND TRIM(message) != ''";
            PreparedStatement pstmt2 = con.prepareStatement(messageQuery);
            pstmt2.setString(1, postid);
            ResultSet messageRs = pstmt2.executeQuery();
            int messageCount = 0;
            if (messageRs.next()) {
                messageCount = messageRs.getInt("message_count");
            }
            messageRs.close();
            pstmt2.close();
    %>
        <div class="post-card" data-postid="<%= postid %>">
            <div onclick="location.href='index1.jsp?postid=<%= postid %>#post-<%= postid %>'" style="cursor: pointer;">
                <img src="<%= pic %>" alt="Post Image" class="post-image" onerror="this.src='images/default.jpg'">
                <div class="post-content">
                    <div class="post-author"><%= memberId != null ? memberId : "匿名用戶" %></div>
                    <div class="post-theme"><%= theme != null ? theme : "無主題" %></div>
                    <div class="tags-container">
                        <% if (tags != null && !tags.trim().isEmpty()) { 
                            String[] tagArray = tags.split(",");
                            for (String tag : tagArray) {
                                if(tag != null && !tag.trim().isEmpty()) {
                        %>
                            <span class="post-tags">#<%= tag.trim() %></span>
                        <% 
                                }
                            }
                        } %>
                    </div>
                </div>
            </div>
            <div class="post-stats">
                <span class="stat-item like-icon" onclick="toggleLike(this, event)" data-liked="<%= isLiked %>">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"></path>
                    </svg>
                    <span class="stat-count likes-count"><%= likes %></span>
                </span>
                <span class="stat-item comment-icon" onclick="toggleComment(this, event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M21 11.5a8.5 8.5 0 1 0-13.971 6.607l-3.75 3.75a1 1 0 0 0-.23 1.082A1 1 0 0 0 4 21h4.582a8.5 8.5 0 0 0 12.418-9.5z"></path>
                    </svg>
                    <span class="stat-count comments-count"><%= messageCount %></span>
                </span>
                <span class="stat-item star-icon" onclick="toggleStar(this, event)" data-collected="<%= isCollected %>">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"></path>
                    </svg>
                    <span class="stat-count stars-count"><%= collects %></span>
                </span>
                <span class="stat-item">
                    <i class="fas fa-eye"></i>
                    <span class="stat-count"><%= views %></span>
                </span>
            </div>
        </div>
    <%
        }
        
        out.println("<!-- 找到 " + count + " 筆資料 -->");

        if (!hasResults) {
    %>
        <div class="empty-message" style="grid-column: 1 / -1;">
            <i class="fas fa-heart-broken"></i>
            <p>目前還沒有任何<%= activeTab.equals("likes") ? "按讚" : "收藏" %>的貼文</p>
        </div>
    <%
        }

        commentsDataJS.append("};");
        rs.close();
    %>
    </div>
</div>

<!-- 留言模態框 -->
<div class="modal" id="commentModal" style="display: none;">
    <div class="modal-content">
        <span class="close" onclick="closeCommentModal()">&times;</span>
        
        <!-- 顯示留言區域 -->
        <div id="commentDisplay" class="comment-display">
            <h3>留言內容：</h3>
            <ul id="commentList">
                <!-- 留言會動態載入到這裡 -->
            </ul>
        </div>

        <!-- 輸入留言 -->
        <form name="form" action="update.jsp" method="post">                          
            <textarea name="text" id="commentText" placeholder="請輸入您的留言..." rows="5"></textarea>
            <input type="hidden" name="memberId" value="<%= currentMemberId %>">
            <input type="hidden" name="postid" id="hiddenPostid" value="">
            <button type="submit" name="submitButton">提交留言</button>
        </form>
    </div>
</div>

<script>
// 載入留言數據
<%= commentsDataJS.toString() %>

// 按讚功能
function toggleLike(element, event) {
    event.stopPropagation();
    
    const icon = element.querySelector('svg path');
    const isLiked = element.getAttribute('data-liked') === 'true';
    const action = isLiked ? 'remove' : 'add';
    
    const postCard = element.closest('.post-card');
    const postid = postCard.getAttribute('data-postid');
    const memberId = '<%= currentMemberId %>';
    
    fetch('updateLike.jsp?postid=' + postid + '&memberId=' + memberId + '&action=' + action)
        .then(response => response.text())
        .then(data => {
            const newCount = data.trim();
            if (newCount !== 'error' && !isNaN(newCount)) {
                element.setAttribute('data-liked', !isLiked);
                icon.style.fill = isLiked ? 'none' : 'red';
                icon.style.stroke = isLiked ? 'currentColor' : 'red';
                
                const likeCountElement = element.querySelector('.likes-count');
                likeCountElement.textContent = newCount;
                
                // 如果在按讚頁面且取消按讚，可選擇移除卡片
                <% if (activeTab.equals("likes")) { %>
                if (!isLiked === false) {
                    setTimeout(() => {
                        postCard.style.transition = 'opacity 0.3s';
                        postCard.style.opacity = '0';
                        setTimeout(() => postCard.remove(), 300);
                    }, 500);
                }
                <% } %>
            } else {
                alert('操作失敗，請稍後再試！');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤，請稍後再試！');
        });
}

// 收藏功能
function toggleStar(element, event) {
    event.stopPropagation();
    
    const icon = element.querySelector('svg path');
    const isCollected = element.getAttribute('data-collected') === 'true';
    const action = isCollected ? 'remove' : 'add';
    
    const postCard = element.closest('.post-card');
    const postid = postCard.getAttribute('data-postid');
    const memberId = '<%= currentMemberId %>';
    
    fetch('updateCollect.jsp?postid=' + postid + '&memberId=' + memberId + '&action=' + action)
        .then(response => response.text())
        .then(data => {
            const newCount = data.trim();
            if (newCount !== 'error' && !isNaN(newCount)) {
                element.setAttribute('data-collected', !isCollected);
                icon.style.fill = isCollected ? 'none' : 'yellow';
                
                const starCountElement = element.querySelector('.stars-count');
                starCountElement.textContent = newCount;
                
                // 如果在收藏頁面且取消收藏，可選擇移除卡片
                <% if (activeTab.equals("collects")) { %>
                if (!isCollected === false) {
                    setTimeout(() => {
                        postCard.style.transition = 'opacity 0.3s';
                        postCard.style.opacity = '0';
                        setTimeout(() => postCard.remove(), 300);
                    }, 500);
                }
                <% } %>
            } else {
                alert('操作失敗，請稍後再試！');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤，請稍後再試！');
        });
}

// 留言功能
function toggleComment(element, event) {
    event.stopPropagation();
    
    const postCard = element.closest('.post-card');
    const postid = postCard.getAttribute('data-postid');
    
    document.getElementById('hiddenPostid').value = postid;
    
    const commentList = document.getElementById('commentList');
    commentList.innerHTML = '';
    
    if (allComments[postid] && allComments[postid].length > 0) {
        allComments[postid].forEach(function(comment) {
            const li = document.createElement('li');
            li.innerHTML = '<strong>' + comment.member + ':</strong> ' + comment.message;
            commentList.appendChild(li);
        });
    } else {
        commentList.innerHTML = '<li style="color: #999;">目前還沒有留言，快來搶沙發吧！</li>';
    }
    
    document.getElementById('commentModal').style.display = 'flex';
}

// 關閉留言模態框
function closeCommentModal() {
    document.getElementById('commentModal').style.display = 'none';
}
</script>

<%
    smt.close();
    con.close();
%>

</body>
</html>

<%!
    public int getCount(Connection con, String tableName, String memberId) {
        try {
            Statement stmt = con.createStatement();
            String sql = "SELECT COUNT(*) as cnt FROM " + tableName + " WHERE memberId = '" + memberId + "'";
            ResultSet rs = stmt.executeQuery(sql);
            if (rs.next()) {
                return rs.getInt("cnt");
            }
            rs.close();
            stmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
%>