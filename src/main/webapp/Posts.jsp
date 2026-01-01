<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />

<%
// 處理表單提交
if("POST".equals(request.getMethod())) {
    try {
        // 獲取表單數據
        String memberId = (String) session.getAttribute("accessId");
        String wearId = request.getParameter("wearId");
        String tags = request.getParameter("tags");
        
        // 檢查數據
        if(memberId == null || memberId.trim().isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 暫時使用預設圖片
        String picPath = "images/default-post.jpg";
        
     // 存入資料庫
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");

        // ✅ 修正：加入 tags 欄位
        String sql = "INSERT INTO personal_wear (memberId, wearId, pic, tags, [like], collect, view, post_state) VALUES (?, ?, ?, ?, 0, 0, 0, True)";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, memberId);
        pstmt.setString(2, wearId != null ? wearId : "");
        pstmt.setString(3, picPath);
        pstmt.setString(4, tags != null ? tags : ""); // ✅ 加入標籤參數

        pstmt.executeUpdate();
        pstmt.close();
        con.close();
        
        // 成功後直接重定向
        response.sendRedirect("index1.jsp");
        return;
        
    } catch(Exception e) {
        // 發生錯誤時顯示錯誤訊息
        request.setAttribute("errorMessage", e.getMessage());
        e.printStackTrace();
    }
}
%>

