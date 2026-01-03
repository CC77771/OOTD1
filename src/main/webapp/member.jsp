<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file = "menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>CZ Web</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f0; 
            color: #333;
        }

        .container {
            max-width: 900px;
            margin: 40px auto;
            background: #fff;
            border-radius: 10px;
            padding: 40px 30px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            border: 1px solid #e0e0e0;
        }

        h1, h3 {
            font-size: 28px;
            font-weight: 600;
            color: #333;
        }

        h3 {
            font-size: 22px;
            margin-bottom: 20px;
        }

        .info {
            text-align: center; 
            margin-bottom: 30px;
        }

        .info span {
            font-size: 16px;
            color: #666;
            margin-top: 10px;
            display: block;
        }

        .profile-image {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }

        .profile-image img {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            border: 3px solid #a89f91;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .form-section {
            margin-top: 30px;
        }

        .form-section input[type="text"],
        .form-section select,
        .form-section input[type="file"],
        .form-section button {
            width: 100%;
            padding: 12px;
            font-size: 16px;
            border-radius: 8px;
            border: 1px solid #ddd;
            margin-bottom: 20px;
            box-sizing: border-box;
        }

        .form-section input[type="text"],
        .form-section select {
            background-color: #f9f9f9; 
        }

        .form-section button {
            background: #a89f91; 
            color: white;
            border: none;
            cursor: pointer;
        }

        .form-section button:hover {
            background: #8b8d7a;
        }

        .dropdown {
            position: relative;
            display: inline-block;
        }

        .dropdown button {
            background: #a89f91; 
            color: #fff;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
        }

        .dropdown-content {
            display: none;
            position: absolute;
            background-color: #fff;
            min-width: 160px;
            box-shadow: 0px 8px 16px rgba(0, 0, 0, 0.2);
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid #ddd;
        }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        .dropdown-content select {
            background-color: #fff;
            border: 1px solid #ddd;
            font-size: 16px;
            padding: 12px;
            border-radius: 8px;
            width: 100%;
        }

        .dropdown-content button {
            background: #a89f91;
            color: white;
            font-size: 16px;
            padding: 12px;
            cursor: pointer;
            border-radius: 8px;
            width: 100%;
            margin-top: 10px;
        }

        .dropdown-content button:hover {
            background: #8b8d7a; 
        }

        @media screen and (max-width: 600px) {
            .container {
                margin: 10px;
                padding: 20px;
            }

            .profile-image img {
                width: 120px;
                height: 120px;
            }

            h1 {
                font-size: 24px;
            }

            h3 {
                font-size: 20px;
            }

            .form-section input[type="text"],
            .form-section select,
            .form-section button {
                padding: 10px;
                font-size: 14px;
            }
        }

        .custom-button {
            background-color: #a89f91;
            color: #fff;
            border: none;
            padding: 10px 30px;
            border-radius: 5px;
            text-decoration: none;
            cursor: pointer;
            display: inline-block;
            text-align: center;
        }

        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
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
            height: 200px;
            object-fit: contain; /* ✅ 改這裡 */
            background-color: #f5f5f5;
        }

        .post-content-mini {
            padding: 12px;
            background-color: #f5f5f5;
        }

        .post-theme-mini {
            font-size: 14px;
            color: #333;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .tags-container-mini {
            margin-bottom: 8px;
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
        }

        .post-tag-mini {
            display: inline-block;
            color: #666;
            font-size: 12px;
        }

        .post-stats-mini {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: #666;
            border-top: 1px solid #e0e0e0;
            padding-top: 8px;
        }

        .post-stats-mini span {
            display: flex;
            align-items: center;
            gap: 3px;
        }

        .empty-message-mini {
            text-align: center;
            padding: 40px 20px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            grid-column: 1 / -1;
        }

        .empty-message-mini i {
            font-size: 48px;
            color: #ccc;
            margin-bottom: 15px;
        }

        .empty-message-mini p {
            font-size: 16px;
            color: #666;
        }

       /* ✅ 彈出視窗樣式 (放大卡片版) */
.post-modal {
    display: none;
    position: fixed;
    z-index: 2000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.85);
    justify-content: center;
    align-items: center;
    overflow: auto;
    padding: 20px;
}

