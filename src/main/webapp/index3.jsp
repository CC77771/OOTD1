<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file ="menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<%	
Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
Statement smt= con.createStatement();
String sql = "SELECT postid, " +
        "       FIRST(memberId) as memberId, " +
        "       FIRST(wearId) as wearId, " +
        "       FIRST(pic) as pic, " +
        "       MAX([like]) as [like], " +
        "       MAX(collect) as collect, " +
        "       MAX(view) as view, " +
        "       FIRST(tags) as tags " +
        "FROM personal_wear " +
        "WHERE post_state = True " +
        "GROUP BY postid " +
        "ORDER BY postid DESC";
ResultSet rs = smt.executeQuery(sql);
//====== 新增：查詢已上架的穿搭組合 ======
String styleSql = "SELECT commodity_title, pic " +
               "FROM commodity_information " +
               "WHERE authorization = True " +
               "GROUP BY commodity_title, pic " +
               "ORDER BY MAX(commodity_code) DESC";
Statement styleStmt = con.createStatement();
ResultSet styleRs = styleStmt.executeQuery(styleSql);

//儲存穿搭組合資料
java.util.ArrayList<java.util.HashMap<String, String>> styleList = new java.util.ArrayList<>();
while(styleRs.next()) {
 java.util.HashMap<String, String> style = new java.util.HashMap<>();
 style.put("title", styleRs.getString("commodity_title"));
 style.put("pic", styleRs.getString("pic"));
 
//查詢該穿搭組合的所有商品標籤
String tagSql = "SELECT commodity_name, price, tag_x, tag_y, website, commodity_code FROM commodity_information " +
              "WHERE commodity_title = ? AND pic = ? AND authorization = True";
PreparedStatement tagPstmt = con.prepareStatement(tagSql);
tagPstmt.setString(1, styleRs.getString("commodity_title"));
tagPstmt.setString(2, styleRs.getString("pic"));
ResultSet tagRs = tagPstmt.executeQuery();

StringBuilder tags = new StringBuilder();
int tagCount = 0;
while(tagRs.next()) {
  if(tagCount > 0) tags.append("|");
  tags.append(tagRs.getString("commodity_name")).append(",")
      .append(tagRs.getString("price")).append(",")
      .append(tagRs.getDouble("tag_x")).append(",")
      .append(tagRs.getDouble("tag_y")).append(",")
      .append(tagRs.getString("website") != null ? tagRs.getString("website") : "").append(",")
      .append(tagRs.getString("commodity_code"));
  tagCount++;
}
 style.put("tags", tags.toString());
 style.put("tagCount", String.valueOf(tagCount));
 
 tagRs.close();
 tagPstmt.close();
 
 styleList.add(style);
}
styleRs.close();
styleStmt.close();
%>	
	<%
    String member = (String) session.getAttribute("accessId");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="BIG5">
<title>CZ_OOTD</title>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="format-detection" content="telephone=no">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="author" content="TemplatesJungle">
  <meta name="keywords" content="ecommerce,fashion,store">
  <meta name="description" content="Bootstrap 5 Fashion Store HTML CSS Template">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet"
    integrity="sha384-KK94CHFLLe+nY2dmCWGMq91rCGa5gtU4mk92HdvYe+M/SXH301p5ILy+dN9+nJOZ" crossorigin="anonymous">
  <link rel="stylesheet" type="text/css" href="css/vendor.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.css" />
  <link rel="stylesheet" type="text/css" href="style.css">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link
    href="https://fonts.googleapis.com/css2?family=Jost:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Marcellus&display=swap"
    rel="stylesheet">
    <style>
        /* Fixed button style */
        .back-to-top {
            position: fixed;
            bottom: 40px;  /* Distance from the bottom */
            right: 40px;   /* Distance from the right */
            background-color: #a89f91;  /* Button color */
            color: white;
            border: none;
            padding: 8px;  /* Smaller padding */
            border-radius: 50%;  /* Circular button */
            cursor: pointer;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
            transition: background-color 0.3s ease, transform 0.3s ease;
            width: 60px;  /* Set width */
            height: 60px;  /* Set height */
        }

        .back-to-top:hover {
            background-color: #555; /* Hover effect */
            transform: scale(1.1);   /* Slightly enlarge on hover */
        }

        .back-to-top svg {
            width: 24px;  /* Smaller icon size */
            height: 24px; /* Smaller icon size */
            fill: white; /* Arrow icon color */
        }

        /* Example content */
        .content-section {
            min-height: 100vh;  /* Ensures the section takes at least the full viewport height */
            padding: 20px;
            background-color: lightgray;
        }
    </style> 
    <style>
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(8px);
    display: none;
    align-items: center;
    justify-content: center;
    z-index: -1;  /* ✅ 初始設為 -1，不干擾其他元素 */
    animation: fadeIn 0.5s ease;
    pointer-events: none;  /* ✅ 初始設為 none，不接收點擊 */
}