<%@include file="menu.jsp" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Responsive Post Upload</title>
    
    <%
    // 如果有錯誤訊息，顯示出來
    String errorMsg = (String) request.getAttribute("errorMessage");
    if(errorMsg != null) {
    %>
    <script>
        alert('發布失敗: <%= errorMsg.replace("'", "\\'") %>');
    </script>
    <%
    }
    %>
    
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f8f8;
        }

        .main-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }

        .content-wrapper {
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
        }

        .upload-container {
            width: 100%;
            max-width: 400px;
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            margin-top: 20px;
            margin-left: 200px;
        }

        .upload-header {
            background-color: #a89f91;
            color: white;
            text-align: center;
            padding: 20px;
            font-size: 22px;
            font-weight: bold;
        }

        .upload-body {
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .upload-image {
            border: 2px dashed #a89f91;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 200px;
            cursor: pointer;
            color: #888;
            text-align: center;
            transition: background-color 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .upload-image:hover {
            background-color: #f5ebe2;
        }

        .upload-image input[type="file"] {
            display: none;
        }

        .image-preview {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: none;
        }

        .image-preview.show {
            display: block;
        }

        .upload-description {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .upload-description textarea {
            width: 100%;
            height: 100px;
            border: 1px solid #ccc;
            border-radius: 10px;
            padding: 10px;
            font-size: 16px;
            resize: none;
            transition: border 0.3s ease;
        }

        .upload-description textarea:focus {
            border-color: #a89f91;
            outline: none;
        }

        /* 標籤區域樣式 */
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

        .upload-buttons {
            display: flex;
            gap: 10px;
        }

        .upload-buttons button {
            flex: 1;
            padding: 10px 15px;
            font-size: 16px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .cancel-btn {
            background-color: #e0e0e0;
            color: #555;
        }

        .cancel-btn:hover {
            background-color: #d6d6d6;
        }

        .post-btn {
            background-color: #a89f91;
            color: white;
        }

        .post-btn:hover {
            background-color: #8d7c70;
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 10px;
            }

            .upload-container {
                width: 90%;
                margin-top: 10px;
                margin-left: 0;
            }

            .upload-image {
                height: 150px;
            }

            .upload-description textarea {
                height: 80px;
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <div class="content-wrapper">
            <div class="upload-container">
                <div class="upload-header">上傳貼文</div>
                <div class="upload-body">
                    <form name="form" action="Posts.jsp" method="post" enctype="multipart/form-data">
                        <!-- Image Upload -->
                        <div class="upload-image" onclick="document.getElementById('fileInput').click()">
                            <span id="filePlaceholder">點擊上傳圖片</span>
                            <img id="imagePreview" class="image-preview" alt="預覽">
                        </div>
                        <input type="file" id="fileInput" name="pic" accept="image/*" required>
                        
                        <!-- Description -->
                        <div class="upload-description">
                            <label for="description">新增文字:</label>
                            <textarea id="description" name="wearId" placeholder="有什麼想法..."></textarea>
                        </div>

                        <!-- AI 標籤建議區域 -->
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
                        <input type="hidden" name="memberId" value="<%= session.getAttribute("accessId") %>" />

                        <!-- Buttons -->
                        <div class="upload-buttons">
                            <button type="button" class="cancel-btn" onclick="cancelPost()">關閉</button>
                            <button type="submit" class="post-btn">發佈</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        const fileInput = document.getElementById("fileInput");
        const filePlaceholder = document.getElementById("filePlaceholder");
        const imagePreview = document.getElementById("imagePreview");
        const description = document.getElementById("description");
        const analyzeStatus = document.getElementById("analyzeStatus");
        
        let selectedTags = [];
        let suggestedTagsList = [];

        // 預設標籤庫
       const popularTags = ['休閒風', '正式風', '韓系', '日系', '復古風', '運動風', '甜美風', '帥氣風', '簡約風', '波西米亞', '龐克風', '學院風'];

        // 圖片上傳預覽
        fileInput.addEventListener("change", function () {
            if (fileInput.files.length > 0) {
                const file = fileInput.files[0];
                filePlaceholder.style.display = 'none';
                imagePreview.classList.add('show');
                imagePreview.src = URL.createObjectURL(file);
                
                // 觸發 AI 分析
                analyzeContent();
            }
        });

        // 文字輸入時也觸發分析
        let typingTimer;
        description.addEventListener('input', function() {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(analyzeContent, 1000);
        });

        // AI 分析內容（模擬）
        function analyzeContent() {
            const text = description.value.toLowerCase();
            const hasImage = fileInput.files.length > 0;
            
            if (!text && !hasImage) {
                return;
            }

            analyzeStatus.textContent = '🔍 AI 正在分析內容...';
            
            setTimeout(() => {
                const tags = [];
             // 基於文字關鍵字分析 - 服飾風格標籤
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
                if (text.includes('嘻哈') || text.includes('hip hop') || text.includes('寬鬆') || text.includes('oversize') || text.includes('潮流')) {
                    tags.push('嘻哈風');
                }
                if (text.includes('法式') || text.includes('優雅') || text.includes('浪漫') || text.includes('巴黎') || text.includes('chic')) {
                    tags.push('法式風');
                }
                if (text.includes('英倫') || text.includes('紳士') || text.includes('格紋') || text.includes('英式') || text.includes('學院')) {
                    tags.push('英倫風');
                }
                if (text.includes('性感') || text.includes('辣妹') || text.includes('火辣') || text.includes('露肩') || text.includes('低胸')) {
                    tags.push('性感風');
                }
                
                // 如果沒有匹配到，隨機建議一些標籤
                if (tags.length === 0) {
                    const randomTags = popularTags.sort(() => 0.5 - Math.random()).slice(0, 3);
                    tags.push(...randomTags);
                }
                
                // 確保標籤不重複
                suggestedTagsList = [...new Set(tags)];
                
                displaySuggestedTags();
                analyzeStatus.textContent = `✅ 已分析完成，建議 ${suggestedTagsList.length} 個標籤`;
            }, 1500);
        }

     // 顯示建議的標籤
        function displaySuggestedTags() {
            const container = document.getElementById('suggestedTags');
            container.innerHTML = '';
            
            suggestedTagsList.forEach(tag => {
                const tagEl = document.createElement('span');
                tagEl.className = 'tag';
                tagEl.textContent = tag;  // ✅ 這裡不要加 #
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
            
            updateSelectedTagsDisplay();
            displaySuggestedTags();
            updateHiddenInput();
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
                tagEl.innerHTML = `${tag} <span class="tag-remove" onclick="removeTag('${tag}')">×</span>`;
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

        // 更新隱藏欄位（用於表單提交）
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

        // Cancel post function
        function cancelPost() {
            fileInput.value = "";
            filePlaceholder.style.display = 'block';
            filePlaceholder.textContent = "點擊上傳圖片";
            imagePreview.classList.remove('show');
            imagePreview.src = '';
            description.value = "";
            selectedTags = [];
            suggestedTagsList = [];
            analyzeStatus.textContent = '';
            updateSelectedTagsDisplay();
            document.getElementById('suggestedTags').innerHTML = '';
            updateHiddenInput();
        }
    </script>
</body>
</html>