.modal-close {
    position: absolute;
    top: 20px;
    right: 30px;
    color: #fff;
    font-size: 40px;
    font-weight: bold;
    cursor: pointer;
    z-index: 2001;
    transition: transform 0.2s;
}

.modal-close:hover {
    transform: scale(1.1);
}

.modal-card {
    background: #fff;
    border-radius: 15px;
    width: 90%;
    max-width: 500px;
    max-height: 90vh;
    overflow-y: auto;
    position: relative;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

/* 圖片區 (無黑邊框) */
.modal-image-container {
    width: 100%;
    background: #fff;
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 15px 15px 0 0;
    overflow: hidden;
}

.modal-image-container img {
    width: 100%;
    height: auto;
    object-fit: contain;
    max-height: 500px;
    display: block;
}

/* 右上角按鈕 */
.modal-top-buttons {
    position: absolute;
    top: 15px;
    right: 15px;
    z-index: 10;
    display: flex;
    gap: 10px;
}

.modal-action-btn {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    transition: all 0.3s;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}

.edit-btn {
    background: rgba(168, 159, 145, 0.9);
    color: white;
}

.edit-btn:hover {
    background: rgba(168, 159, 145, 1);
    transform: scale(1.1);
}

.delete-btn {
    background: rgba(255, 0, 0, 0.85);
    color: white;
}

.delete-btn:hover {
    background: rgba(200, 0, 0, 1);
    transform: scale(1.1);
}

/* 內容區 */
.modal-card-content {
    padding: 20px;
    background: #fff;
    border-radius: 0 0 15px 15px;
}

.modal-author-section {
    font-size: 15px;
    color: #333;
    margin-bottom: 8px;
    font-weight: 600;
}

.modal-theme-section {
    font-size: 16px;
    color: #333;
    margin-bottom: 12px;
}

/* 標籤區 */
.modal-tags-section {
    margin-bottom: 15px;
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
}

.modal-tag {
    display: inline-block;
    color: #0095f6;
    font-size: 13px;
    background: transparent;
    padding: 0;
}

/* 統計數據 (像第二張圖) */
.modal-stats {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    gap: 20px;
    padding: 12px 0;
    border-top: 1px solid #e0e0e0;
    border-bottom: 1px solid #e0e0e0;
    margin-bottom: 20px;
}

.stat-item {
    display: flex;
    align-items: center;
    gap: 5px;
    color: #333;
    font-size: 14px;
    cursor: pointer;
    transition: transform 0.2s;
}

.stat-item:hover {
    transform: scale(1.05);
}

.stat-item svg {
    width: 20px;
    height: 20px;
}

.stat-item i {
    font-size: 18px;
}

/* 按讚狀態 */
.like-icon[data-liked="true"] svg path {
    fill: red !important;
    stroke: red;
}

/* 收藏狀態 */
.star-icon[data-collected="true"] svg path {
    fill: #ffd700 !important;
    stroke: #ffa500;
}

/* 留言區 */
.modal-comments-section {
    margin-top: 20px;
}

.modal-comments-section h4 {
    font-size: 16px;
    color: #333;
    margin-bottom: 15px;
    font-weight: 600;
}

.comments-list {
    max-height: 250px;
    overflow-y: auto;
    margin-bottom: 15px;
}

.comment-item {
    background: #f8f9fa;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 10px;
    line-height: 1.5;
}

.comment-author {
    font-weight: 600;
    color: #a89f91;
    margin-right: 8px;
    font-size: 14px;
}

.comment-text {
    color: #333;
    font-size: 14px;
}

/* 留言輸入區 */
.comment-input-section {
    display: flex;
    gap: 10px;
    align-items: flex-end;
}

.comment-input-section textarea {
    flex: 1;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 8px;
    resize: none;
    font-size: 14px;
    font-family: inherit;
    transition: border-color 0.3s;
}

.comment-input-section textarea:focus {
    outline: none;
    border-color: #a89f91;
}

.comment-input-section button {
    background: #a89f91;
    color: #fff;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: background 0.3s;
}

.comment-input-section button:hover {
    background: #8b8d7a;
}

/* 捲軸美化 */
.comments-list::-webkit-scrollbar {
    width: 6px;
}

.comments-list::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

.comments-list::-webkit-scrollbar-thumb {
    background: #a89f91;
    border-radius: 10px;
}

.comments-list::-webkit-scrollbar-thumb:hover {
    background: #8b8d7a;
}

/* 響應式設計 */
@media screen and (max-width: 768px) {
    .modal-card {
        width: 95%;
        max-width: none;
    }

    .modal-image-container img {
        max-height: 400px;
    }

    .modal-stats {
        gap: 15px;
    }

    .posts-grid {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 15px;
    }

    .post-image {
        height: 150px;
    }
}
/* 留言模態框樣式 (跟 myFavorites.jsp 一樣) */
.modal {
    display: none;
    position: fixed;
    z-index: 3000;
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
    max-height: 300px;
    overflow-y: auto;
}

#commentList li {
    padding: 10px;
    border-bottom: 1px solid #ddd;
    margin-bottom: 10px;
    text-align: left;
    line-height: 1.6;
    background: #f8f9fa;
    border-radius: 8px;
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
    box-sizing: border-box;
}

