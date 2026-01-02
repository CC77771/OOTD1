<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@include file="menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />

<%
// 在頁面最開始就宣告所有需要的變數
String targetMemberId = request.getParameter("memberId");
String currentMemberId = (String) session.getAttribute("accessId");

// 初始化變數為預設值
boolean userFound = false;
String userName = targetMemberId != null ? targetMemberId : "";
String userNickName = targetMemberId != null ? targetMemberId : "";
String userGender = "未設定";
String userPic = null;
String userPosition = "未設定";  // ← 添加這一行
int postCount = 0;
int totalLikes = 0;
int totalCollects = 0;

StringBuilder commentsDataJS = new StringBuilder();
commentsDataJS.append("var allComments = {");

Connection con = null;
PreparedStatement pstmtUser = null;
PreparedStatement pstmtStats = null;
PreparedStatement pstmtWardrobe = null;
PreparedStatement pstmtPosts = null;
ResultSet rsUser = null;
ResultSet rsStats = null;
ResultSet rsWardrobe = null;
ResultSet rsPosts = null;

java.util.ArrayList<java.util.HashMap<String, String>> wardrobeList = new java.util.ArrayList<>();

try {
    if(targetMemberId == null || targetMemberId.trim().isEmpty()) {
        response.sendRedirect("index1.jsp");
        return;
    }

    // 連接資料庫
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
 // 查詢用戶基本資料 (加入 JOIN position 表)
    String userInfoSql = "SELECT pi.*, p.positionName " +
                         "FROM personal_information pi " +
                         "LEFT JOIN position p ON pi.positionId = p.positionId " +
                         "WHERE pi.memberId = ?";
    pstmtUser = con.prepareStatement(userInfoSql);
    pstmtUser.setString(1, targetMemberId);
    rsUser = pstmtUser.executeQuery();

    if(rsUser.next()) {
        userFound = true;
        userNickName = rsUser.getString("nickName") != null ? rsUser.getString("nickName") : targetMemberId;
        userName = userNickName;
        
        int genderCode = rsUser.getInt("gendercode");
        if(genderCode == 1) {
            userGender = "男";
        } else if(genderCode == 2) {
            userGender = "女";
        }
        
        userPic = rsUser.getString("pic");
        
        // 直接讀取 positionName
        userPosition = rsUser.getString("positionName");
        if(userPosition == null || userPosition.trim().isEmpty()) {
            userPosition = "未設定";
        }
    }
    
    // 統計資料
    String statsSql = "SELECT COUNT(DISTINCT postid) as postCount, " +
                      "SUM([like]) as totalLikes, " +
                      "SUM(collect) as totalCollects " +
                      "FROM personal_wear " +
                      "WHERE memberId = ? AND post_state = True " +
                      "GROUP BY memberId";
    pstmtStats = con.prepareStatement(statsSql);
    pstmtStats.setString(1, targetMemberId);
    rsStats = pstmtStats.executeQuery();
    
    if(rsStats.next()) {
        postCount = rsStats.getInt("postCount");
        totalLikes = rsStats.getInt("totalLikes");
        totalCollects = rsStats.getInt("totalCollects");
    }
    
    // 查詢該用戶的衣櫃資料
    String wardrobeSql = "SELECT * FROM my_wardrobe WHERE memberId = ? AND state = True ORDER BY clothing_number DESC";
    pstmtWardrobe = con.prepareStatement(wardrobeSql);
    pstmtWardrobe.setString(1, targetMemberId);
    rsWardrobe = pstmtWardrobe.executeQuery();
    
    // 將衣櫃資料存入 ArrayList
    while(rsWardrobe.next()) {
        java.util.HashMap<String, String> item = new java.util.HashMap<>();
        item.put("pic", rsWardrobe.getString("pic"));
        item.put("description", rsWardrobe.getString("text_description") != null ? rsWardrobe.getString("text_description") : "未命名");
        item.put("brand", rsWardrobe.getString("brand") != null ? rsWardrobe.getString("brand") : "");
        item.put("color", rsWardrobe.getString("color_code") != null ? rsWardrobe.getString("color_code") : "");
        item.put("size", rsWardrobe.getString("size") != null ? rsWardrobe.getString("size") : "");
        wardrobeList.add(item);
    }
    
    // 查詢該用戶的所有貼文
    String postsSql = "SELECT postid, " +
                     "FIRST(memberId) as memberId, " +
                     "FIRST(wearId) as wearId, " +
                     "FIRST(pic) as pic, " +
                     "MAX([like]) as likeCount, " +
                     "MAX(collect) as collectCount, " +
                     "MAX(view) as viewCount, " +
                     "FIRST(tags) as tags " +
                     "FROM personal_wear " +
                     "WHERE memberId = ? AND post_state = True " +
                     "GROUP BY postid " +
                     "ORDER BY postid DESC";
    pstmtPosts = con.prepareStatement(postsSql);
    pstmtPosts.setString(1, targetMemberId);
    rsPosts = pstmtPosts.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%=userName%> 的個人頁面</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="css/vendor.css">
    <link rel="stylesheet" type="text/css" href="style.css">
    
    <style>
        body {
            background-color: #f8f5f0;
            font-family: 'Jost', sans-serif;
            padding-top: 80px;
        }
        
        .profile-header {
            background: linear-gradient(165deg, #a89f91 0%, #8f8c7f 100%);
            color: white;
            padding: 60px 0;
            margin-bottom: 40px;
        }
        
        .profile-avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 60px;
            color: #a89f91;
            margin: 0 auto 20px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
            font-weight: bold;
            overflow: hidden;
        }
        
        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .profile-info h2 {
            font-size: 32px;
            margin-bottom: 10px;
            font-weight: 500;
        }
        
        .profile-username {
            font-size: 16px;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        
        .profile-gender {
            font-size: 14px;
            opacity: 0.8;
            display: inline-block;
            padding: 4px 12px;
            background: rgba(255,255,255,0.2);
            border-radius: 15px;
            margin-top: 10px;
        }
        
        .profile-stats {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: 28px;
            font-weight: bold;
            display: block;
        }
        
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .content-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .section-title {
            font-size: 24px;
            color: #4a4239;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #a89f91;
            display: flex;
            align-items: center;
        }
        
        .section-title svg {
            margin-right: 8px;
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
        }

        .post-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
        }

        .post-image {
            width: 100%;
            height: 280px;
            object-fit: cover;
            background-color: #f5f5f5;
            cursor: pointer;
        }

        .post-content {
            padding: 15px;
            background-color: #f5f5f5;
            cursor: pointer;
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
            padding: 15px;
            background: white;
        }

        .post-stats .stat-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
            cursor: pointer;
            transition: transform 0.2s;
            text-align: center;
        }

        .post-stats .stat-item:hover {
            transform: scale(1.1);
        }

        .post-stats .stat-item svg {
            width: 24px;
            height: 24px;
        }

        .stat-count {
            font-size: 13px;
        }

        .like-icon[data-liked="true"] svg path {
            fill: red !important;
            stroke: red;
        }

        .star-icon[data-collected="true"] svg path {
            fill: yellow !important;
            stroke: #333;
        }
        
        .wardrobe-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .wardrobe-item {
            border: 2px solid #f0ebe5;
            border-radius: 10px;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        
        .wardrobe-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(168, 159, 145, 0.3);
            border-color: #a89f91;
        }
        
        .wardrobe-item img {
            width: 100%;
            height: 250px;
            object-fit: cover;
        }
        
        .wardrobe-item-info {
            padding: 12px;
            background: #f8f5f0;
        }
        
        .wardrobe-item-desc {
            font-weight: 500;
            color: #4a4239;
            margin-bottom: 5px;
            font-size: 14px;
        }
        
        .wardrobe-item-brand {
            font-size: 12px;
            color: #999;
            margin-bottom: 3px;
        }
        
        .wardrobe-item-details {
            font-size: 13px;
            color: #6a6158;
            display: flex;
            justify-content: space-between;
            margin-top: 5px;
        }
        
        .back-btn {
            background: white;
            color: #a89f91;
            border: 2px solid #a89f91;
            padding: 10px 30px;
            border-radius: 25px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }
        
        .back-btn:hover {
            background: #a89f91;
            color: white;
            text-decoration: none;
        }
        
        .empty-message {
            text-align: center;
            padding: 60px 20px;
            color: #999;
            font-size: 18px;
            grid-column: 1 / -1;
        }
        
        .user-not-found {
            text-align: center;
            padding: 100px 20px;
        }
        
        .user-not-found-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        
        .nav-tabs {
            border-bottom: 2px solid #f0ebe5;
            margin-bottom: 30px;
        }
        
        .nav-tabs .nav-link {
            color: #6a6158;
            border: none;
            border-bottom: 3px solid transparent;
            padding: 12px 24px;
            font-weight: 500;
        }
        
        .nav-tabs .nav-link:hover {
            color: #a89f91;
            border-color: transparent;
        }
        
        .nav-tabs .nav-link.active {
            color: #a89f91;
            background: transparent;
            border-color: #a89f91;
        }
        
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
            position: relative;
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
    </style>
