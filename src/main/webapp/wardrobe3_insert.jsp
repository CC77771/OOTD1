<%@page contentType="text/html"%>
<%@page pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<title>新增衣物資料</title>
<style>
body {
    font-family: 'Microsoft JhengHei', Arial, Helvetica, sans-serif;
    background-color: #fafbfc;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    margin: 0;
    padding: 20px;
}

form {
    border: 3px solid #c4b5a0;
    background: white;
    border-radius: 20px;
    max-width: 600px;
    width: 100%;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.container {
    padding: 30px;
}

h1 {
    color: #2c3e50;
    margin-bottom: 10px;
}

hr {
    border: none;
    border-top: 2px solid #f0f0f0;
    margin: 20px 0;
}

label {
    font-weight: bold;
    color: #555;
    display: block;
    margin-bottom: 8px;
    font-size: 14px;
}

input[type=text], input[type=file], select {
    width: 100%;
    padding: 14px 16px;
    margin: 8px 0 20px 0;
    display: inline-block;
    border: 1px solid #e0e0e0;
    box-sizing: border-box;
    border-radius: 10px;
    font-size: 15px;
    font-family: 'Microsoft JhengHei', Arial, sans-serif;
    transition: all 0.3s;
}

input[type=text]:focus, select:focus {
    outline: none;
    border-color: #c4b5a0;
    box-shadow: 0 0 0 3px rgba(196, 181, 160, 0.1);
}

select {
    cursor: pointer;
}

.image-upload-section {
    margin: 20px 0;
}

.image-preview-container {
    width: 100%;
    height: 300px;
    background-color: #f8f8f8;
    border: 2px dashed #ddd;
    border-radius: 15px;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    margin-bottom: 10px;
    overflow: hidden;
    position: relative;
    transition: all 0.3s;
}

.image-preview-container:hover {
    border-color: #c4b5a0;
    background-color: #fafafa;
}

.upload-placeholder {
    text-align: center;
    color: #999;
}

.upload-icon {
    font-size: 48px;
    margin-bottom: 10px;
}

#previewImage {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
    display: none;
}

.change-text {
    position: absolute;
    bottom: 10px;
    background: rgba(0, 0, 0, 0.6);
    color: white;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 14px;
    display: none;
}

input[type=file] {
    display: none;
}

.clearfix {
    display: flex;
    gap: 12px;
    margin-top: 30px;
}

button {
    flex: 1;
    color: white;
    padding: 16px;
    margin: 0;
    border: none;
    cursor: pointer;
    border-radius: 25px;
    font-size: 16px;
    font-weight: bold;
    transition: all 0.3s;
}

.signupbtn {
    background-color: #c4b5a0;
}

.signupbtn:hover {
    background-color: #a89f91;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(196, 181, 160, 0.3);
}

.cancelbtn {
    background-color: #e0e0e0;
    color: #666;
}

.cancelbtn:hover {
    background-color: #d0d0d0;
}
</style>
</head>
<body>
<form action="wardrobe3_DB.jsp" method="post" enctype="multipart/form-data" style="border:1px solid #ccc">
<div class="container">
<h1>新增衣物資料</h1>
<hr>

<div class="image-upload-section">
<label><b>📷 點擊更換圖片</b></label>
<div class="image-preview-container" onclick="document.getElementById('clothingImage').click()">
    <div class="upload-placeholder" id="uploadPlaceholder">
        <div class="upload-icon">📷</div>
        <div>點擊更換圖片</div>
    </div>
    <img id="previewImage" alt="預覽圖片">
    <div class="change-text" id="changeText">點擊更換圖片</div>
</div>
<input type="file" id="clothingImage" name="clothingImage" accept="image/*" required onchange="previewImage(event)">
</div>

<input type="hidden" name="memberId" value="1">

<label for="text_description"><b>衣物名稱</b></label>
<input type="text" placeholder="例如:白色T恤" name="text_description" required>

<label for="clothing_code"><b>品牌</b></label>
<input type="text" placeholder="例如:UNIQLO" name="clothing_code">

<label for="color_code"><b>顏色</b></label>
<input type="text" placeholder="例如:白色" name="color_code">

<label for="types_of_clothes"><b>分類</b></label>
<select name="types_of_clothes" required>
    <option value="">請選擇分類</option>
    <option value="衣服">衣服</option>
    <option value="褲子">褲子</option>
    <option value="裙子">裙子</option>
    <option value="連身裙/褲">連身裙/褲</option>
    <option value="配件">配件</option>
    <option value="鞋子">鞋子</option>
</select>

<div class="clearfix">
<button type="submit" class="signupbtn">儲存</button>
<button type="reset" class="cancelbtn">取消</button>
</div>
</div>
</form>

<script>
function previewImage(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    if (!file.type.startsWith('image/')) {
        alert('請選擇圖片檔案！');
        event.target.value = '';
        return;
    }
    
    if (file.size > 50 * 1024 * 1024) {
        alert('圖片檔案過大，請選擇小於 50MB 的圖片！');
        event.target.value = '';
        return;
    }
    
    const reader = new FileReader();
    reader.onload = function(e) {
        const img = document.getElementById('previewImage');
        const placeholder = document.getElementById('uploadPlaceholder');
        const changeText = document.getElementById('changeText');
        
        img.src = e.target.result;
        img.style.display = 'block';
        placeholder.style.display = 'none';
        changeText.style.display = 'block';
    };
    reader.readAsDataURL(file);
}
</script>
</body>
</html>