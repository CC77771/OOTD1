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
    <title>編輯貼文 - CZ Web</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f1f0;
            color: #333;
        }

        .container {
            max-width: 800px;
            margin: 40px auto;
            background: #fff;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #a89f91;
        }

        .header h1 {
            font-size: 28px;
            color: #333;
            margin: 0;
        }

        .post-preview {
            text-align: center;
            margin-bottom: 30px;
        }

        .post-preview img {
            max-width: 100%;
            max-height: 400px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            object-fit: contain;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
        }

        .form-group label i {
            margin-right: 8px;
            color: #a89f91;
        }

        .form-group input[type="text"],
        .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            font-size: 15px;
            border: 2px solid #ddd;
            border-radius: 8px;
            box-sizing: border-box;
            transition: border-color 0.3s;
            font-family: inherit;
        }

        .form-group input[type="text"]:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #a89f91;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }

        .form-hint {
            font-size: 13px;
            color: #666;
            margin-top: 5px;
        }

        /* 標籤區域樣式 (跟 Posts.jsp 一樣) */
        .tag-section {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 10px;
            border: 1px solid #e0e0e0;
        }

        .tag-section-header {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: bold;
            color: #555;
            font-size: 14px;
        }

        .ai-icon {
            color: #a89f91;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .suggested-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 10px;
        }

        .tag {
            background-color: #e8e0d5;
            color: #555;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .tag:hover {
            background-color: #d4c4b0;
        }

        .tag.selected {
            background-color: #a89f91;
            color: white;
            border-color: #8d7c70;
        }

        .tag.user-added {
            background-color: #b8c9d9;
            color: white;
        }

        .tag.user-added:hover {
            background-color: #a0b5c7;
        }

        .tag-remove {
            margin-left: 5px;
            cursor: pointer;
            font-weight: bold;
        }

        .selected-tags-display {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            min-height: 30px;
            padding: 10px;
            background-color: white;
            border-radius: 8px;
            border: 1px solid #ddd;
        }

        .custom-tag-input {
            display: flex;
            gap: 5px;
            margin-top: 10px;
        }

        .custom-tag-input input {
            flex: 1;
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 14px;
        }

        .custom-tag-input button {
            padding: 8px 15px;
            background-color: #a89f91;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
        }

        .custom-tag-input button:hover {
            background-color: #8d7c70;
        }

        .analyze-status {
            font-size: 12px;
            color: #666;
            font-style: italic;
            text-align: center;
            padding: 5px;
        }

        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 30px;
            font-size: 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: #a89f91;
            color: #fff;
        }

        .btn-primary:hover {
            background: #8b8d7a;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .btn-secondary {
            background: #6c757d;
            color: #fff;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .loading {
            display: none;
            text-align: center;
            padding: 20px;
        }

        .loading i {
            font-size: 30px;
            color: #a89f91;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @media screen and (max-width: 768px) {
            .container {
                margin: 20px;
                padding: 25px;
            }

            .button-group {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
<%
    String postid = request.getParameter("postid");
    String currentMemberId = (String) session.getAttribute("accessId");
    
    if (postid == null || postid.trim().isEmpty()) {
        response.sendRedirect("member.jsp");
        return;
    }
    
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    
    // 查詢貼文資料
    String sql = "SELECT pw.postid, " +
                 "       FIRST(pw.memberId) as memberId, " +
                 "       FIRST(pw.wearId) as wearId, " +
                 "       FIRST(pw.pic) as pic, " +
                 "       FIRST(pw.tags) as tags " +
                 "FROM personal_wear pw " +
                 "WHERE pw.postid = ? AND pw.post_state = True " +
                 "GROUP BY pw.postid";
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setString(1, postid);
    ResultSet rs = pstmt.executeQuery();
    
    if (!rs.next()) {
        out.println("<script>alert('找不到此貼文!'); window.location.href='member.jsp';</script>");
        rs.close();
        pstmt.close();
        con.close();
        return;
    }
    
    String memberId = rs.getString("memberId");
    
    // 檢查是否為貼文擁有者
    if (!memberId.equals(currentMemberId)) {
        out.println("<script>alert('您沒有權限編輯此貼文!'); window.location.href='member.jsp';</script>");
        rs.close();
        pstmt.close();
        con.close();
        return;
    }
    
    String wearId = rs.getString("wearId");
    String pic = rs.getString("pic");
    String tags = rs.getString("tags");
    
    rs.close();
    pstmt.close();
%>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-edit"></i> 編輯貼文</h1>
    </div>

    <div class="alert alert-success" id="successAlert">
        <i class="fas fa-check-circle"></i> 更新成功!
    </div>

    <div class="alert alert-error" id="errorAlert">
        <i class="fas fa-exclamation-circle"></i> 更新失敗,請稍後再試!
    </div>

    <div class="loading" id="loadingIndicator">
        <i class="fas fa-spinner"></i>
        <p>處理中,請稍候...</p>
    </div>

    <!-- 貼文圖片預覽 -->
    <div class="post-preview">
        <img src="<%= pic %>" alt="Post Image" onerror="this.src='images/default.jpg'">
    </div>

    <!-- 編輯表單 -->
    <form id="editForm" onsubmit="return false;">
        <input type="hidden" name="postid" value="<%= postid %>">
        <input type="hidden" name="memberId" value="<%= currentMemberId %>">

        <!-- 主題 -->
        <div class="form-group">
            <label for="wearId">
                <i class="fas fa-heading"></i> 貼文主題
            </label>
            <input 
                type="text" 
                id="wearId" 
                name="wearId" 
                value="<%= wearId != null ? wearId : "" %>" 
                placeholder="請輸入貼文主題..."
                maxlength="100"
            >
            <div class="form-hint">
                <i class="fas fa-info-circle"></i> 簡短描述這個穿搭的主題或場合
            </div>
        </div>

        <!-- AI 標籤建議區域 (跟 Posts.jsp 一樣) -->
        <div class="tag-section">
            <div class="tag-section-header">
                <span class="ai-icon">✨</span>
                <span>AI 建議標籤</span>
            </div>
            <div id="analyzeStatus" class="analyze-status"></div>
            
            <!-- 建議的標籤 -->
            <div class="suggested-tags" id="suggestedTags"></div>
            
            <!-- 已選擇的標籤顯示 -->
            <div class="selected-tags-display" id="selectedTagsDisplay">
                <span style="color: #999;">尚未選擇標籤</span>
            </div>
            
            <!-- 自訂標籤輸入 -->
            <div class="custom-tag-input">
                <input type="text" id="customTagInput" placeholder="新增自訂標籤..." maxlength="20">
                <button type="button" onclick="addCustomTag()">+</button>
            </div>
        </div>

        <!-- 隱藏欄位：儲存選中的標籤 -->
        <input type="hidden" id="tagsInput" name="tags" value="">

        <!-- 按鈕 -->
        <div class="button-group">
            <button type="button" class="btn btn-secondary" onclick="goBack()">
                <i class="fas fa-times"></i> 取消
            </button>
            <button type="button" class="btn btn-primary" onclick="updatePost()">
                <i class="fas fa-save"></i> 儲存變更
            </button>
        </div>
    </form>
</div>

<script>
// 變數宣告
const wearIdInput = document.getElementById('wearId');
const analyzeStatus = document.getElementById('analyzeStatus');

let selectedTags = [];
let suggestedTagsList = [];

// 預設標籤庫 (跟 Posts.jsp 一樣)
const popularTags = ['休閒風', '正式風', '韓系', '日系', '復古風', '運動風', '甜美風', '帥氣風', '簡約風', '波西米亞', '龐克風', '學院風'];

// 初始化:載入現有標籤
window.addEventListener('DOMContentLoaded', function() {
    const existingTags = '<%= tags != null ? tags : "" %>';
    if (existingTags.trim() !== '') {
        selectedTags = existingTags.split(',').map(tag => tag.trim()).filter(tag => tag !== '');
        updateSelectedTagsDisplay();
        updateHiddenInput();
    }
    
    // 初始分析
    analyzeContent();
});

// 文字輸入時觸發分析
let typingTimer;
wearIdInput.addEventListener('input', function() {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(analyzeContent, 1000);
});

// AI 分析內容（模擬）
function analyzeContent() {
    const text = wearIdInput.value.toLowerCase();
    
    if (!text) {
        displaySuggestedTags();
        return;
    }

    analyzeStatus.textContent = '🔍 AI 正在分析內容...';
    
    setTimeout(() => {
        const tags = [];
        
        // 基於文字關鍵字分析
        if (text.includes('休閒') || text.includes('輕鬆') || text.includes('街頭') || text.includes('日常') || text.includes('舒適')) {
            tags.push('休閒風');
        }
        if (text.includes('正式') || text.includes('西裝') || text.includes('商務') || text.includes('上班') || text.includes('優雅')) {
            tags.push('正式風');
        }
        if (text.includes('韓系') || text.includes('韓風') || text.includes('韓國') || text.includes('韓妞')) {
            tags.push('韓系');
        }
        if (text.includes('日系') || text.includes('日風') || text.includes('日本') || text.includes('無印') || text.includes('森林系')) {
            tags.push('日系');
        }
        if (text.includes('復古') || text.includes('古著') || text.includes('vintage') || text.includes('懷舊') || text.includes('老派')) {
            tags.push('復古風');
        }
        if (text.includes('運動') || text.includes('健身') || text.includes('機能') || text.includes('球鞋') || text.includes('athleisure')) {
            tags.push('運動風');
        }
        if (text.includes('甜美') || text.includes('可愛') || text.includes('少女') || text.includes('粉色') || text.includes('蝴蝶結')) {
            tags.push('甜美風');
        }
        if (text.includes('帥氣') || text.includes('中性') || text.includes('俐落') || text.includes('率性') || text.includes('帥T')) {
            tags.push('帥氣風');
        }
        if (text.includes('簡約') || text.includes('極簡') || text.includes('基本款') || text.includes('素色') || text.includes('minimalist')) {
            tags.push('簡約風');
        }
        if (text.includes('波西米亞') || text.includes('民族') || text.includes('流蘇') || text.includes('度假') || text.includes('boho')) {
            tags.push('波西米亞');
        }
        if (text.includes('龐克') || text.includes('搖滾') || text.includes('暗黑') || text.includes('皮革') || text.includes('punk')) {
            tags.push('龐克風');
        }
        if (text.includes('學院') || text.includes('preppy') || text.includes('學生') || text.includes('校園')) {
            tags.push('學院風');
        }
        
        // 如果沒有匹配到,隨機建議一些標籤
        if (tags.length === 0) {
            const randomTags = popularTags.sort(() => 0.5 - Math.random()).slice(0, 3);
            tags.push(...randomTags);
        }
        
        // 確保標籤不重複
        suggestedTagsList = [...new Set(tags)];
        
        displaySuggestedTags();
        analyzeStatus.textContent = `✅ 已分析完成,建議 ${suggestedTagsList.length} 個標籤`;
    }, 1000);
}

// 顯示建議的標籤
function displaySuggestedTags() {
    const container = document.getElementById('suggestedTags');
    container.innerHTML = '';
    
    suggestedTagsList.forEach(tag => {
        const tagEl = document.createElement('span');
        tagEl.className = 'tag';
        tagEl.textContent = tag;
        tagEl.onclick = () => toggleTag(tag, false);
        
        if (selectedTags.includes(tag)) {
            tagEl.classList.add('selected');
        }
        
        container.appendChild(tagEl);
    });
}

// 切換標籤選擇狀態
function toggleTag(tagName, isCustom) {
    const index = selectedTags.indexOf(tagName);
    
    if (index > -1) {
        selectedTags.splice(index, 1);
    } else {
        selectedTags.push(tagName);
    }
    
    updateHiddenInput();
    updateSelectedTagsDisplay();
    displaySuggestedTags();
}

// 更新已選標籤顯示
function updateSelectedTagsDisplay() {
    const container = document.getElementById('selectedTagsDisplay');
    container.innerHTML = '';
    
    if (selectedTags.length === 0) {
        container.innerHTML = '<span style="color: #999;">尚未選擇標籤</span>';
        return;
    }
    
    selectedTags.forEach(tag => {
        const tagEl = document.createElement('span');
        const isCustom = !suggestedTagsList.includes(tag);
        tagEl.className = isCustom ? 'tag user-added selected' : 'tag selected';
        
        const removeBtn = document.createElement('span');
        removeBtn.className = 'tag-remove';
        removeBtn.textContent = '×';
        removeBtn.onclick = function(e) {
            e.stopPropagation();
            removeTag(tag);
        };
        
        tagEl.textContent = tag + ' ';
        tagEl.appendChild(removeBtn);
        container.appendChild(tagEl);
    });
}

// 移除標籤
function removeTag(tagName) {
    toggleTag(tagName);
}

// 新增自訂標籤
function addCustomTag() {
    const input = document.getElementById('customTagInput');
    const tagName = input.value.trim();
    
    if (tagName && !selectedTags.includes(tagName)) {
        selectedTags.push(tagName);
        updateSelectedTagsDisplay();
        updateHiddenInput();
        input.value = '';
    }
}

// 更新隱藏欄位
function updateHiddenInput() {
    document.getElementById('tagsInput').value = selectedTags.join(',');
}

// 按 Enter 新增自訂標籤
document.getElementById('customTagInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        addCustomTag();
    }
});

