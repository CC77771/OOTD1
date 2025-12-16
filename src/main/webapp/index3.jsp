<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file ="menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<%	
	Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
	Connection con=DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
	Statement smt= con.createStatement();
	String sql = "SELECT * FROM personal_wear;";
	ResultSet rs = smt.executeQuery(sql);
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
            bottom: 40px;
            right: 40px;
            background-color: #a89f91;
            color: white;
            border: none;
            padding: 8px;
            border-radius: 50%;
            cursor: pointer;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
            transition: background-color 0.3s ease, transform 0.3s ease;
            width: 60px;
            height: 60px;
        }

        .back-to-top:hover {
            background-color: #555;
            transform: scale(1.1);
        }

        .back-to-top svg {
            width: 24px;
            height: 24px;
            fill: white;
        }

        .content-section {
            min-height: 100vh;
            padding: 20px;
            background-color: lightgray;
        }

        /* 搜尋按鈕樣式 */
        .search-main-button {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            padding: 15px 30px;
            background: linear-gradient(135deg, #a89f91 0%, #8b7e6f 100%);
            color: white;
            border: none;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(168, 159, 145, 0.3);
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }

        .search-main-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(168, 159, 145, 0.4);
            background: linear-gradient(135deg, #8b7e6f 0%, #a89f91 100%);
        }

        .search-main-button svg {
            width: 24px;
            height: 24px;
        }

        /* 搜尋彈窗樣式 */
        .search-modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 9998;
            animation: fadeIn 0.3s ease;
        }

        .search-modal-overlay.active {
            display: block;
        }

        .search-modal {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 90%;
            max-width: 900px;
            max-height: 90vh;
            background: linear-gradient(135deg, #fff5f5 0%, #ffffff 50%, #f5f0ff 100%);
            border-radius: 25px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            z-index: 9999;
            overflow-y: auto;
            animation: slideIn 0.3s ease;
        }

        .search-modal.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translate(-50%, -45%);
            }
            to {
                opacity: 1;
                transform: translate(-50%, -50%);
            }
        }

        .search-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 25px 30px;
            border-bottom: 2px solid #f0f0f0;
        }

        .search-modal-title {
            font-size: 28px;
            font-weight: 700;
            color: #333;
            margin: 0;
        }

        .search-modal-subtitle {
            color: #666;
            font-size: 14px;
            margin-top: 5px;
        }

        .search-modal-close {
            background: none;
            border: none;
            font-size: 32px;
            color: #999;
            cursor: pointer;
            transition: color 0.3s ease;
            padding: 0;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .search-modal-close:hover {
            color: #333;
        }

        .search-modal-body {
            padding: 30px;
        }

        .search-input-wrapper {
            position: relative;
            margin-bottom: 20px;
        }

        .search-input {
            width: 100%;
            padding: 15px 50px 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            font-size: 16px;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            border-color: #a89f91;
            box-shadow: 0 0 0 3px rgba(168, 159, 145, 0.1);
        }

        .search-icon {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }

        .selected-tags-container {
            background: #f8f5f2;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            display: none;
        }

        .selected-tags-container.show {
            display: block;
        }

        .selected-tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #a89f91;
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            margin: 5px;
            font-size: 14px;
        }

        .remove-tag-btn {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 18px;
            padding: 0;
            margin-left: 5px;
        }

        .style-tags-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
            gap: 12px;
            margin-bottom: 25px;
        }

        .style-tag-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 18px 12px;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .style-tag-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .style-tag-btn.selected {
            background: #a89f91;
            color: white;
            border-color: #a89f91;
            box-shadow: 0 4px 12px rgba(168, 159, 145, 0.3);
        }

        .style-tag-emoji {
            font-size: 28px;
            margin-bottom: 8px;
        }

        .style-tag-label {
            font-size: 13px;
            font-weight: 500;
        }

        .search-actions {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
        }

        .btn-perform-search {
            flex: 1;
            background: #a89f91;
            color: white;
            border: none;
            padding: 15px 25px;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-perform-search:hover {
            background: #8b7e6f;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(168, 159, 145, 0.3);
        }

        .btn-clear-search {
            padding: 15px 30px;
            background: #f0f0f0;
            color: #666;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-clear-search:hover {
            background: #e0e0e0;
        }

        .search-tip {
            background: rgba(168, 159, 145, 0.1);
            padding: 15px;
            border-radius: 12px;
            text-align: center;
            font-size: 14px;
            color: #666;
        }

        .search-results-panel {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-top: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            display: none;
        }

        .search-results-panel.show {
            display: block;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .search-results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .search-results-title {
            font-size: 22px;
            font-weight: 700;
            color: #333;
            margin: 0;
        }

        .close-results-btn {
            background: none;
            border: none;
            font-size: 28px;
            color: #999;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .close-results-btn:hover {
            color: #333;
        }

        .result-info-box {
            background: #f8f5f2;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 15px;
        }

        .result-info-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }

        .result-info-value {
            font-size: 16px;
            font-weight: 600;
            color: #333;
        }

        .result-tag {
            display: inline-block;
            background: #a89f91;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            margin: 5px;
            font-size: 14px;
            font-weight: 500;
        }

        .search-button-container {
            text-align: center;
            margin-bottom: 25px;
        }
    </style>    
</head>
<body class="homepage">
<button id="backToTop" class="back-to-top" onclick="scrollToTop()">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 4l-8 8h5v8h6v-8h5z" />
    </svg>
</button>

<!-- 搜尋彈窗背景遮罩 -->
<div class="search-modal-overlay" id="searchOverlay" onclick="closeSearchModal()"></div>

<!-- 搜尋彈窗 -->
<div class="search-modal" id="searchModal">
    <div class="search-modal-header">
        <div>
            <h2 class="search-modal-title">穿搭靈感搜尋</h2>
            <p class="search-modal-subtitle">找到你的專屬風格</p>
        </div>
        <button class="search-modal-close" onclick="closeSearchModal()">×</button>
    </div>
    
    <div class="search-modal-body">
        <div class="search-input-wrapper">
            <input type="text" id="searchKeyword" class="search-input" placeholder="搜尋穿搭關鍵字..." onkeypress="handleSearchEnter(event)">
            <svg class="search-icon" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
            </svg>
        </div>

        <div class="selected-tags-container" id="selectedTagsContainer">
            <span style="font-size: 13px; color: #666;">已選擇：</span>
            <span id="selectedTagsList"></span>
        </div>

        <div style="margin-bottom: 15px;">
            <label style="font-size: 14px; font-weight: 600; color: #666; margin-bottom: 12px; display: block;">快速選擇風格：</label>
            <div class="style-tags-grid" id="styleTagsGrid">
                <button class="style-tag-btn" onclick="toggleStyleTag('韓系', this)">
                    <span class="style-tag-emoji">🇰🇷</span>
                    <span class="style-tag-label">韓系</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('日系', this)">
                    <span class="style-tag-emoji">🇯🇵</span>
                    <span class="style-tag-label">日系</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('歐美風', this)">
                    <span class="style-tag-emoji">👔</span>
                    <span class="style-tag-label">歐美風</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('街頭風', this)">
                    <span class="style-tag-emoji">🛹</span>
                    <span class="style-tag-label">街頭風</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('休閒', this)">
                    <span class="style-tag-emoji">👟</span>
                    <span class="style-tag-label">休閒</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('正式', this)">
                    <span class="style-tag-emoji">💼</span>
                    <span class="style-tag-label">正式</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('運動風', this)">
                    <span class="style-tag-emoji">⚽</span>
                    <span class="style-tag-label">運動風</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('復古', this)">
                    <span class="style-tag-emoji">📻</span>
                    <span class="style-tag-label">復古</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('極簡', this)">
                    <span class="style-tag-emoji">⚪</span>
                    <span class="style-tag-label">極簡</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('甜美', this)">
                    <span class="style-tag-emoji">🎀</span>
                    <span class="style-tag-label">甜美</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('暗黑', this)">
                    <span class="style-tag-emoji">🖤</span>
                    <span class="style-tag-label">暗黑</span>
                </button>
                <button class="style-tag-btn" onclick="toggleStyleTag('學院風', this)">
                    <span class="style-tag-emoji">🎓</span>
                    <span class="style-tag-label">學院風</span>
                </button>
            </div>
        </div>

        <div class="search-actions">
            <button class="btn-perform-search" onclick="performSearch()">開始搜尋</button>
            <button class="btn-clear-search" onclick="clearSearch()">清除</button>
        </div>

        <div class="search-tip">
            💡 提示：可以輸入關鍵字或選擇多個風格標籤來找到最適合你的穿搭靈感
        </div>

        <div class="search-results-panel" id="searchResultsPanel">
            <div class="search-results-header">
                <h3 class="search-results-title">搜尋結果</h3>
                <button class="close-results-btn" onclick="closeResults()">×</button>
            </div>
            
            <div class="result-info-box">
                <div class="result-info-label">搜尋關鍵字：</div>
                <div class="result-info-value" id="resultKeyword">無</div>
            </div>
            
            <div class="result-info-box" id="resultTagsBox" style="display: none;">
                <div class="result-info-label">選擇的風格：</div>
                <div id="resultTagsList"></div>
            </div>
            
            <div style="text-align: center; padding: 20px; color: #999;">
                <p>📸 這裡將顯示符合條件的穿搭靈感...</p>
            </div>
        </div>
    </div>
</div>

<section id="billboard" class="bg-light py-5">
    <section class="slide" id="Posts">
        <div class="container">
            <!-- 搜尋按鈕 -->
            <div class="search-button-container">
                <button class="search-main-button" onclick="openSearchModal()">
                    <svg width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <span>穿搭靈感搜尋</span>
                </button>
            </div>

            <div class="row justify-content-center">
                <h1 class="section-title text-center mt-4" data-aos="fade-up">New Posts</h1>
            </div>
            <div class="row">
                <div class="swiper main-swiper py-4" data-aos="fade-up" data-aos-delay="600">
                    <div class="swiper-wrapper d-flex border-animation-left">
                        <% int num=1;                       
                        while(rs.next()){ 
                        	String wearId = rs.getString("wearId");%>
                            <div class="swiper-slide">
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
                                        <p class="post-description"><%=rs.getString("memberId") %><%=rs.getString("wearId") %></p>
                                        <div class="post-actions">
                                            <div class="action-icons">
                                                <a href="#" class="action-icon like-icon" onclick="toggleLike(this)">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="feather feather-heart">
                                                        <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"></path>
                                                    </svg>
                                                </a>
                                                <a href="#" class="action-icon comment-icon" onclick="toggleComment(this)">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="feather feather-message-circle">
                                                        <path d="M21 11.5a8.5 8.5 0 1 0-13.971 6.607l-3.75 3.75a1 1 0 0 0-.23 1.082A1 1 0 0 0 4 21h4.582a8.5 8.5 0 0 0 12.418-9.5z"></path>
                                                    </svg>
                                                </a>
                                                <a href="#" class="action-icon star-icon" onclick="toggleStar(this)">
                                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="feather feather-star">
                                                        <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"></path>
                                                    </svg>
                                                </a>
                                            </div>
                                            <div class="action-text">
                                                <span class="likes-count"><%=rs.getInt("like") %></span>&nbsp;                                                  
                                              <span class="comments-count">
                                <% 
                                    String messageQuery = "SELECT COUNT(*) AS message_count FROM personal_wear WHERE wearId = ? AND message IS NOT NULL AND TRIM(message) != ''";
                                    PreparedStatement pstmt2 = con.prepareStatement(messageQuery);
                                    pstmt2.setString(1, wearId);
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
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <%}%>
                    </div>
                    
                    <div class="modal" id="commentModal" style="display: none;">
                        <div class="modal-content">
                            <span class="close" onclick="closeModal()">&times;</span>
 <% 
    String wearId = request.getParameter("wearId");

    if (wearId != null && !wearId.isEmpty()) {
        String commentQuery = "SELECT message FROM personal_wear WHERE wearId = ?";
        PreparedStatement mes = con.prepareStatement(commentQuery);
        mes.setString(1, wearId);
        ResultSet commentRs = mes.executeQuery();
%>

<div id="commentDisplay" class="comment-display">
    <h3>留言內容：</h3>
    <ul id="commentList">
        <% 
            while (commentRs.next()) {
        %>
            <li>
                <%= commentRs.getString("message") %>
            </li>
        <% 
            } 
        %>
    </ul>
</div>

<% 
        if (commentRs != null) commentRs.close();
        if (mes != null) mes.close();
    }
%>

<%
String newWearId = null;
String newQuery = "SELECT * FROM personal_wear";

Statement newStmt = con.createStatement();
ResultSet newRs = newStmt.executeQuery(newQuery);

if (newRs.next()) {
    newWearId = newRs.getString("wearId");
}

if (newRs != null) newRs.close();
if (newStmt != null) newStmt.close();
%>

                            <form name="form" action="update.jsp" method="post">                          
            <textarea name="text" id="commentText" placeholder="請輸入您的留言..." rows="5"></textarea>
               <input type="hidden" name="memberId" value="<%= member %>">
            <input type="hidden" name="wearId" value="<%= newWearId %>">
            <button type="submit" name="submitButton" onclick="submitComment()">提交留言</button>
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

<script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>
<script>
    // 搜尋功能相關變數
    let selectedTags = [];

    // 開啟搜尋彈窗
    function openSearchModal() {
        document.getElementById('searchModal').classList.add('active');
        document.getElementById('searchOverlay').classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    // 關閉搜尋彈窗
    function closeSearchModal() {
        document.getElementById('searchModal').classList.remove('active');
        document.getElementById('searchOverlay').classList.remove('active');
        document.body.style.overflow = 'auto';
    }

    // 切換風格標籤選擇
    function toggleStyleTag(tagName, element) {
        if (selectedTags.includes(tagName)) {
            selectedTags = selectedTags.filter(t => t !== tagName);
            element.classList.remove('selected');
        } else {
            selectedTags.push(tagName);
            element.classList.add('selected');
        }
        updateSelectedTagsDisplay();
    }

    // 更新已選擇標籤顯示
    function updateSelectedTagsDisplay() {
        const container = document.getElementById('selectedTagsContainer');
        const tagsList = document.getElementById('selectedTagsList');
        
        if (selectedTags.length > 0) {
            container.classList.add('show');
            tagsList.innerHTML = selectedTags.map(tag => 
                `<span class="selected-tag">${tag}<button class="remove-tag-btn" onclick="removeTag('${tag}')">×</button></span>`
            ).join('');
        } else {
            container.classList.remove('show');
        }
    }

    // 移除單個標籤
    function removeTag(tagName) {
        selectedTags = selectedTags.filter(t => t !== tagName);
        const buttons = document.querySelectorAll('.style-tag-btn');
        buttons.forEach(btn => {
            if (btn.textContent.includes(tagName)) {
                btn.classList.remove('selected');
            }
        });
        updateSelectedTagsDisplay();
    }

    // 執行搜尋
    function performSearch() {
        const keyword = document.getElementById('searchKeyword').value.trim();
        const resultsPanel = document.getElementById('searchResultsPanel');
        const resultKeyword = document.getElementById('resultKeyword');
        const resultTagsBox = document.getElementById('resultTagsBox');
        const resultTagsList = document.getElementById('resultTagsList');
        
        resultKeyword.textContent = keyword || '無';
        
        if (selectedTags.length > 0) {
            resultTagsBox.style.display = 'block';
            resultTagsList.innerHTML = selectedTags.map(tag => 
                `<span class="result-tag">${tag}</span>`
            ).join('');
        } else {
            resultTagsBox.style.display = 'none';
        }
        
        resultsPanel.classList.add('show');
    }

    // 關閉搜尋結果
    function closeResults() {
        document.getElementById('searchResultsPanel').classList.remove('show');
    }

    // 清除搜尋
    function clearSearch() {
        document.getElementById('searchKeyword').value = '';
        selectedTags = [];
        const buttons = document.querySelectorAll('.style-tag-btn');
        buttons.forEach(btn => btn.classList.remove('selected'));
        updateSelectedTagsDisplay();
        closeResults();
    }

    // Enter鍵觸發搜尋
    function handleSearchEnter(event) {
        if (event.key === 'Enter') {
            performSearch();
        }
    }

    // 回到頂部
    function scrollToTop() {
        window.scrollTo({
            top: 0, 
            behavior: 'smooth'
        });
    }

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

    // 點贊功能
    function toggleLike(element) {
        const icon = element.querySelector('svg path');
        icon.style.fill = icon.style.fill === 'red' ? 'none' : 'red';

        const likeCountElement = element.closest('.post-actions').querySelector('.likes-count');
        let likeCount = parseInt(likeCountElement.textContent);
        likeCountElement.textContent = (icon.style.fill === 'red') ? likeCount + 1 : likeCount - 1;
    }

    // 留言功能
    function toggleComment(element) {
        document.getElementById('commentModal').style.display = 'flex';
    }

    // 關閉留言模態框
    function closeModal() {
        document.getElementById('commentModal').style.display = 'none';
    }

    // 提交留言功能
    function submitComment() {
        const commentText = document.getElementById('commentText').value;
        if (commentText.trim() !== "") {
            const commentList = document.getElementById('commentList');
            const newComment = document.createElement('li');
            newComment.textContent = commentText;
            commentList.appendChild(newComment);

            const commentCountElement = document.querySelector('.comments-count');
            let commentCount = parseInt(commentCountElement.textContent);
            commentCountElement.textContent = commentCount + 1;

            document.getElementById('commentDisplay').style.display = 'block'; 
            document.getElementById('commentText').value = "";
            alert("留言提交成功！");
        } else {
            alert("請輸入留言內容！");
        }
    }

    // 收藏功能
    function toggleStar(element) {
        const icon = element.querySelector('svg path');
        icon.style.fill = icon.style.fill === 'yellow' ? 'none' : 'yellow';

        const starCountElement = element.closest('.post-actions').querySelector('.stars-count');
        let starCount = parseInt(starCountElement.textContent);
        starCountElement.textContent = (icon.style.fill === 'yellow') ? starCount + 1 : starCount - 1;
    }
</script>

<style>
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
        padding: 8px;
        border-bottom: 1px solid #ddd;
        margin-bottom: 10px;
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
        background-color: #a89f91;
        color: #fff;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 16px;
    }
    button:hover {
        background-color: #8f8c7f;
    }

    .likes-count-container, .comments-count-container, .stars-count-container {
        text-align: center;
        margin-top: 5px;
    }
    .likes-text, .comments-text, .stars-text {
        font-size: 12px;
        color: #555;
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
</style>


  <section id="new-arrival" class="new-arrival product-carousel py-5 position-relative overflow-hidden">
  <div class="container">
    <div class="section-header text-center mt-5">
    <section id="Same style">
      <h3 class="text-uppercase">同款服飾</h3>     
    </div>

    <div class="swiper product-swiper open-up" data-aos="zoom-out">
      <div class="swiper-wrapper d-flex">

        <div class="swiper-slide">
          <div class="product-item image-zoom-effect link-effect">
            <div class="image-holder position-relative">
              <a href="index1.jsp">
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

        <div class="swiper-slide">
          <div class="product-item image-zoom-effect link-effect">
            <div class="image-holder position-relative">
              <a href="index2.jsp">
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

        <div class="swiper-slide">
          <div class="product-item image-zoom-effect link-effect">
            <div class="image-holder position-relative">
              <a href="index3.jsp">
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

        <div class="swiper-slide">
          <div class="product-item image-zoom-effect link-effect">
            <div class="image-holder position-relative">
              <a href="index4.jsp">
                <img src="images\C.jpg" alt="Outfit 4" class="product-image img-fluid">
              </a>
              <a href="https://reurl.cc/kMakNq" class="product-link" style="position: absolute; top: 60%; left: 35%;">
                <div class="product-tag">連帽棉外套-黑<br>$880</div>
              </a>
            </div>
          </div>
        </div>

        <div class="swiper-slide">
          <div class="product-item image-zoom-effect link-effect">
            <div class="image-holder position-relative">
              <a href="index5.jsp">
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
       
        <div class="swiper-slide">
          <div class="product-item image-zoom-effect link-effect">
            <div class="image-holder position-relative">
              <a href="index6.jsp">
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
                <a href="index1.jsp">
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
                <a href="Posts.jsp" class="item-anchor">上傳貼文</a>
              </li>
              <li class="menu-item">
                <a href="#Posts" class="item-anchor">貼文</a>
              </li>
              <li class="menu-item">
                <a href="#Same style" class="item-anchor">同款服飾</a>
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
  
</body>

</html>