.modal-overlay[style*="display: none"] {
    pointer-events: none !important;  /* ✅ 新增這段 */
    z-index: -1 !important;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.modal-card {
    background: linear-gradient(165deg, #ffffff 0%, #f8f5f0 50%, #f0ebe5 100%);
    border-radius: 25px;
    max-width: 650px;
    width: 92%;
    padding: 60px 50px;
    position: relative;
    box-shadow: 0 25px 80px rgba(168, 159, 145, 0.35), 0 0 0 1px rgba(255, 255, 255, 0.8) inset;
    animation: slideScale 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
    overflow: hidden;
    font-family: 'Noto Serif TC', serif;
}

@keyframes slideScale {
    from {
        transform: translateY(40px) scale(0.9);
        opacity: 0;
    }
    to {
        transform: translateY(0) scale(1);
        opacity: 1;
    }
}

.modal-card::before {
    content: '';
    position: absolute;
    top: -100px;
    right: -100px;
    width: 300px;
    height: 300px;
    background: radial-gradient(circle, rgba(168, 159, 145, 0.15) 0%, transparent 60%);
    border-radius: 50%;
    animation: float 6s ease-in-out infinite;
}

.modal-card::after {
    content: '';
    position: absolute;
    bottom: -80px;
    left: -80px;
    width: 250px;
    height: 250px;
    background: radial-gradient(circle, rgba(168, 159, 145, 0.12) 0%, transparent 60%);
    border-radius: 50%;
    animation: float 7s ease-in-out infinite reverse;
}

@keyframes float {
    0%, 100% {
        transform: translate(0, 0) scale(1);
    }
    50% {
        transform: translate(20px, 20px) scale(1.1);
    }
}

.close-btn {
    position: absolute;
    top: 25px;
    right: 25px;
    width: 40px;
    height: 40px;
    border: 2px solid rgba(168, 159, 145, 0.2);
    background: rgba(255, 255, 255, 0.8);
    color: #a89f91;
    border-radius: 50%;
    cursor: pointer;
    font-size: 22px;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10;
    font-weight: 300;
}

.close-btn:hover {
    background: #a89f91;
    color: white;
    border-color: #a89f91;
    transform: rotate(90deg) scale(1.1);
}

.modal-content {
    text-align: center;
    position: relative;
    z-index: 5;
}

.top-decoration {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 15px;
    margin-bottom: 35px;
}

.deco-line {
    width: 80px;
    height: 1px;
    background: linear-gradient(to right, transparent, #a89f91, transparent);
}

.deco-dot {
    width: 8px;
    height: 8px;
    background: #a89f91;
    border-radius: 50%;
    animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% {
        opacity: 0.4;
        transform: scale(1);
    }
    50% {
        opacity: 1;
        transform: scale(1.3);
    }
}

.modal-title {
    font-size: 32px;
    color: #4a4239;
    margin-bottom: 40px;
    font-weight: 500;
    letter-spacing: 8px;
    position: relative;
    display: inline-block;
}

.modal-title::after {
    content: '';
    position: absolute;
    bottom: -12px;
    left: 50%;
    transform: translateX(-50%);
    width: 50px;
    height: 2px;
    background: #a89f91;
}

.quote-text {
    font-size: 18px;
    line-height: 2.2;
    color: #6a6158;
    margin-bottom: 20px;
    font-weight: 300;
    letter-spacing: 1.5px;
    padding: 0 20px;
}

.quote-text:last-of-type {
    margin-bottom: 45px;
}

.highlight {
    color: #a89f91;
    font-weight: 500;
}

.start-btn {
    background: linear-gradient(135deg, #a89f91 0%, #9b8e82 100%);
    color: white;
    border: none;
    padding: 16px 55px;
    font-size: 17px;
    border-radius: 35px;
    cursor: pointer;
    transition: all 0.4s ease;
    font-family: 'Noto Serif TC', serif;
    letter-spacing: 3px;
    font-weight: 400;
    box-shadow: 0 8px 25px rgba(168, 159, 145, 0.35);
    position: relative;
    overflow: hidden;
}

.start-btn::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 0;
    height: 0;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.2);
    transform: translate(-50%, -50%);
    transition: width 0.6s, height 0.6s;
}

.start-btn:hover::before {
    width: 300px;
    height: 300px;
}

.start-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 12px 35px rgba(168, 159, 145, 0.45);
}

.start-btn span {
    position: relative;
    z-index: 1;
}

.bottom-decoration {
    margin-top: 35px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.ornament {
    width: 25px;
    height: 1px;
    background: #a89f91;
    opacity: 0.4;
}

.ornament-circle {
    width: 5px;
    height: 5px;
    background: #a89f91;
    border-radius: 50%;
    opacity: 0.4;
    animation: twinkle 2s ease-in-out infinite;
}

.ornament-circle:nth-child(2) {
    animation-delay: 0.4s;
}

.ornament-circle:nth-child(4) {
    animation-delay: 0.8s;
}

@keyframes twinkle {
    0%, 100% { opacity: 0.2; }
    50% { opacity: 0.8; }
}

@keyframes fadeOut {
    from { opacity: 1; }
    to { opacity: 0; }
}
</style>  

<style>
/* ===== 強制移除所有搜尋相關的動畫 ===== */
header *,
.navbar *,
.action-menu *,
.search-box *,
header a,
header button,
header svg,
header img,
.search-popup *,
button[data-bs-toggle],
button[data-bs-toggle] * {
    transform: none !important;
    transition: none !important;
    animation: none !important;
    -webkit-transform: none !important;
    -webkit-transition: none !important;
    -webkit-animation: none !important;
}

/* ✅ 針對搜尋圖示移除所有動畫效果 */
.simple-search-icon,
.simple-search-icon:hover,
.simple-search-icon svg,
.simple-search-icon:hover svg {
    transform: none !important;
    transition: none !important;
    animation: none !important;
    -webkit-transform: none !important;
    -webkit-transition: none !important;
    -webkit-animation: none !important;
}

/* 確保搜尋圖示和導航列元素不受影響 */
header .action-menu svg,
header .search-box svg,
header button svg {
    transform: scale(1) !important;
}

/* 移除 hover 效果的動畫 */
header a:hover,
header button:hover,
header svg:hover {
    transform: none !important;
    transition: none !important;
}
</style>

</head>
<body class="homepage">
<button id="backToTop" class="back-to-top" onclick="scrollToTop()">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 4l-8 8h5v8h6v-8h5z" />
    </svg>
</button>
<script>
    // Scroll back to the top of the page
    function scrollToTop() {
        window.scrollTo({
            top: 0, 
            behavior: 'smooth'  // Smooth scrolling
        });
    }
</script>
<section id="billboard" class="bg-light py-5">
    <section class="slide" id="Posts">
        <div class="container">
            <div class="row justify-content-center">
                <h1 class="section-title text-center mt-4" data-aos="fade-up">New Posts</h1>
            </div>
            <div class="row">
                <div class="swiper main-swiper py-4" data-aos="fade-up" data-aos-delay="600">
                    <div class="swiper-wrapper d-flex border-animation-left">
                        <% 
int num=1;
StringBuilder commentsDataJS = new StringBuilder();
commentsDataJS.append("var allComments = {");

while(rs.next()){ 
    String postid = rs.getString("postid");
    int viewCount = rs.getInt("view");
    
 // ✅ 新增：查詢當前會員是否已按讚
    boolean isLiked = false;
    String checkLikeSql = "SELECT COUNT(*) as cnt FROM user_likes WHERE memberId = ? AND postid = ?";
    PreparedStatement pstmtLike = con.prepareStatement(checkLikeSql);
    pstmtLike.setString(1, member);
    pstmtLike.setInt(2, Integer.parseInt(postid));
    ResultSet rsLike = pstmtLike.executeQuery();
    if(rsLike.next() && rsLike.getInt("cnt") > 0) {
        isLiked = true;
    }
    rsLike.close();
    pstmtLike.close();
    
    // ✅ 新增：查詢當前會員是否已收藏
    boolean isCollected = false;
    String checkCollectSql = "SELECT COUNT(*) as cnt FROM user_collects WHERE memberId = ? AND postid = ?";
    PreparedStatement pstmtCollect = con.prepareStatement(checkCollectSql);
    pstmtCollect.setString(1, member);
    pstmtCollect.setInt(2, Integer.parseInt(postid));
    ResultSet rsCollect = pstmtCollect.executeQuery();
    if(rsCollect.next() && rsCollect.getInt("cnt") > 0) {
        isCollected = true;
    }
    rsCollect.close();
    pstmtCollect.close();
    
  
    // 查詢該貼文的所有留言（包含留言者帳號）
String commentQuery = "SELECT message, memberId FROM personal_wear WHERE postid = ? AND message IS NOT NULL AND TRIM(message) != '' ORDER BY recordid ASC";
    PreparedStatement pstmtComment = con.prepareStatement(commentQuery);
    pstmtComment.setInt(1, Integer.parseInt(postid));
    ResultSet rsComment = pstmtComment.executeQuery();
    
    // 建立該貼文的留言陣列
    commentsDataJS.append("'").append(postid).append("': [");
    boolean hasComment = false;
    while(rsComment.next()) {
        if(hasComment) commentsDataJS.append(",");
        String message = rsComment.getString("message");
        String commentMemberId = rsComment.getString("memberId");
        message = message.replace("'", "\\'").replace("\n", "\\n").replace("\r", "");
        commentMemberId = commentMemberId.replace("'", "\\'");
        // 格式改為：{member:'帳號', message:'留言內容'}
        commentsDataJS.append("{member:'").append(commentMemberId).append("',message:'").append(message).append("'}");
        hasComment = true;
    }
    commentsDataJS.append("],");
    
    rsComment.close();
    pstmtComment.close();
%>
    <!-- 帖子 -->
    <div class="swiper-slide" data-postid="<%= postid %>">
        <div class="post-item">
            <div class="image-holder">
                <a href="#">
                    <img src="<%= rs.getString("pic")%>?t=<%= System.currentTimeMillis() %>" 
                         alt="product" 
                         class="img-fluid" 
                         style="width: 600px; height: 500px;">
                </a>
            </div>
            <div class="post-content py-4">
    <p class="post-description"><%=rs.getString("memberId") %> <%=rs.getString("wearId") %></p>
    
    <!-- ✅ 新增標籤顯示 -->
    <%
    String tags = rs.getString("tags");
    if(tags != null && !tags.trim().isEmpty()) {
        String[] tagArray = tags.split(",");
    %>
    <div class="post-tags" style="margin: 10px 0;">
        <%
        for(String tag : tagArray) {
            if(tag != null && !tag.trim().isEmpty()) {
        %>
        <span class="post-tag">#<%= tag.trim() %></span>
        <%
            }
        }
        %>
    </div>
    <%
    }
    %>
    
    <div class="post-actions">
                    <div class="action-icons">
                        <a href="#" class="action-icon like-icon" onclick="toggleLike(this)" data-liked="<%= isLiked %>">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="feather feather-heart">
        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"></path>
    </svg>
</a>
                        <a href="#" class="action-icon comment-icon" onclick="toggleComment(this)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="feather feather-message-circle">
                                <path d="M21 11.5a8.5 8.5 0 1 0-13.971 6.607l-3.75 3.75a1 1 0 0 0-.23 1.082A1 1 0 0 0 4 21h4.582a8.5 8.5 0 0 0 12.418-9.5z"></path>
                            </svg>
                        </a>
                        <a href="#" class="action-icon star-icon" onclick="toggleStar(this)" data-collected="<%= isCollected %>">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="feather feather-star">
        <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"></path>
    </svg>
</a>
                    </div>
                    <div class="action-text">
                        <span class="likes-count"><%=rs.getInt("like") %></span>&nbsp;                                                  
                        <span class="comments-count">
                        <% 
                            String messageQuery = "SELECT COUNT(*) AS message_count FROM personal_wear WHERE postid = ? AND message IS NOT NULL AND TRIM(message) != ''";
                            PreparedStatement pstmt2 = con.prepareStatement(messageQuery);
                            pstmt2.setString(1, postid);
                            ResultSet messageRs = pstmt2.executeQuery();
                            if (messageRs.next()) {
                                int messageCount = messageRs.getInt("message_count");
                                out.println(messageCount);
                            }
                            if (messageRs != null) messageRs.close();
                            if (pstmt2 != null) pstmt2.close();
                        %>
                        </span>                                            
                        &nbsp;&nbsp;&nbsp;<span class="stars-count"><%=rs.getInt("collect") %></span>
                        <br>
                        👁️&nbsp;<span class="view-count"><%= viewCount %></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
<%
}
commentsDataJS.append("};");
%>
                    </div>
                    
                   <!-- 留言模态框 -->
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

        <!-- 输入留言 -->
        <form name="form" action="update.jsp" method="post">                          
            <textarea name="text" id="commentText" placeholder="請輸入您的留言..." rows="5"></textarea>
            <input type="hidden" name="memberId" value="<%= member %>">
            <input type="hidden" name="postid" id="hiddenPostid" value="">
            <button type="submit" name="submitButton">提交留言</button>
        </form>
    </div>
</div>

                    <div class="swiper-button-next icon-arrow-right"></div>
                    <div class="swiper-button-prev icon-arrow-left"></div>
                    <div class="swiper-pagination"></div>
                </div>
            </div>
        </div>
    </section>
</section>

<!-- JS -->
<script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>
<script>
// 載入留言數據
<%= commentsDataJS.toString() %>

// Swiper 初始化
var swiper = new Swiper('.main-swiper', {
    slidesPerView: 1,
    spaceBetween: 10,
    navigation: {
        nextEl: '.icon-arrow-right',
        prevEl: '.icon-arrow-left'
    },
    pagination: {
        el: '.swiper-pagination',
        clickable: true,
    },
});


console.log('Swiper 初始化完成');
console.log('總共有 ' + swiper.slides.length + ' 張投影片');

// 記錄已經計數過的貼文
var viewedPosts = new Set();

// 監聽 Swiper 滑動事件
swiper.on('slideChange', function () {
    console.log('=== 投影片切換 ===');
    console.log('當前索引: ' + swiper.activeIndex);
    
    var activeSlide = swiper.slides[swiper.activeIndex];
    var postid = activeSlide.getAttribute('data-postid');
    
    console.log('當前 postid: ' + postid);
    console.log('是否已計數: ' + viewedPosts.has(postid));
    
    if (postid && !viewedPosts.has(postid)) {
        viewedPosts.add(postid);
        updateViewCount(postid, activeSlide);
    }
});

// 頁面載入時，計算第一張可見的貼文
window.addEventListener('load', function() {
    console.log('=== 頁面載入完成 ===');
    setTimeout(function() {
        if (swiper.slides && swiper.slides.length > 0) {
            var firstSlide = swiper.slides[0];
            var postid = firstSlide.getAttribute('data-postid');
            
            console.log('第一張投影片 postid: ' + postid);
            
            if (postid && !viewedPosts.has(postid)) {
                viewedPosts.add(postid);
                updateViewCount(postid, firstSlide);
            } else {
                console.log('無法取得 postid 或已計數');
            }
        } else {
            console.log('找不到投影片');
        }
    }, 500);
});

// 更新瀏覽次數的函數
function updateViewCount(postid, slideElement) {
    console.log('=== 呼叫 updateViewCount ===');
    console.log('postid: ' + postid);
    console.log('fetch URL: updateView.jsp?postid=' + postid);
    
    fetch('updateView.jsp?postid=' + postid)
        .then(response => {
            console.log('收到回應');
            return response.text();
        })
        .then(data => {
            console.log('回應內容: ' + data);
            var newCount = data.trim();
            if (newCount !== 'error' && !isNaN(newCount)) {
                var viewCountElement = slideElement.querySelector('.view-count');
                if (viewCountElement) {
                    viewCountElement.textContent = newCount;
                    console.log('✅ 瀏覽次數已更新為: ' + newCount);
                } else {
                    console.log('❌ 找不到 .view-count 元素');
                }
            } else {
                console.error('❌ 更新失敗，收到: ' + data);
            }
        })
        .catch(error => {
            console.error('❌ Fetch 錯誤:', error);
        });
}
    // ========== 瀏覽次數追蹤程式碼結束 ==========

    // 留言功能 - 修改這個函數
function toggleComment(element) {
    // 找到當前貼文的 postid
    var postSlide = element.closest('.swiper-slide');
    var postid = postSlide.getAttribute('data-postid');
    
    // 設置隱藏欄位的值
    document.getElementById('hiddenPostid').value = postid;
    
    // 清空並載入該貼文的留言
    var commentList = document.getElementById('commentList');
    commentList.innerHTML = '';
    
    if (allComments[postid] && allComments[postid].length > 0) {
        allComments[postid].forEach(function(comment) {
            var li = document.createElement('li');
            // 顯示格式：帳號 + 留言內容
            li.innerHTML = '<strong style="color: #a89f91;">' + comment.member + ':</strong> ' + comment.message;
            commentList.appendChild(li);
        });
    } else {
        commentList.innerHTML = '<li style="color: #999;">目前還沒有留言，快來搶沙發吧！</li>';
    }
    
    // 打開留言模態框
    document.getElementById('commentModal').style.display = 'flex';
}

 // 關閉留言模態框
    function closeCommentModal() {
        document.getElementById('commentModal').style.display = 'none';
    }

    // 提交留言功能（會顯示留言內容在列表中）
    function submitComment() {
        const commentText = document.getElementById('commentText').value;
        if (commentText.trim() !== "") {
            const commentList = document.getElementById('commentList');
            const newComment = document.createElement('li');
            newComment.textContent = commentText;  // 顯示留言的內容
            commentList.appendChild(newComment);  // 把留言加入到列表中

            // 更新留言數量
            const commentCountElement = document.querySelector('.comments-count');
            let commentCount = parseInt(commentCountElement.textContent);
            commentCountElement.textContent = commentCount + 1;  // 每次提交留言數量增加1

            // 讓留言區顯示
            document.getElementById('commentDisplay').style.display = 'block'; 

            document.getElementById('commentText').value = ""; // 清空留言輸入框
            alert("留言提交成功！");
        } else {
            alert("請輸入留言內容！");
        }
    }

    
 // 按讚功能 - 記錄會員狀態
    function toggleLike(element) {
        event.preventDefault();
        
        const icon = element.querySelector('svg path');
        const isLiked = element.getAttribute('data-liked') === 'true';
        const action = isLiked ? 'remove' : 'add';
        
        const postSlide = element.closest('.swiper-slide');
        const postid = postSlide.getAttribute('data-postid');
        const memberId = '<%= member %>';
        
        fetch('updateLike.jsp?postid=' + postid + '&memberId=' + memberId + '&action=' + action)
            .then(response => response.text())
            .then(data => {
                const newCount = data.trim();
                if (newCount !== 'error' && !isNaN(newCount)) {
                    // 更新狀態
                    element.setAttribute('data-liked', !isLiked);
                    icon.style.fill = isLiked ? 'none' : 'red';
                    
                    const likeCountElement = element.closest('.post-actions').querySelector('.likes-count');
                    likeCountElement.textContent = newCount;
                } else {
                    alert('操作失敗，請稍後再試！');
                }
            })
            .catch(error => {
                console.error('錯誤:', error);
                alert('系統錯誤，請稍後再試！');
            });
    }

 // 收藏功能 - 記錄會員狀態
    function toggleStar(element) {
        event.preventDefault();
        
        const icon = element.querySelector('svg path');
        const isCollected = element.getAttribute('data-collected') === 'true';
        const action = isCollected ? 'remove' : 'add';
        
        const postSlide = element.closest('.swiper-slide');
        const postid = postSlide.getAttribute('data-postid');
        const memberId = '<%= member %>';
        
        fetch('updateCollect.jsp?postid=' + postid + '&memberId=' + memberId + '&action=' + action)
            .then(response => response.text())
            .then(data => {
                const newCount = data.trim();
                if (newCount !== 'error' && !isNaN(newCount)) {
                    // 更新狀態
                    element.setAttribute('data-collected', !isCollected);
                    icon.style.fill = isCollected ? 'none' : 'yellow';
                    
                    const starCountElement = element.closest('.post-actions').querySelector('.stars-count');
                    starCountElement.textContent = newCount;
                } else {
                    alert('操作失敗，請稍後再試！');
                }
            })
            .catch(error => {
                console.error('錯誤:', error);
                alert('系統錯誤，請稍後再試！');
            });
    }
    
</script>

<!-- CSS -->
<style>
    /

    /* 统一样式 */
    .modal {
        display: none;
        position: fixed;
        z-index: 1;
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
        font-family: 'Helvetic

    /* 统一样式 */
    .modal {
        display: none;
        position: fixed;
        z-index: 1;
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
        font-family: 'Helvetica', sans-serif;
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
    .close:hover,
    .close:focus {
        color: #000;
        text-decoration: none;
    }
    h2 {
        font-size: 24px;
        font-weight: 600;
        color: #333;
        margin-bottom: 20px;
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
}
    }
    #commentText {
        width: 100%;
        height: 80px;
        padding: 10px;
        margin-bottom: 10px;
        border-radius: 5px;
        border: 1px solid #ddd;
        font-size: 14px;
        font-family: 'Helvetica', sans-serif;
    }
    button {
        padding: 10px 20px;
        background-color: #a89f91; /* 按鈕顏色 */
        color: #fff;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 16px;
    }
    button:hover {
        background-color: #8f8c7f;
    }

    /* 按钮下方的文本样式 */
    .likes-count-container, .comments-count-container, .stars-count-container {
        text-align: center;
        margin-top: 5px;
    }
    .likes-text, .comments-text, .stars-text {
        font-size: 12px;
        color: #555;
    }
</style>


  <section id="new-arrival" class="new-arrival product-carousel py-5 position-relative overflow-hidden">
  <div class="container">
    <div class="section-header text-center mt-5">
    <section id="Same style">
      <h3 class="text-uppercase">穿搭推薦</h3>     
    </div>

    <div class="swiper product-swiper open-up" data-aos="zoom-out">
      <div class="swiper-wrapper d-flex">

<%
  // 顯示資料庫中的穿搭組合
  for(int i = 0; i < styleList.size(); i++) {
      java.util.HashMap<String, String> style = styleList.get(i);
      String[] tagArray = style.get("tags").split("\\|");
  %>
  <div class="swiper-slide">
    <div class="product-item image-zoom-effect link-effect">
      <div class="image-holder position-relative">
        <a href="javascript:void(0)" onclick="openStyleModal('<%= i %>')" style="cursor: pointer;">
          <img src="<%= style.get("pic") %>" alt="<%= style.get("title") %>" class="product-image img-fluid">
        </a>
        <%
for(String tag : tagArray) {
    if(tag.trim().isEmpty()) continue;
    String[] tagInfo = tag.split(",");
    if(tagInfo.length >= 6) {
        String tagName = tagInfo[0];
        String tagPrice = tagInfo[1];
        String tagX = tagInfo[2];
        String tagY = tagInfo[3];
        String tagWebsite = tagInfo[4];
        String commodityCode = tagInfo[5];
        
        // 查詢該商品編號的所有圖片（從同一個 commodity_code 的所有記錄中獲取）
        String imageQuery = "SELECT pic FROM commodity_information WHERE commodity_code = ?";
        PreparedStatement pstmtImages = con.prepareStatement(imageQuery);
        pstmtImages.setString(1, commodityCode);
        ResultSet rsImages = pstmtImages.executeQuery();
        
        StringBuilder images = new StringBuilder();
        int imgCount = 0;
        while(rsImages.next() && imgCount < 4) {  // 最多4張圖片
            if(imgCount > 0) images.append("|||");
            images.append(rsImages.getString("pic"));
            imgCount++;
        }
        rsImages.close();
        pstmtImages.close();
%>
<div class="product-link" 
     style="top: <%= tagY %>%; left: <%= tagX %>%;"
     onclick="window.open('<%= tagWebsite %>', '_blank')">
  <div class="product-tag"><%= tagName %><br>$<%= tagPrice %></div>
</div>
<%
    }
}
%>
      </div>
    </div>
  </div>
  <%
  }
  %>
  <script>
  // 從資料庫載入的穿搭組合資料
  const styleSetData = [
	  <%
	  for(int i = 0; i < styleList.size(); i++) {
	      java.util.HashMap<String, String> style = styleList.get(i);
	      if(i > 0) out.print(",");
	  %>
	  {
	      title: '<%= style.get("title").replace("'", "\\'") %>',
	      image: '<%= style.get("pic") %>',
	      tags: '<%= style.get("tags") %>',
	      tagCount: <%= style.get("tagCount") %>
	  }
	  <%
	  }
	  %>
	  ];

	  // 打開穿搭組合彈窗
	  function openStyleModal(index) {
	      const style = styleSetData[index];
	      if (!style) return;
	      
	      // 使用相同的彈窗，但填入不同資料
	      document.getElementById('modalProductName').textContent = style.title;
	      document.getElementById('modalProductTitle').textContent = style.title;
	      document.getElementById('modalProductDesc').textContent = '這是來自商家的穿搭組合，包含 ' + style.tagCount + ' 件商品';
	      
	      // 設置圖片
	      document.getElementById('modalMainImage').src = style.image;
	      document.getElementById('imageCounter').textContent = '1 / 1';
	      
	      // 隱藏縮圖區域（因為只有一張圖）
	      document.getElementById('productThumbnails').style.display = 'none';
	      document.querySelector('.product-nav-btn.prev').style.display = 'none';
	      document.querySelector('.product-nav-btn.next').style.display = 'none';
	      
	      // 顯示標籤資訊
	      const tags = style.tags.split('|');
	      let tagHtml = '<h3>包含商品：</h3><ul>';
	      tags.forEach(tag => {
	          const [name, price] = tag.split(',');
	          if(name && price) {
	              tagHtml += '<li>' + name + ' - NT$' + price + '</li>';
	          }
	      });
	      tagHtml += '</ul>';
	      document.getElementById('modalProductDesc').innerHTML = tagHtml;
	      
	      // 隱藏蝦皮連結按鈕
	      document.getElementById('modalShopeeLink').style.display = 'none';
	      
	      // 顯示彈窗
	      document.getElementById('productModal').classList.add('active');
	      document.body.style.overflow = 'hidden';
	  }
	  </script>
       <div class="swiper-slide">
  <div class="product-item image-zoom-effect link-effect">
    <div class="image-holder position-relative">
      <a href="javascript:void(0)" onclick="openProductModal('outfit1')" style="cursor: pointer;">
        <img src="images/M.jpg" alt="Outfit 1" class="product-image img-fluid">
      </a>
      <a href="https://reurl.cc/eGdpqM" class="product-link" style="position: absolute; top: 65%; left: 35%;">
        <div class="product-tag">咖啡外套<br>$750</div>
      </a>
      <a href="https://reurl.cc/eGdpqM" class="product-link" style="position: absolute; top: 80%; left: 70%;">
        <div class="product-tag">咖啡百褶裙<br>$410</div>
      </a>
    </div>
  </div>
</div>

<!-- 商品 2：西裝外套 -->
<div class="swiper-slide">
  <div class="product-item image-zoom-effect link-effect">
    <div class="image-holder position-relative">
      <a href="javascript:void(0)" onclick="openProductModal('outfit2')" style="cursor: pointer;">
        <img src="images/W.jpg" alt="Outfit 2" class="product-image img-fluid">
      </a>
      <a href="https://reurl.cc/WAvzvL" class="product-link" style="position: absolute; top: 60%; left: 40%;">
        <div class="product-tag">西裝外套-灰<br>$1180</div>
      </a>
      <a href="https://reurl.cc/oV5mRg" class="product-link" style="position: absolute; top: 75%; left: 65%;">
        <div class="product-tag">水桶包-黑<br>$600</div>
      </a>
    </div>
  </div>
</div>

<!-- 商品 3：排釦上衣 -->
<div class="swiper-slide">
  <div class="product-item image-zoom-effect link-effect">
    <div class="image-holder position-relative">
      <a href="javascript:void(0)" onclick="openProductModal('outfit3')" style="cursor: pointer;">
        <img src="images/S.jpg" alt="Outfit 3" class="product-image img-fluid">
      </a>
      <a href="https://reurl.cc/26E734" class="product-link" style="position: absolute; top: 65%; left: 40%;">
        <div class="product-tag">排釦上衣<br>$430</div>
      </a>
      <a href="https://tw.shp.ee/D5aeBeq" class="product-link" style="position: absolute; top: 80%; left: 60%;">
        <div class="product-tag">深藍黑牛仔短裙<br>$525</div>
      </a>
    </div>
  </div>
</div>

<!-- 商品 4：連帽外套 -->
<div class="swiper-slide">
  <div class="product-item image-zoom-effect link-effect">
    <div class="image-holder position-relative">
      <a href="javascript:void(0)" onclick="openProductModal('outfit4')" style="cursor: pointer;">
        <img src="images/C.jpg" alt="Outfit 4" class="product-image img-fluid">
      </a>
      <a href="https://reurl.cc/kMakNq" class="product-link" style="position: absolute; top: 60%; left: 35%;">
        <div class="product-tag">連帽棉外套-黑<br>$880</div>
      </a>
    </div>
  </div>
</div>

<!-- 商品 5：帽T -->
<div class="swiper-slide">
  <div class="product-item image-zoom-effect link-effect">
    <div class="image-holder position-relative">
      <a href="javascript:void(0)" onclick="openProductModal('outfit5')" style="cursor: pointer;">
        <img src="images/X.jpg" alt="Outfit 5" class="product-image img-fluid">
      </a>
      <a href="https://reurl.cc/vp6omj" class="product-link" style="position: absolute; top: 65%; left: 40%;">
        <div class="product-tag">帽T-淺灰色<br>$609</div>
      </a>
      <a href="https://reurl.cc/Q5ZmXZ" class="product-link" style="position: absolute; top: 80%; left: 70%;">
        <div class="product-tag">日系工裝褲-灰<br>$550</div>
      </a>
    </div>
  </div>
</div>

<!-- 商品 6：風衣 -->
<div class="swiper-slide">
  <div class="product-item image-zoom-effect link-effect">
    <div class="image-holder position-relative">
      <a href="javascript:void(0)" onclick="openProductModal('outfit6')" style="cursor: pointer;">
        <img src="images/O.jpg" alt="Outfit 6" class="product-image img-fluid">
      </a>
      <a href="https://tw.shp.ee/tjJueee" class="product-link" style="position: absolute; top: 65%; left: 35%;">
        <div class="product-tag">風衣-黑<br>$2240</div>
      </a>
      <a href="https://tw.shp.ee/LhYjBBQ" class="product-link" style="position: absolute; top: 80%; left: 65%;">
        <div class="product-tag">西裝褲-灰<br>$350</div>
      </a>
    </div>
  </div>
</div>

      </div>
      <div class="swiper-pagination"></div>
    </div>
    
    <div class="icon-arrow icon-arrow-left">
      <svg width="50" height="50" viewBox="0 0 24 24">
        <use xlink:href="#arrow-left"></use>
      </svg>
    </div>
    <div class="icon-arrow icon-arrow-right">
      <svg width="50" height="50" viewBox="0 0 24 24">
        <use xlink:href="#arrow-right"></use>
      </svg>
    </div>
  </div>
 </section>
</section>

<style>

.product-link {
  position: absolute;
  transform: translate(-50%, -50%);
  z-index: 10;
  cursor: pointer;
  transition: all 0.3s ease;
}

.product-link:hover {
  transform: translate(-50%, -50%) scale(1.05);
  z-index: 20;
}

.product-tag {
  font-size: 12px; 
  padding: 4px 6px; 
  background-color: #a89f91;
  color: white;
  border-radius: 4px;
  white-space: nowrap;
  text-align: center;
  transition: all 0.3s ease;
}

.product-tag:hover {
  background-color: #9b8e82; 
  transform: scale(1.05);
}

.product-item .image-holder {
  position: relative;
  width: 100%;
  overflow: hidden;  /* 让标签不超出图片边界 */
}

.product-item .image-holder .product-image {
  display: block;
  width: 100%;
  height: auto;
  object-fit: cover;
}

/* ===== 確保導航列和搜尋功能正常運作 ===== */

/* 導航列要在正常層級 */
header {
    position: relative !important;
    z-index: 1050 !important;
}

.navbar {
    position: relative !important;
    z-index: 1050 !important;
}

/* 搜尋功能 */
.search-popup {
    z-index: 1060 !important;
}

.offcanvas {
    z-index: 1055 !important;
}

.offcanvas-backdrop {
    z-index: 1054 !important;
}

/* 確保搜尋圖示可以點擊 */
.action-menu,
.search-box,
button[data-bs-toggle] {
    position: relative !important;
    z-index: 1051 !important;
    pointer-events: auto !important;
}

/* ✅ 新增：移除搜尋圖示的動畫效果 */
.action-menu svg,
.search-box svg,
.action-menu a,
.search-box a {
    transform: none !important;
    transition: none !important;
    animation: none !important;
}

.action-menu a:hover svg,
.search-box a:hover svg {
    transform: none !important;
}

/* 留言彈窗 */
#commentModal {
    z-index: 1040 !important;
}

/* 回到頂部按鈕 */
.back-to-top {
    z-index: 1030 !important;
}

/* 開場動畫關閉後完全不干擾 */
.modal-overlay {
    transition: z-index 0s 0.4s;
}

/* 貼文標籤樣式 */
.post-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 12px;
}