// 更新貼文
function updatePost() {
    // ✅ 從 hidden input 讀取 postid
    const postid = document.querySelector('input[name="postid"]').value;
    const wearId = document.getElementById('wearId').value.trim();
    const tags = document.getElementById('tagsInput').value.trim();
    
    console.log('準備提交:', {postid, wearId, tags});
    
    if (!postid) {
        alert('錯誤: postid 不存在!');
        return;
    }
    
    // 顯示載入中
    document.getElementById('loadingIndicator').style.display = 'block';
    document.getElementById('editForm').style.display = 'none';
    
    // ✅ 使用 URLSearchParams 而不是 FormData
    const params = new URLSearchParams();
    params.append('postid', postid);
    params.append('wearId', wearId);
    params.append('tags', tags);
    
    console.log('提交參數:', params.toString());
    
    fetch('updatePost.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        },
        body: params.toString()
    })
    .then(response => response.text())
    .then(data => {
        console.log('伺服器回應:', data);
        
        document.getElementById('loadingIndicator').style.display = 'none';
        document.getElementById('editForm').style.display = 'block';
        
        if (data.trim() === 'success') {
            const successAlert = document.getElementById('successAlert');
            successAlert.style.display = 'block';
            
            // 重置表單變更標記
            formChanged = false;
            
            setTimeout(function() {
                window.location.href = 'member.jsp';
            }, 1500);
        } else {
            const errorAlert = document.getElementById('errorAlert');
            errorAlert.innerHTML = '<i class="fas fa-exclamation-circle"></i> 更新失敗: ' + data;
            errorAlert.style.display = 'block';
            
            setTimeout(function() {
                errorAlert.style.display = 'none';
            }, 5000);
        }
    })
    .catch(error => {
        console.error('錯誤:', error);
        document.getElementById('loadingIndicator').style.display = 'none';
        document.getElementById('editForm').style.display = 'block';
        
        const errorAlert = document.getElementById('errorAlert');
        errorAlert.innerHTML = '<i class="fas fa-exclamation-circle"></i> 系統錯誤: ' + error.message;
        errorAlert.style.display = 'block';
        
        setTimeout(function() {
            errorAlert.style.display = 'none';
        }, 5000);
    });
}

// 返回上一頁
function goBack() {
    if (confirm('確定要取消編輯嗎?未儲存的變更將會遺失!')) {
        window.location.href = 'member.jsp';
    }
}

// 防止意外離開頁面
let formChanged = false;

document.getElementById('wearId').addEventListener('input', function() {
    formChanged = true;
});

document.getElementById('customTagInput').addEventListener('input', function() {
    formChanged = true;
});

window.addEventListener('beforeunload', function(e) {
    if (formChanged) {
        e.preventDefault();
        e.returnValue = '';
    }
});
</script>

<%
    con.close();
%>

</body>
</html>