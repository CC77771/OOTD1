<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>  
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>CZ Web</title>
  <!-- Template CSS -->
  <link rel="stylesheet" href="webapp/style.css">
  <meta name="keywords" content="CZ">
  <meta name="description" content="This is for example.">
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
<style>
/* 🔧 移除 body 預設 margin，讓 header 對齊頂部 */
body {
    margin: 0 !important;
    padding: 0 !important;
}

/* 🔒 鎖住 header 排版，避免 logo 被擠動 */
.w3l-header .navbar .container-fluid > .row {
    display: flex;
    align-items: center;
    justify-content: space-between !important;
    width: 100%;
    margin: 0;
}

/* 🔒 固定 logo 尺寸，避免圖片大小導致 layout 改變 */
.w3l-header .navbar-brand img {
    width: 220px !important;
    height: 40px !important;
    object-fit: contain;
    display: block;
}

/* 🛡 防止 Bootstrap 或其他頁面的 CSS 蓋掉你的設定 */
.w3l-header .navbar {
    flex-wrap: nowrap !important;
}

/* 🔧 修復 col-auto 在某些頁面被壓縮造成跑版 */
.w3l-header .col-auto {
    display: flex;
    align-items: center;
}

/* 🔍 搜索图标样式 */
.simple-search-icon {
    width: 40px;
    height: 40px;
    background: transparent;
    border: 2px solid #a89f91;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    margin-right: 15px;
}

.simple-search-icon:hover {
    background: #a89f91;
    transform: scale(1.1);
}

.simple-search-icon:hover svg {
    stroke: white;
}

.simple-search-icon svg {
    stroke: #a89f91;
    transition: all 0.3s ease;
}

/* 搜索弹窗样式 */
.search-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(5px);
    z-index: 10000;
    display: none;
    align-items: flex-start;
    justify-content: center;
    padding-top: 80px;
}

.search-modal-overlay.active {
    display: flex;
}

.search-modal-content {
    background: white;
    border-radius: 20px;
    max-width: 600px;
    width: 90%;
    padding: 30px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    animation: slideDown 0.3s ease;
}

@keyframes slideDown {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.search-modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.search-modal-header h3 {
    margin: 0;
    color: #333;
    font-size: 24px;
}

.close-search-modal {
    background: transparent;
    border: 2px solid #ddd;
    width: 35px;
    height: 35px;
    border-radius: 50%;
    cursor: pointer;
    font-size: 24px;
    color: #666;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
}

.close-search-modal:hover {
    background: #a89f91;
    border-color: #a89f91;
    color: white;
    transform: rotate(90deg);
}

.search-input-group {
    position: relative;
    width: 100%;
    margin-bottom: 25px;
}

.search-input {
    width: 100%;
    padding: 15px 55px 15px 20px;
    border: 2px solid #ddd;
    border-radius: 25px;
    font-size: 15px;
    transition: all 0.3s ease;
    background: #f8f8f8;
}

.search-input:focus {
    outline: none;
    border-color: #a89f91;
    background: #fff;
    box-shadow: 0 2px 8px rgba(168, 159, 145, 0.15);
}

.search-button {
    position: absolute;
    right: 5px;
    top: 50%;
    transform: translateY(-50%);
    background: #a89f91;
    border: none;
    border-radius: 50%;
    width: 45px;
    height: 45px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
}

.search-button:hover {
    background: #9b8e82;
    transform: translateY(-50%) scale(1.05);
}

.search-button svg {
    stroke: white;
}

.dropdown-section {
    margin-top: 20px;
}

.dropdown-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    font-weight: 600;
    color: #666;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid #eee;
}

.dropdown-title svg {
    stroke: #a89f91;
}

.dropdown-list {
    list-style: none;
    padding: 0;
    margin: 0;
    max-height: 300px;
    overflow-y: auto;
}

.dropdown-list li {
    padding: 12px 15px;
    cursor: pointer;
    border-radius: 8px;
    transition: all 0.2s ease;
    color: #333;
    font-size: 14px;
}

.dropdown-list li:hover {
    background: #f5f5f5;
    color: #a89f91;
    transform: translateX(5px);
}