.post-tag {
    display: inline-block;
    padding: 4px 12px;
    background-color: #f0ebe5;
    color: #6b5d52;
    border-radius: 15px;
    font-size: 13px;
    font-weight: 500;
    transition: all 0.3s ease;
}

.post-tag:hover {
    background-color: #a89f91;
    color: white;
    transform: translateY(-2px);
}

/* ✅ 新增：已按讚的愛心顯示紅色 */
.like-icon[data-liked="true"] svg path {
    fill: red !important;
}

/* ✅ 新增：已收藏的星星顯示黃色 */
.star-icon[data-collected="true"] svg path {
    fill: yellow !important;
}

</style>


  <section class="collection bg-light position-relative py-5">
    <div class="container">
      <div class="row">
        <div class="title-xlarge text-uppercase txt-fx domino">Collection</div>
        <div class="collection-item d-flex flex-wrap my-5">
          <div class="col-md-6 column-container">
            <div class="image-holder">
              <img src="images/single-image-2.jpg" alt="collection" class="product-image img-fluid">
            </div>
          </div>
          <div class="col-md-6 column-container bg-white">
            <div class="collection-content p-5 m-0 m-md-5">
             <section id="Reward&Method">
              <h3 class="element-title text-uppercase">活動方法</h3>
              <p>上傳貼文,並獲得10,000按讚數且留言數獲得100則，則能得到以下獎賞</p>
               <h3 class="element-title text-uppercase">活動獎勵</h3>
              <p>Z品牌服飾的50%折扣,C品牌服飾的購物金$3000</p> 
              </section>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>


    <div class="container">
    <div class="section-header text-center mt-5"> 
      <h3 class="section-title">體型建議</h3>
    </div>
    <div class="swiper testimonial-swiper overflow-hidden my-5">
      <div class="swiper-wrapper d-flex">
        <div class="swiper-slide">
          <div class="testimonial-item text-center">
            <blockquote>
            <section class="slide" id="Inverted_Triangle">
            <div class="review-title text-uppercase">倒三角型</div>
             <h4><p>肩膀較寬，下半身比較窄，容易顯得頭重腳輕，看起來比較壯。</p></h4>
             </section>
            </blockquote>
          </div>
        </div>
        <div class="swiper-slide">
          <div class="testimonial-item text-center">
            <blockquote>
            <section class="slide" id="Rectangle">
              <div class="review-title text-uppercase">矩型</div>
              <h4><p>肩膀、腰部、臀部的寬度都差不多，腰線不明顯，身材輪廓較模糊。</p></h4>
              </section>
            </blockquote>
          </div>
        </div>
        <div class="swiper-slide">
          <div class="testimonial-item text-center">
            <blockquote>
             <section class="slide" id="Apple">
              <div class="review-title text-uppercase">蘋果型</div>
             <h4><p>肩膀較寬厚，腰部贅肉較多，胸部、臀部較豐滿，下肢較細，整體容易顯得臃腫。</p></h4>
             </section>
            </blockquote>
          </div>
        </div>
        <div class="swiper-slide">
          <div class="testimonial-item text-center">
            <blockquote>
            <section class="slide" id="Pear">
              <div class="review-title text-uppercase">梨型</div>
              <h4><p>肩膀較窄，腰部較細，臀部、骨盆較為寬大，整體呈現出正三角的形狀，常伴隨「假跨寬」的現象（即大腿外側的馬鞍肉），下半身易顯肥胖。</p></h4>
            </section>
            </blockquote>
          </div>
        </div>
        <div class="swiper-slide">
          <div class="testimonial-item text-center">
            <blockquote>
            <section id="Hourglass">
           <div class="review-title text-uppercase">沙漏型</div>
              <h4><p>肩膀、臀部的寬度比較接近，胸部、臀部較為豐滿，整體曲線明顯，是較為理想的身材。</p></h4>
            </section>
            </blockquote>
          </div>
        </div>
      </div>
    </div>
    <div class="testimonial-swiper-pagination d-flex justify-content-center mb-5"></div>
  

  <footer id="footer" class="mt-5">
    <div class="container">
      <div class="row d-flex flex-wrap justify-content-between py-5">
        <div class="col-md-3 col-sm-6">
          <div class="footer-menu footer-menu-001">
            <div class="footer-intro mb-4">
            </div>
           <div class="social-links">
              <ul class="list-unstyled d-flex flex-wrap gap-3">
                 <a href="javascript:void(0)" onclick="openProductModal('outfit1')" style="cursor: pointer;">
                <img src="images/main-logo.png" alt="logo" width="300" height="60">
                 </a>
              </ul>
            </div>
          </div>
        </div>
        <div class="col-md-3 col-sm-6">
          <div class="footer-menu footer-menu-002">
            <h5 class="widget-title text-uppercase mb-4">Quick Links</h5>
            <ul class="menu-list list-unstyled text-uppercase border-animation-left fs-6">
              <li class="menu-item">
                <a href="#Inverted_Triangle" class="item-anchor">體型建議</a>
              </li>                            
              <li class="menu-item">
                <a href="#Posts" class="item-anchor">穿搭展示區</a>
              </li>
              <li class="menu-item">
                <a href="#Same style" class="item-anchor">穿搭推薦</a>
              </li>
              <li class="menu-item">
                <a href="#Reward&Method" class="item-anchor">穿搭分享獎勵</a>
              </li>              
            </ul>
          </div>
        </div>
       
      </div>
    </div>
    <div class="border-top py-4">
      <div class="container">
        <div class="row">
          <div class="col-md-6 d-flex flex-wrap">
            <div class="payment-option">
              <span>Payment Option:</span>
              <img src="images/visa-card.png" alt="card">
              <img src="images/paypal-card.png" alt="card">
              <img src="images/master-card.png" alt="card">
            </div>
          </div>
          <div class="col-md-6 text-end">
            <p>© CZ</p>
          </div>
        </div>
      </div>
    </div>
  </footer>