.modal form button {
    padding: 10px 20px;
    background-color: #a89f91;
    color: #fff;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
}

.modal form button:hover {
    background-color: #8f8c7f;
}
    </style>
</head>
<body>
<%
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    Statement smt= con.createStatement();
    String sql = "SELECT * FROM personal_information " +
            "LEFT JOIN position ON personal_information.positionId = position.positionId " +
            "LEFT JOIN gender ON personal_information.gendercode = gender.gendercode " + 
            "WHERE memberId = '" + session.getAttribute("accessId") + "'";
    
    ResultSet rs = smt.executeQuery(sql);
    rs.next();
    
    String name = rs.getString("nickName");
    String position = rs.getString("positionName");
    String gender = rs.getString("gender");
    String birthdate = rs.getString("born");
    if (birthdate != null && birthdate.contains(" ")) {
        birthdate = birthdate.split(" ")[0];
    }
    String email = rs.getString("Email");
    if (email != null) {
        email = email.split("#")[0];
    }
    String researchFields = gender + ", " + birthdate + ", " + email;
    
    // 建立留言資料的 JavaScript
    StringBuilder commentsDataJS = new StringBuilder();
    commentsDataJS.append("var allPostsData = {");
%>

<div class="container">
    <div class="profile-image">
        <img src="<%=rs.getString("pic") %>?t=<%= System.currentTimeMillis() %>" alt="Profile Picture">
    </div>
    <div class="info">
        <h1><%= name %></h1>
        <h3><%= position %></h3>
    </div>

    <div class="form-section">
    <h3>個人資料</h3>
    <div style="padding: 20px; margin-top: 15px;">
        <div style="display: grid; grid-template-columns: 100px 1fr; gap: 15px; align-items: center;">
            <div style="display: grid; grid-template-columns: 100px 1fr; gap: 15px; align-items: center;">
                <div style="font-weight: 600; color: #666;">
                    <i class="fas fa-venus-mars" style="margin-right: 5px; color: #a89f91;"></i> 性別
                </div>
                <div><%= (gender != null && !gender.equals("null")) ? gender : "未設定" %></div>
                
                <% if (birthdate != null && !birthdate.equals("null") && !birthdate.trim().isEmpty()) { %>
                <div style="font-weight: 600; color: #666;">
                    <i class="fas fa-birthday-cake" style="margin-right: 5px; color: #a89f91;"></i> 生日
                </div>
                <div><%= birthdate %></div>
                <% } %>
                
                <% if (email != null && !email.equals("null") && !email.trim().isEmpty()) { %>
                <div style="font-weight: 600; color: #666;">
                    <i class="fas fa-envelope" style="margin-right: 5px; color: #a89f91;"></i> 信箱
                </div>
                <div><%= email %></div>
                <% } %>
                
                <% 
                try {
                    String registerDate = rs.getString("register");
                    if (registerDate != null && !registerDate.equals("null") && registerDate.contains(" ")) {
                        registerDate = registerDate.split(" ")[0];
                    }
                    if (registerDate != null && !registerDate.equals("null") && !registerDate.trim().isEmpty()) { 
                %>
                    <div style="font-weight: 600; color: #666;">
                        <i class="fas fa-calendar-plus" style="margin-right: 5px; color: #a89f91;"></i> 註冊
                    </div>
                    <div><%= registerDate %></div>
                <% 
                    }
                } catch(Exception e) {}
                %>
            </div>
        </div>
    </div>

    <a href="memberEdit1.jsp?memberId=<%=rs.getString("memberId")%>" class="custom-button">個人資料編輯</a>
    <br><br>
    <a class="custom-button" href="my_wardrobe3.jsp">我的衣櫃</a>
    <a class="custom-button" href="Posts.jsp">新增貼文</a>
    <a class="custom-button" href="myFavorites.jsp">我的讚與收藏</a>