</head>
<body>

<%
if(!userFound) {
%>
    <div class="container">
        <div class="user-not-found">
            <div class="user-not-found-icon">😔</div>
            <h2>找不到此用戶</h2>
            <p class="text-muted">用戶 @<%=targetMemberId%> 不存在或尚未建立個人資料</p>
            <a href="index1.jsp" class="back-btn mt-3">← 返回首頁</a>
        </div>
    </div>
<%
} else {
%>

<div class="profile-header">
    <div class="container">
        <a href="index1.jsp" class="back-btn">← 返回首頁</a>
        
        <div class="profile-info text-center">
            <div class="profile-avatar">
                <% if(userPic != null && !userPic.trim().isEmpty()) { %>
                    <img src="<%=userPic%>" alt="<%=userName%>">
                <% } else { %>
                    <%= userName.substring(0, Math.min(2, userName.length())).toUpperCase() %>
                <% } %>
            </div>
            
            <h2><%=userName%></h2>
            <p class="profile-username">@<%=targetMemberId%></p>
            <span class="profile-gender"><%=userGender%></span>
            
            <!-- ← 添加這段顯示職位 -->
<span class="profile-gender" style="margin-left: 10px;"><%=userPosition%></span>
            
            
            <div class="profile-stats">
                <div class="stat-item">
                    <span class="stat-number"><%=postCount%></span>
                    <span class="stat-label">發文數</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number"><%=totalLikes%></span>
                    <span class="stat-label">獲得讚數</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number"><%=totalCollects%></span>
                    <span class="stat-label">獲得收藏</span>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container mb-5">
    <ul class="nav nav-tabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="posts-tab" data-bs-toggle="tab" data-bs-target="#posts" type="button" role="tab">
                📝 發布的貼文
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="wardrobe-tab" data-bs-toggle="tab" data-bs-target="#wardrobe" type="button" role="tab">
                👔 衣櫃
            </button>
        </li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade show active" id="posts" role="tabpanel">
            <div class="content-section">
                <h3 class="section-title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                    </svg>
                    發布的貼文
                </h3>
                
                <div class="posts-grid">
                    <%
                    boolean hasPosts = false;
                    
                    while(rsPosts.next()) {
                        hasPosts = true;
                        String postid = String.valueOf(rsPosts.getInt("postid"));
                        String memberId = rsPosts.getString("memberId");
                        String theme = rsPosts.getString("wearId");
                        String pic = rsPosts.getString("pic");
                        String tags = rsPosts.getString("tags");
                        int likes = rsPosts.getInt("likeCount");
                        int collects = rsPosts.getInt("collectCount");
                        int views = rsPosts.getInt("viewCount");
                        
                        boolean isLiked = false;
                        if(currentMemberId != null) {
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
                        }
                        
                        boolean isCollected = false;
                        if(currentMemberId != null) {
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
                        }
                        
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
                        <div onclick="location.href='index1.jsp?postid=<%= postid %>#post-<%= postid %>'">
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
                    %>
                </div>
                
                <% if(!hasPosts) { %>
                <div class="empty-message">
                    <i class="fas fa-heart-broken"></i>
                    <p>📝 此用戶還沒有發布貼文</p>
                    <p style="font-size: 14px; color: #bbb;">快來期待第一篇穿搭分享吧!</p>
                </div>
                <% } %>
            </div>
        </div>

        <div class="tab-pane fade" id="wardrobe" role="tabpanel">
            <div class="content-section">
                <h3 class="section-title">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="9" y1="3" x2="9" y2="21"></line>
                    </svg>
                    衣櫃
                </h3>
                
                <div class="wardrobe-grid">
                    <% 
                    for(java.util.HashMap<String, String> item : wardrobeList) { 
                    %>
                    <div class="wardrobe-item">
                        <img src="<%=item.get("pic")%>" 
                             alt="<%=item.get("description")%>"
                             onerror="this.style.display='none'; this.parentElement.innerHTML='<div style=\'padding:50px;text-align:center;color:#999;background:#f8f5f0;height:250px;display:flex;align-items:center;justify-content:center;flex-direction:column;\'>📷<br><small>圖片載入失敗</small></div>'">
                        <div class="wardrobe-item-info">
                            <div class="wardrobe-item-desc"><%=item.get("description")%></div>
                            <% if(!item.get("brand").isEmpty()) { %>
                            <div class="wardrobe-item-brand">品牌:<%=item.get("brand")%></div>
                            <% } %>
                            <div class="wardrobe-item-details">
                                <span><%=item.get("color")%></span>
                                <span><%=item.get("size")%></span>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                
                <% if(wardrobeList.isEmpty()) { %>
                <div class="empty-message">
                    <i class="fas fa-tshirt"></i>
                    <p>😊 此用戶的衣櫃還是空的</p>
                    <p style="font-size: 14px; color: #bbb;">尚未新增任何衣物</p>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<div class="modal" id="commentModal" style="display: none;">
    <div class="modal-content">
        <span class="close" onclick="closeCommentModal()">&times;</span>
        
        <div id="commentDisplay" class="comment-display">
            <h3>留言內容:</h3>
            <ul id="commentList"></ul>
        </div>

        <% if(currentMemberId != null) { %>
        <form name="form" action="update.jsp" method="post">                          
            <textarea name="text" id="commentText" placeholder="請輸入您的留言..." rows="5"></textarea>
            <input type="hidden" name="memberId" value="<%= currentMemberId %>">
            <input type="hidden" name="postid" id="hiddenPostid" value="">
            <button type="submit" name="submitButton">提交留言</button>
        </form>
        <% } else { %>
        <p style="color: #999; margin-top: 15px;">請先登入以發表留言</p>
        <% } %>
    </div>
</div>

<%
    commentsDataJS.append("};");
%>

<script>
// 載入留言數據
<%= commentsDataJS.toString() %>

// 按讚功能
function toggleLike(element, event) {
    event.stopPropagation();
    
    <% if(currentMemberId == null) { %>
        alert('請先登入才能按讚!');
        return;
    <% } %>
    
    const icon = element.querySelector('svg path');
    const isLiked = element.getAttribute('data-liked') === 'true';
    const action = isLiked ? 'remove' : 'add';
    
    const postCard = element.closest('.post-card');
    const postid = postCard.getAttribute('data-postid');
    const memberId = '<%= currentMemberId != null ? currentMemberId : "" %>';
    
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
            } else {
                alert('操作失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
        });
}

// 收藏功能
function toggleStar(element, event) {
    event.stopPropagation();
    
    <% if(currentMemberId == null) { %>
        alert('請先登入才能收藏!');
        return;
    <% } %>
    
    const icon = element.querySelector('svg path');
    const isCollected = element.getAttribute('data-collected') === 'true';
    const action = isCollected ? 'remove' : 'add';
    
    const postCard = element.closest('.post-card');
    const postid = postCard.getAttribute('data-postid');
    const memberId = '<%= currentMemberId != null ? currentMemberId : "" %>';
    
    fetch('updateCollect.jsp?postid=' + postid + '&memberId=' + memberId + '&action=' + action)
        .then(response => response.text())
        .then(data => {
            const newCount = data.trim();
            if (newCount !== 'error' && !isNaN(newCount)) {
                element.setAttribute('data-collected', !isCollected);
                icon.style.fill = isCollected ? 'none' : 'yellow';
                
                const starCountElement = element.querySelector('.stars-count');
                starCountElement.textContent = newCount;
            } else {
                alert('操作失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
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
        commentList.innerHTML = '<li style="color: #999;">目前還沒有留言,快來搶沙發吧!</li>';
    }
    
    document.getElementById('commentModal').style.display = 'flex';
}

// 關閉留言模態框
function closeCommentModal() {
    document.getElementById('commentModal').style.display = 'none';
}

// 點擊模態框外部關閉
window.onclick = function(event) {
    const modal = document.getElementById('commentModal');
    if (event.target === modal) {
        closeCommentModal();
    }
}
</script>

<%
} // 關閉 else 區塊
%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%
} catch(Exception e) {
    out.println("<html><body>");
    out.println("<div class='container mt-5' style='padding-top:100px;'>");
    out.println("<div class='alert alert-danger'>");
    out.println("<h2>❌ 發生錯誤</h2>");
    out.println("<p><strong>錯誤訊息:</strong>" + e.getMessage() + "</p>");
    out.println("<pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    out.println("</pre>");
    out.println("<a href='index1.jsp' class='btn btn-primary mt-3'>返回首頁</a>");
    out.println("</div>");
    out.println("</div>");
    out.println("</body></html>");
} finally {
    try {
        if(rsPosts != null) rsPosts.close();
        if(pstmtPosts != null) pstmtPosts.close();
        if(rsWardrobe != null) rsWardrobe.close();
        if(pstmtWardrobe != null) pstmtWardrobe.close();
        if(rsStats != null) rsStats.close();
        if(pstmtStats != null) pstmtStats.close();
        if(rsUser != null) rsUser.close();
        if(pstmtUser != null) pstmtUser.close();
        if(con != null) con.close();
    } catch(SQLException e) {
        e.printStackTrace();
    }
}
%>