<div class="modal-overlay" id="modalOverlay">    

        <div class="modal-content">
        <button class="close-btn" onclick="closeModal()">×</button>
            <div class="top-decoration">
                <span class="deco-line"></span>
                <span class="deco-dot"></span>
                <span class="deco-line"></span>
            </div>

            <h2 class="modal-title">穿搭美學</h2>
            
            <p class="quote-text">
                <span class="highlight">穿搭</span>,不只是外在的表現<br>
                也是一種對場合、對他人<br>
                更對自己的<span class="highlight">溫柔尊重</span>
            </p>
            
            <p class="quote-text">
                用心挑選每一件衣服<br>
                讓生活多一份<span class="highlight">儀式感</span>
            </p>
            
            <p class="quote-text">
                穿衣,是一種表達<br>
                合宜的穿搭,不只是風格<br>
                更是一份對世界的<span class="highlight">禮貌與溫柔</span>
            </p>
            
            <button class="start-btn" onclick="closeModal()">
                <span>開始探索</span>
            </button>
            
            <div class="bottom-decoration">
                <span class="ornament"></span>
                <span class="ornament-circle"></span>
                <span class="ornament"></span>
                <span class="ornament-circle"></span>
                <span class="ornament"></span>
            </div>
        </div>
    
</div>

 <script>
 function closeModal() {
	    const overlay = document.getElementById('modalOverlay');
	    overlay.style.animation = 'fadeOut 0.4s ease';
	    
	    setTimeout(() => {
	        overlay.style.display = 'none';
	        overlay.style.zIndex = '-1';
	        overlay.style.pointerEvents = 'none';  // ✅ 新增：完全不接收點擊
	    }, 400);
	}

 window.addEventListener('load', function() {
	    const overlay = document.getElementById('modalOverlay');
	    overlay.style.display = 'flex';
	    overlay.style.zIndex = '10001';
	    overlay.style.pointerEvents = 'auto';  // ✅ 新增：顯示時可接收點擊
	});