</div>

<div class="container" style="margin-top: 30px;">
    <h3 style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-images"></i> 我的貼文
    </h3>
    
    <div class="posts-grid">
    <%
    String currentMemberId = (String) session.getAttribute("accessId");

    String myPostsSql = "SELECT pw.postid, " +
              "       FIRST(pw.memberId) as memberId, " +
              "       FIRST(pw.wearId) as wearId, " +
              "       FIRST(pw.pic) as pic, " +
              "       MAX(pw.[like]) as [like], " +
              "       MAX(pw.collect) as collect, " +
              "       MAX(pw.view) as view, " +
              "       FIRST(pw.tags) as tags " +
              "FROM personal_wear pw " +
              "WHERE pw.memberId = ? " +
              "  AND pw.post_state = True " +
              "  AND (pw.message IS NULL OR pw.message = '') " +
              "GROUP BY pw.postid " +
              "ORDER BY pw.postid DESC";

    PreparedStatement pstmtPosts = con.prepareStatement(myPostsSql);
    pstmtPosts.setString(1, currentMemberId);
    ResultSet rsPosts = pstmtPosts.executeQuery();
    boolean hasPosts = false;
        
        while (rsPosts.next()) {
            hasPosts = true;
            String postid = rsPosts.getString("postid");
            String memberId = rsPosts.getString("memberId");
            String wearId = rsPosts.getString("wearId");
            String pic = rsPosts.getString("pic");
            String tags = rsPosts.getString("tags");
            int likes = rsPosts.getInt("like");
            int collects = rsPosts.getInt("collect");
            int views = rsPosts.getInt("view");
            
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
            
            // 查詢留言數
            String messageQuery = "SELECT COUNT(*) AS message_count FROM personal_wear WHERE postid = ? AND message IS NOT NULL AND TRIM(message) != ''";
            PreparedStatement pstmtMsg = con.prepareStatement(messageQuery);
            pstmtMsg.setString(1, postid);
            ResultSet rsMsg = pstmtMsg.executeQuery();
            int messageCount = 0;
            if (rsMsg.next()) {
                messageCount = rsMsg.getInt("message_count");
            }
            rsMsg.close();
            pstmtMsg.close();
            
            // 查詢留言
            String commentQuery = "SELECT message, memberId FROM personal_wear WHERE postid = ? AND message IS NOT NULL AND TRIM(message) != '' ORDER BY recordid ASC";
            PreparedStatement pstmtComment = con.prepareStatement(commentQuery);
            pstmtComment.setString(1, postid);
            ResultSet rsComment = pstmtComment.executeQuery();
            
            commentsDataJS.append("'").append(postid).append("': {");
            commentsDataJS.append("memberId:'").append(memberId != null ? memberId : "").append("',");
            commentsDataJS.append("wearId:'").append(wearId != null ? wearId : "").append("',");
            commentsDataJS.append("pic:'").append(pic != null ? pic : "").append("',");
            commentsDataJS.append("tags:'").append(tags != null ? tags : "").append("',");
            commentsDataJS.append("likes:").append(likes).append(",");
            commentsDataJS.append("collects:").append(collects).append(",");
            commentsDataJS.append("views:").append(views).append(",");
            commentsDataJS.append("messageCount:").append(messageCount).append(",");
            commentsDataJS.append("isLiked:").append(isLiked).append(",");
            commentsDataJS.append("isCollected:").append(isCollected).append(",");
            commentsDataJS.append("comments:[");
            
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
            commentsDataJS.append("]},");
            rsComment.close();
            pstmtComment.close();
    %>
        <div class="post-card" data-postid="<%= postid %>" onclick="openPostModal('<%= postid %>')">
            <div style="position: relative;">
                <button onclick="deletePost(event, '<%= postid %>')" 
                        style="position: absolute; top: 10px; right: 10px; 
                               background: rgba(255, 0, 0, 0.8); color: white; 
                               border: none; border-radius: 50%; width: 35px; height: 35px; 
                               cursor: pointer; z-index: 10; display: flex; align-items: center; 
                               justify-content: center; font-size: 16px; box-shadow: 0 2px 5px rgba(0,0,0,0.3);">
                    <i class="fas fa-trash"></i>
                </button>
                
                <img src="<%= pic %>" alt="Post Image" class="post-image" onerror="this.src='images/default.jpg'">
            </div>
            
            <div class="post-content-mini">
                <div class="post-theme-mini"><%= wearId != null ? wearId : "無主題" %></div>
                <div class="tags-container-mini">
                    <% if (tags != null && !tags.trim().isEmpty()) { 
                        String[] tagArray = tags.split(",");
                        for (String tag : tagArray) {
                            if(tag != null && !tag.trim().isEmpty()) {
                    %>
                        <span class="post-tag-mini">#<%= tag.trim() %></span>
                    <% 
                            }
                        }
                    } %>
                </div>
                <div class="post-stats-mini">
                    <span><i class="fas fa-heart"></i> <%= likes %></span>
                    <span><i class="far fa-comment"></i> <%= messageCount %></span>
                    <span><i class="fas fa-star"></i> <%= collects %></span>
                    <span><i class="fas fa-eye"></i> <%= views %></span>
                </div>
            </div>
        </div>
    <%
        }
        
        if (!hasPosts) {
    %>
        <div class="empty-message-mini">
            <i class="fas fa-image"></i>
            <p>您還沒有發布任何貼文</p>
        </div>
    <%
        }
        
        commentsDataJS.append("};");
        rsPosts.close();
        pstmtPosts.close();
    %>
    </div>
