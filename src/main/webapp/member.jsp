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

        /* 头像 */
        .profile-image {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }

        .profile-image img {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            border: 3px solid #a89f91; /* 修改為 #a89f91 */
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

        /* 下拉選單 */
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

        /* 響應式設計 */
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

    /* ✅ 我的貼文區塊樣式 */
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
}

.post-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

.post-image {
    width: 100%;
    height: 200px;
    object-fit: cover;
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

@media screen and (max-width: 600px) {
    .posts-grid {
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 15px;
    }

    .post-image {
        height: 150px;
    }
}

    </style>
</head>
<body>
<%
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	//out.println("Con= "+con);
	Statement smt= con.createStatement();
	String sql = "SELECT * FROM personal_information " +
            "LEFT JOIN position ON personal_information.positionId = position.positionId " +
            "LEFT JOIN gender ON personal_information.gendercode = gender.gendercode " + 
            "WHERE memberId = '" + session.getAttribute("accessId") + "'";
	
	ResultSet rs = smt.executeQuery(sql);
	rs.next();
	%>
    <div class="container">
         <%
        // 假設資料庫查詢結果
        String name = rs.getString("nickName");
        String position = rs.getString("positionName");

        // 新增從資料庫提取的 researchFields 資訊
        String gender = rs.getString("gender");  // 假設資料庫中有 gender 欄位
        String birthdate = rs.getString("born");
        if (birthdate != null && birthdate.contains(" ")) {
            birthdate = birthdate.split(" ")[0]; // 只保留日期部分
        }

        String email = rs.getString("Email");
        if (email != null) {
            // 移除多餘的部分
            email = email.split("#")[0];
        }


        // 拼接 researchFields
        String researchFields = gender + ", " + birthdate + ", " + email;
    %>
    


        <!-- Profile Section -->
        <div class="profile-image">
            <img src="<%=rs.getString("pic") %>?t=<%= System.currentTimeMillis() %>" alt="Profile Picture"> <!-- 替換成實際圖片路徑 -->
        </div>
        <div class="info">
        <h1><%= name %></h1> <!-- 顯示 Nickname -->
        <h3><%= position %></h3>
    </div>

        <!-- Research Fields Section -->
        <div class="form-section">
            <h3>個人資料：</h3>
            <ul>
                <% for (String field : researchFields.split(",")) { %>
                    <li><%= field.trim() %></li>
                <% } %>
            </ul>
        </div>
      
<form name="form" action="memberEdit_DBUpdate_pic.jsp" method="post" enctype="multipart/form-data">
    <input type="file" name="theFirstFile" accept="image/*">
     <input type="hidden" name="memberId" value="<%=rs.getString("memberId")%> " />
  <button type="submit" value="上傳圖片" name="submitButton" style="background-color: #a89f91; color: #fff; border: none; padding: 10px 30px; border-radius: 5px; cursor: pointer;">
修改圖片
</button>
</form>

<a href="memberEdit1.jsp?memberId=<%=rs.getString("memberId")%>"  class="custom-button">編輯</a>
<br><br>
<a class="custom-button" href="my_wardrobe3.jsp">我的衣櫃</a>
<a class="custom-button" href="Posts.jsp">新增貼文</a>
<a class="custom-button" href="myFavorites.jsp">我的讚與收藏</a>

</div>

<!-- ✅ 新增:我的貼文區塊 -->
<div class="container" style="margin-top: 30px;">
    <h3 style="text-align: center; margin-bottom: 20px;">
        <i class="fas fa-images"></i> 我的貼文
    </h3>
    
    <div class="posts-grid">
    <%
        // 查詢當前會員的所有貼文
        String myPostsSql = "SELECT pw.postid, " +
                  "       FIRST(pw.memberId) as memberId, " +
                  "       FIRST(pw.wearId) as wearId, " +
                  "       FIRST(pw.pic) as pic, " +
                  "       MAX(pw.[like]) as [like], " +
                  "       MAX(pw.collect) as collect, " +
                  "       MAX(pw.view) as view, " +
                  "       FIRST(pw.tags) as tags " +
                  "FROM personal_wear pw " +
                  "WHERE pw.memberId = '" + session.getAttribute("accessId") + "' AND pw.post_state = True " +
                  "GROUP BY pw.postid " +
                  "ORDER BY pw.postid DESC";
        
        Statement smtPosts = con.createStatement();
        ResultSet rsPosts = smtPosts.executeQuery(myPostsSql);
        boolean hasPosts = false;
        
        while (rsPosts.next()) {
            hasPosts = true;
            String postid = rsPosts.getString("postid");
            String wearId = rsPosts.getString("wearId");
            String pic = rsPosts.getString("pic");
            String tags = rsPosts.getString("tags");
            int likes = rsPosts.getInt("like");
            int collects = rsPosts.getInt("collect");
            int views = rsPosts.getInt("view");
            
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
    %>
        <div class="post-card" data-postid="<%= postid %>">
            <div style="position: relative;">
                <button onclick="deletePost(event, '<%= postid %>')" 
                        style="position: absolute; top: 10px; right: 10px; 
                               background: rgba(255, 0, 0, 0.8); color: white; 
                               border: none; border-radius: 50%; width: 35px; height: 35px; 
                               cursor: pointer; z-index: 10; display: flex; align-items: center; 
                               justify-content: center; font-size: 16px; box-shadow: 0 2px 5px rgba(0,0,0,0.3);">
                    <i class="fas fa-trash"></i>
                </button>
                
                <img src="<%= pic %>" alt="Post Image" class="post-image" 
                     onerror="this.src='images/default.jpg'"
                     onclick="location.href='index1.jsp?postid=<%= postid %>#post-<%= postid %>'" 
                     style="cursor: pointer;">
            </div>
            
            <div class="post-content-mini" onclick="location.href='index1.jsp?postid=<%= postid %>#post-<%= postid %>'" style="cursor: pointer;">
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
        
        rsPosts.close();
        smtPosts.close();
    %>
    </div>
</div>

<script>
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
                const postCard = document.querySelector('[data-postid="' + postid + '"]');
                if (postCard) {
                    postCard.style.transition = 'opacity 0.3s';
                    postCard.style.opacity = '0';
                    setTimeout(() => {
                        postCard.remove();
                        
                        const remainingPosts = document.querySelectorAll('.post-card').length;
                        if (remainingPosts === 0) {
                            const postsGrid = document.querySelector('.posts-grid');
                            postsGrid.innerHTML = `
                                <div class="empty-message-mini">
                                    <i class="fas fa-image"></i>
                                    <p>您還沒有發布任何貼文</p>
                                </div>
                            `;
                        }
                    }, 300);
                }
            } else {
                alert('刪除失敗,請稍後再試!');
            }
        })
        .catch(error => {
            console.error('錯誤:', error);
            alert('系統錯誤,請稍後再試!');
        });
}
</script>

</body>
</html>