document.getElementById('modalOverlay').addEventListener('click', function(e) {
    if (e.target === this) {
        closeModal();
    }
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeModal();
    }
});
</script>
          

        </div>

<script>
// 商品資料庫 - 使用真實蝦皮商品連結
const productsData = {
    'outfit1': {
        name: 'ATTENTION 初雪!水貂毛柔軟毛衣(附繫脖)',
        price: 790,
        description: 'ATTENTION att-made! 初雪系列，水貂毛柔軟舒適，附可拆式繫脖設計，展現優雅氣質。',
        shopeeLink: 'https://shopee.tw/ATTENTION-att-made!%E5%88%9D%E9%9B%AA!%E6%B0%B4%E8%B2%82%E6%AF%9B%E6%9F%94%E8%BB%9F%E6%AF%9B%E8%A1%A3(%E9%99%84%E7%B9%9E%E8%84%96)-i.11304279.50152742814',
        images: [
            'https://cf.shopee.tw/file/tw-11134207-7r98o-m24b68bkh5ky1e',
            'https://cf.shopee.tw/file/tw-11134207-7r98z-m24b68bkiqae41',
            'https://cf.shopee.tw/file/tw-11134207-7r990-m24b68bkk4uu80',
            'https://cf.shopee.tw/file/tw-11134207-7r98u-m24b68bkljff64'
        ]
    },
    'outfit2': {
        name: 'ATTENTION 國民男友立領拉鍊大學TEE',
        price: 590,
        description: 'ATTENTION att-made! 國民男友系列，立領拉鍊設計，大學風格休閒百搭。',
        shopeeLink: 'https://shopee.tw/ATTENTION-att-made!%E5%9C%8B%E6%B0%91%E7%94%B7%E5%8F%8B%E7%AB%8B%E9%A0%98%E6%8B%89%E9%8D%8A%E5%A4%A7%E5%AD%B8TEE-i.11304279.26315496029',
        images: [
            'https://cf.shopee.tw/file/tw-11134207-7r98y-lvxezaswwk2ee9',
            'https://cf.shopee.tw/file/tw-11134207-7r990-lvxezaswyemg97',
            'https://cf.shopee.tw/file/tw-11134207-7r98v-lvxezaswxf8wce',
            'https://cf.shopee.tw/file/tw-11134207-7r98y-lvxezaswyzvw4a'
        ]
    },
    'outfit3': {
        name: 'ATTENTION 新色回歸!愛款質感西褲',
        price: 890,
        description: 'ATTENTION 愛款質感西褲，新色上市！俐落剪裁展現專業氣質，適合各種正式場合。',
        shopeeLink: 'https://shopee.tw/ATTENTION-%E6%96%B0%E8%89%B2%E5%9B%9E%E6%AD%B8!%E6%84%9B%E6%AC%BE%E8%B3%AA%E6%84%9F%E8%A5%BF%E8%A4%B2-i.11304279.16441442858',
        images: [
            'https://cf.shopee.tw/file/tw-11134207-7r98w-lue5jdtl2v2ud2',
            'https://cf.shopee.tw/file/tw-11134207-7r98u-lue5jdtl49n6e7',
            'https://cf.shopee.tw/file/tw-11134207-7r98v-lue5jdtl5o7m51',
            'https://cf.shopee.tw/file/tw-11134207-7r991-lue5jdtl72s265'
        ]
    },
    'outfit4': {
        name: '復古藍寬鬆彎刀牛仔褲（現貨）',
        price: 750,
        description: '復古藍寬鬆彎刀牛仔褲，經典復古設計，寬鬆版型舒適自在，展現個性街頭風格。',
        shopeeLink: 'https://shopee.tw/%E5%BE%A9%E5%8F%A4%E8%97%8D%E5%AF%AC%E9%AC%86%E5%BD%8E%E5%88%80%E7%89%9B%E4%BB%94%E8%A4%B2%EF%BC%88%E7%8F%BE%E8%B2%A8)-i.3112818.44462968339',
        images: [
            'https://cf.shopee.tw/file/tw-11134207-7r990-m1a6wy27mf9f75',
            'https://cf.shopee.tw/file/tw-11134207-7r98s-m1a6wy27nttpbc',
            'https://cf.shopee.tw/file/tw-11134207-7r98x-m1a6wy27p8e549',
            'https://cf.shopee.tw/file/tw-11134207-7r98z-m1a6wy27qmyl6f'
        ]
    },
    'outfit5': {
        name: '大V領條紋毛衣（現+預購）',
        price: 680,
        description: '大V領條紋毛衣，經典條紋設計，V領修飾臉型，溫柔知性風格必備單品。',
        shopeeLink: 'https://shopee.tw/%E5%A4%A7V%E9%A0%98%E6%A2%9D%E7%B4%8B%E6%AF%9B%E8%A1%A3%EF%BC%88%E7%8F%BE-%E9%A0%90%E8%B3%BC)-i.3112818.26420658795',
        images: [
            'https://cf.shopee.tw/file/tw-11134207-7r98x-lweorh15ld7w75',
            'https://cf.shopee.tw/file/tw-11134207-7r98z-lweorh15mrsca4',
            'https://cf.shopee.tw/file/tw-11134207-7r98u-lweorh15o6cs6d',
            'https://cf.shopee.tw/file/tw-11134207-7r98v-lweorh15pl1822'
        ]
    },
    'outfit6': {
        name: '版型極好顯瘦五分褲（現貨）',
        price: 590,
        description: '版型極好顯瘦五分褲，精心設計的版型修飾腿型，顯瘦效果極佳，夏日必備單品。',
        shopeeLink: 'https://shopee.tw/%E7%89%88%E5%9E%8B%E6%A5%B5%E5%A5%BD%E9%A1%AF%E7%98%A6%E4%BA%94%E5%88%86%E8%A4%B2%EF%BC%88%E7%8F%BE%E8%B2%A8%EF%BC%89-i.3112818.26907648064',
        images: [
            'https://cf.shopee.tw/file/tw-11134207-7r990-lweoq82iw8xsd7',
            'https://cf.shopee.tw/file/tw-11134207-7r98s-lweoq82ixni86e',
            'https://cf.shopee.tw/file/tw-11134207-7r98x-lweoq82iz22o2f',
            'https://cf.shopee.tw/file/tw-11134207-7r98z-lweoq82j0gn455'
        ]
    }
};

// 當前顯示的商品和圖片索引
let currentProduct = null;
let currentImageIndex = 0;

// 打開商品詳情彈窗
function openProductModal(productId) {
    currentProduct = productsData[productId];
    if (!currentProduct) return;
    
    currentImageIndex = 0;
    
    // 設置商品基本資訊
    document.getElementById('modalProductName').textContent = currentProduct.name;
    document.getElementById('modalProductTitle').textContent = currentProduct.name;
    document.getElementById('modalProductPrice').textContent = 'NT$ ' + currentProduct.price.toLocaleString();
    document.getElementById('modalProductDesc').textContent = currentProduct.description;
    document.getElementById('modalShopeeLink').href = currentProduct.shopeeLink;
    
    // 設置主圖片
    updateMainImage();
    
    // 生成縮圖
    generateThumbnails();
    
    // 顯示彈窗
    document.getElementById('productModal').classList.add('active');
    document.body.style.overflow = 'hidden';
}

</script>

</body>

</html>