</div>

<!-- ✅ 彈出視窗 (放大卡片版) -->
<div class="post-modal" id="postModal">
    <span class="modal-close" onclick="closePostModal()">&times;</span>
    <div class="modal-card">
        <!-- 圖片區 (無黑邊) -->
        <div class="modal-image-container">
            <img id="modalImage" src="" alt="Post Image">
            <!-- 右上角按鈕 -->
            <div class="modal-top-buttons">
                <button class="modal-action-btn edit-btn" onclick="editPostFromModal(event)" title="編輯">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="modal-action-btn delete-btn" onclick="deletePostFromModal(event)" title="刪除">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        </div>
        
        <!-- 內容區 -->
        <div class="modal-card-content">
            <!-- 作者 -->
            <div class="modal-author-section">
                <strong id="modalAuthor"></strong>
            </div>
            
            <!-- 主題 -->
            <div class="modal-theme-section">
                <span id="modalTheme"></span>
            </div>
            
            <!-- 標籤 -->
            <div class="modal-tags-section" id="modalTags"></div>
            
            <!-- 統計數據 -->
            <div class="modal-stats">
                <span class="stat-item like-icon" onclick="toggleModalLike(event)" id="modalLikeBtn" data-liked="false">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"></path>
                    </svg>
                    <span class="stat-count" id="modalLikeCount">0</span>
                </span>
                
                <span class="stat-item comment-icon" onclick="openModalComment(event)">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M21 11.5a8.5 8.5 0 1 0-13.971 6.607l-3.75 3.75a1 1 0 0 0-.23 1.082A1 1 0 0 0 4 21h4.582a8.5 8.5 0 0 0 12.418-9.5z"></path>
                    </svg>
                    <span class="stat-count" id="modalCommentCount">0</span>
                </span>
                
                <span class="stat-item star-icon" onclick="toggleModalCollect(event)" id="modalCollectBtn" data-collected="false">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                        <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"></path>
                    </svg>
                    <span class="stat-count" id="modalCollectCount">0</span>
                </span>
                
                <span class="stat-item">
                    <i class="fas fa-eye"></i>
                    <span class="stat-count" id="modalViewCount">0</span>
                </span>
            </div>
        </div>
    </div>
</div>