@media (max-width: 768px) {
    .search-modal-content {
        width: 95%;
        padding: 20px;
    }
    
    .search-modal-header h3 {
        font-size: 20px;
    }
    
    .simple-search-icon {
        width: 35px;
        height: 35px;
        margin-right: 10px;
    }
}
</style>
    
</head>
<body>
<form method="post" action="logout.jsp">
  <header class="w3l-header">
    <nav class="navbar navbar-expand-lg bg-light text-uppercase fs-6 p-3 border-bottom align-items-center">
      <div class="container-fluid">
        <div class="row justify-content-between align-items-center w-100">
          <!-- Logo -->
          <div class="col-auto">
            <a class="navbar-brand text-white" href="index1.jsp">
              <img src="images/main-logo.png" width="220" height="40" alt="Main Logo">
            </a>
          </div>

          <!-- 中间菜单区 -->
          <div class="col d-flex justify-content-center">
            <button class="navbar-toggler" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasNavbar" aria-controls="offcanvasNavbar">
              <span class="navbar-toggler-icon"></span>
            </button>
            <div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel">
              <div class="offcanvas-header">
                <h5 class="offcanvas-title" id="offcanvasNavbarLabel">Menu</h5>
                <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
              </div>
              <div class="offcanvas-body">
                <ul class="navbar-nav justify-content-center flex-grow-1 gap-1 gap-md-5 pe-3">
                  
                  <!-- 體型建議 -->
                  <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle active" href="#" id="dropdownBodyTypeSuggestions" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">體型建議</a>
                    <ul class="dropdown-menu" aria-labelledby="dropdownBodyTypeSuggestions">
                      <li><a href="index1.jsp#Inverted_Triangle" class="dropdown-item">倒三角型</a></li>
                      <li><a href="index1.jsp#Rectangle" class="dropdown-item">矩型</a></li>
                      <li><a href="index1.jsp#Apple" class="dropdown-item">蘋果型</a></li>
                      <li><a href="index1.jsp#Pear" class="dropdown-item">梨型</a></li>
                      <li><a href="index1.jsp#Hourglass" class="dropdown-item">沙漏型</a></li>
                    </ul>
                  </li>                  

                  <!-- 穿搭展示區 -->
                  <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="dropdownWearExhibitionArea" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">穿搭展示區</a>
                    <ul class="dropdown-menu" aria-labelledby="dropdownWearExhibitionArea">                     
                      <li><a href="index1.jsp#Posts" class="dropdown-item">貼文</a></li>
                      <li><a href="index1.jsp#Same style" class="dropdown-item">穿搭推薦</a></li>
                    </ul>
                  </li>

                  <!-- 穿搭分享獎勵 -->
                  <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="dropdownReward" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">穿搭分享獎勵</a>
                    <ul class="dropdown-menu" aria-labelledby="dropdownReward">
                      <li><a href="index1.jsp#Reward&Method" class="dropdown-item">活動方法</a></li>
                      <li><a href="index1.jsp#Reward&Method" class="dropdown-item">活動獎勵</a></li>
                    </ul>
                  </li>
                  
                  <!-- 管理者控制台 (只有管理員可見) -->
                  <% 
                    String positionId = (String) session.getAttribute("positionId");
                    if("1".equals(positionId)) { 
                  %>
                  <li class="nav-item">
                    <a class="nav-link" href="manager3.jsp">管理者控制台</a>
                  </li>
                  <% } %>

                  <!-- 品牌合作方控制台 (只有商家可見) -->
                  <% 
                    if("4".equals(positionId)) { 
                  %>
                  <li class="nav-item">
                    <a class="nav-link" href="merchant.jsp">品牌合作方控制台</a>
                  </li>
                  <% } %>
                
                </ul>
              </div>
            </div>
          </div>

          <!-- 右侧：搜索 + 登入 -->
          <div class="col-auto d-flex align-items-center gap-2">
            <!-- 搜索图标 -->
            <button type="button" class="simple-search-icon" onclick="toggleSearchModal()" title="搜索">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/>
                <path d="m21 21-4.35-4.35"/>
              </svg>
            </button>
            
            <!-- 会员名称 -->
            <% if(session.getAttribute("accessId") != null){ %>
              <a class="nav-link" href="member.jsp?memberId=<%=session.getAttribute("accessId")%>" style="white-space: nowrap;">
                <%=session.getAttribute("accessId")%>
              </a>
              <input type="submit" value="登出" name="login" class="btn btn-style btn-effect px-3 py-1">
            <% } else { %>
              <a class="text-uppercase align-items-center" href="login.jsp" style="white-space: nowrap;">登入</a>
            <% } %>
          </div>

        </div>
      </div>
    </nav>
  </header>