<!-- ✅ 留言模態框 (跟 myFavorites.jsp 一樣) -->
<div class="modal" id="commentModal" style="display: none;">
    <div class="modal-content">
        <span class="close" onclick="closeCommentModal()">&times;</span>
        
        <!-- 顯示留言區域 -->
        <div id="commentDisplay" class="comment-display">
            <h3>留言內容:</h3>
            <ul id="commentList">
                <!-- 留言會動態載入到這裡 -->
            </ul>
        </div>

        <!-- 輸入留言 -->
        <form name="form" action="update.jsp" method="post">                          
            <textarea name="text" id="commentText" placeholder="請輸入您的留言..." rows="5"></textarea>
            <input type="hidden" name="memberId" value="<%= session.getAttribute("accessId") %>">
            <input type="hidden" name="postid" id="hiddenPostid" value="">
            <button type="submit" name="submitButton">提交留言</button>
        </form>
    </div>
</div>
        
<script>
// 載入貼文資料
<%= commentsDataJS.toString() %>

let currentPostId = null;
const currentMemberId = '<%= session.getAttribute("accessId") %>';

//開啟貼文彈窗
function openPostModal(postid) {
    event.stopPropagation();
    
    currentPostId = postid;
    const postData = allPostsData[postid];
    
    if (!postData) {
        alert('無法載入貼文資料');
        return;
    }
    
    // 設定圖片
    document.getElementById('modalImage').src = postData.pic;
    
    // 設定作者和主題
    document.getElementById('modalAuthor').textContent = postData.memberId || '匿名用戶';
    document.getElementById('modalTheme').textContent = postData.wearId || '無主題';
    
    // 設定標籤
    const tagsContainer = document.getElementById('modalTags');
    tagsContainer.innerHTML = '';
    if (postData.tags && postData.tags.trim() !== '') {
        const tagArray = postData.tags.split(',');
        tagArray.forEach(tag => {
            if (tag.trim() !== '') {
                const tagSpan = document.createElement('span');
                tagSpan.className = 'modal-tag';
                tagSpan.textContent = '#' + tag.trim();
                tagsContainer.appendChild(tagSpan);
            }
        });
    }
    
    // 設定統計數據
    document.getElementById('modalLikeCount').textContent = postData.likes;
    document.getElementById('modalCommentCount').textContent = postData.messageCount;
    document.getElementById('modalCollectCount').textContent = postData.collects;
    document.getElementById('modalViewCount').textContent = postData.views;
    
    // 設定按讚狀態
    const likeBtn = document.getElementById('modalLikeBtn');
    const likePath = likeBtn.querySelector('svg path');
    if (postData.isLiked) {
        likeBtn.setAttribute('data-liked', 'true');
        likePath.style.fill = 'red';
        likePath.style.stroke = 'red';
    } else {
        likeBtn.setAttribute('data-liked', 'false');
        likePath.style.fill = 'none';
        likePath.style.stroke = 'currentColor';
    }
    
    // 設定收藏狀態
    const collectBtn = document.getElementById('modalCollectBtn');
    const collectPath = collectBtn.querySelector('svg path');
    if (postData.isCollected) {
        collectBtn.setAttribute('data-collected', 'true');
        collectPath.style.fill = 'yellow';
        collectPath.style.stroke = '#333';
    } else {
        collectBtn.setAttribute('data-collected', 'false');
        collectPath.style.fill = 'none';
        collectPath.style.stroke = 'currentColor';
    }
    
    // 顯示彈出視窗
    document.getElementById('postModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
}



// 編輯貼文
function editPostFromModal(event) {
    event.stopPropagation();
    
    if (!currentPostId) return;
    
    // 跳轉到編輯頁面 (請根據你的實際編輯頁面路徑修改)
    window.location.href = 'editPost.jsp?postid=' + currentPostId;
}

// 關閉貼文彈窗
function closePostModal() {
    document.getElementById('postModal').style.display = 'none';
    document.body.style.overflow = 'auto';
    currentPostId = null;
}


//開啟留言模態框 (跟 myFavorites.jsp 一樣)
function openModalComment(event) {
    event.stopPropagation();
    
    if (!currentPostId) return;
    
    const postData = allPostsData[currentPostId];
    
    document.getElementById('hiddenPostid').value = currentPostId;
    
    const commentList = document.getElementById('commentList');
    commentList.innerHTML = '';
    
    if (postData.comments && postData.comments.length > 0) {
        postData.comments.forEach(function(comment) {
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
    document.getElementById('commentText').value = '';
}


// 按讚功能
function toggleModalLike(event) {
    event.stopPropagation();
    if (!currentPostId) return;
    
    const likeBtn = document.getElementById('modalLikeBtn');
    const isLiked = likeBtn.getAttribute('data-liked') === 'true';
    const action = isLiked ? 'remove' : 'add';
    
    fetch('updateLike.jsp?postid=' + currentPostId + '&memberId=' + currentMemberId + '&action=' + action)
        .then(response => response.text())
        .then(data => {
            const newCount = data.trim();
            if (newCount !== 'error' && !isNaN(newCount)) {
                const likePath = likeBtn.querySelector('svg path');
                likeBtn.setAttribute('data-liked', !isLiked);
                likePath.style.fill = isLiked ? 'none' : 'red';
                likePath.style.stroke = isLiked ? 'currentColor' : 'red';
                document.getElementById('modalLikeCount').textContent = newCount;
                
                // 更新小卡片的按讚數
                const postCard = document.querySelector(`.post-card[data-postid="${currentPostId}"]`);
                if (postCard) {
                    const likeSpan = postCard.querySelector('.post-stats-mini span:first-child');
                    if (likeSpan) {
                        likeSpan.innerHTML = `<i class="fas fa-heart"></i> ${newCount}`;
                    }
                }
                
                // 更新記憶體資料
                allPostsData[currentPostId].likes = parseInt(newCount);
                allPostsData[currentPostId].isLiked = !isLiked;
            } else {
                alert('操作失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
        });
}

//收藏功能
function toggleModalCollect(event) {
    event.stopPropagation();
    if (!currentPostId) return;
    
    const collectBtn = document.getElementById('modalCollectBtn');
    const isCollected = collectBtn.getAttribute('data-collected') === 'true';
    const action = isCollected ? 'remove' : 'add';
    
    fetch('updateCollect.jsp?postid=' + currentPostId + '&memberId=' + currentMemberId + '&action=' + action)
        .then(response => response.text())
        .then(data => {
            const newCount = data.trim();
            if (newCount !== 'error' && !isNaN(newCount)) {
                const collectPath = collectBtn.querySelector('svg path');
                collectBtn.setAttribute('data-collected', !isCollected);
                collectPath.style.fill = isCollected ? 'none' : 'yellow';
                document.getElementById('modalCollectCount').textContent = newCount;
                
                // 更新小卡片的收藏數
                const postCard = document.querySelector(`.post-card[data-postid="${currentPostId}"]`);
                if (postCard) {
                    const collectSpan = postCard.querySelector('.post-stats-mini span:nth-child(3)');
                    if (collectSpan) {
                        collectSpan.innerHTML = `<i class="fas fa-star"></i> ${newCount}`;
                    }
                }
                
                // 更新記憶體資料
                allPostsData[currentPostId].collects = parseInt(newCount);
                allPostsData[currentPostId].isCollected = !isCollected;
            } else {
                alert('操作失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
        });
}


//從彈窗刪除貼文
function deletePostFromModal(event) {
    event.stopPropagation();
    
    if (!currentPostId) return;
    
    if (!confirm('確定要刪除這篇貼文嗎?刪除後將無法恢復!')) {
        return;
    }
    
    fetch('deletePost.jsp?postid=' + currentPostId)
        .then(response => response.text())
        .then(data => {
            if (data.trim() === 'success') {
                alert('貼文已成功刪除!');
                
                // ✅ 關閉彈窗並重新載入頁面
                closePostModal();
                location.reload();
            } else {
                alert('刪除失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
        });
}

//從小卡片刪除貼文
function deletePost(event, postid) {
    event.stopPropagation();
    
    if (!confirm('確定要刪除這篇貼文嗎?刪除後將無法恢復!')) {
        return;
    }
    
    fetch('deletePost.jsp?postid=' + postid)
        .then(response => response.text())
        .then(data => {
            if (data.trim() === 'success') {
                alert('貼文已成功刪除!');
                
                // ✅ 重新載入頁面
                location.reload();
            } else {
                alert('刪除失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
        });
}

// 點擊彈窗外部關閉
window.onclick = function(event) {
    const modal = document.getElementById('postModal');
    if (event.target == modal) {
        closePostModal();
    }
}

// ESC 鍵關閉彈窗
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closePostModal();
    }
});
</script>

</body>
</html>