</form>

<!-- 🔍 搜索弹窗 -->
<div class="search-modal-overlay" id="searchModalOverlay">
    <div class="search-modal-content">
        <div class="search-modal-header">
            <h3>搜索商品</h3>
            <button class="close-search-modal" onclick="toggleSearchModal()">×</button>
        </div>
        
        <div class="search-input-group">
            <input 
                type="text" 
                class="search-input" 
                placeholder="搜尋商品、品牌或關鍵字..." 
                id="modalSearchInput"
            >
            <button class="search-button" onclick="performSearchFromModal()">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="8"/>
                    <path d="m21 21-4.35-4.35"/>
                </svg>
            </button>
        </div>
        
        <div class="dropdown-section">
            <div class="dropdown-title">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="9 11 12 14 22 4"/>
                    <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                </svg>
                熱門搜尋
             </div>
            <ul class="dropdown-list">
    <li onclick="selectSearchFromModal('休閒風')">🌿 休閒風</li>
    <li onclick="selectSearchFromModal('正式風')">👔 正式風</li>
    <li onclick="selectSearchFromModal('運動風')">⚽ 運動風</li>
    <li onclick="selectSearchFromModal('韓系')">🇰🇷 韓系</li>
    <li onclick="selectSearchFromModal('日系')">🇯🇵 日系</li>
    <li onclick="selectSearchFromModal('復古風')">📻 復古風</li>
    <li onclick="selectSearchFromModal('甜美風')">💖 甜美風</li>
    <li onclick="selectSearchFromModal('簡約風')">✨ 簡約風</li>
</ul>
        </div>
    </div>
</div>

<script>
// 切换搜索弹窗显示/隐藏
function toggleSearchModal() {
    const modal = document.getElementById('searchModalOverlay');
    if (modal.classList.contains('active')) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    } else {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
        setTimeout(() => {
            document.getElementById('modalSearchInput').focus();
        }, 100);
    }
}

//从弹窗执行搜索
function performSearchFromModal() {
    const keyword = document.getElementById('modalSearchInput').value.trim();
    if (keyword) {
        // 跳轉到搜索結果頁面
        window.location.href = 'SearchResults.jsp?keyword=' + encodeURIComponent(keyword);
        toggleSearchModal();
    } else {
        alert('請輸入搜索關鍵字');
    }
}

// 从弹窗选择搜索项目
function selectSearchFromModal(keyword) {
    if (keyword) {
        // 直接跳轉到搜索結果頁面
        window.location.href = 'SearchResults.jsp?keyword=' + encodeURIComponent(keyword);
        toggleSearchModal();
    }
}
// 按下 Enter 键执行搜索
document.addEventListener('DOMContentLoaded', function() {
    const input = document.getElementById('modalSearchInput');
    if (input) {
        input.addEventListener('keypress', function(event) {
            if (event.key === 'Enter') {
                performSearchFromModal();
            }
        });
    }
});

// 点击弹窗外部关闭
document.addEventListener('click', function(event) {
    const modal = document.getElementById('searchModalOverlay');
    if (event.target === modal) {
        toggleSearchModal();
    }
});

// ESC 键关闭弹窗
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('searchModalOverlay');
        if (modal && modal.classList.contains('active')) {
            toggleSearchModal();
        }
    }
});
</script>

<script src="js/jquery.min.js"></script>
<script src="js/plugins.js"></script>
<script src="js/SmoothScroll.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"
  integrity="sha384-ENjdO4Dr2bkBIFxQpeoTz1HIcje39Wm4jDKdf19U8gI4ddQ3GYNS7NTKfAdVQSZe"
  crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>
<script src="js/script.min.js"></script>
</body>
</html>