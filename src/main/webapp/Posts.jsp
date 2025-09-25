<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file="menu.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Responsive Post Upload</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f8f8;
        }

        /* 主容器，包含導航欄和主要內容 */
        .main-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }

        /* 將內容居中 */
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
    margin-left: 200px; /* 将表单向右移动一点 */
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
        }

        .upload-image:hover {
            background-color: #f5ebe2;
        }

        .upload-image input[type="file"] {
            display: none;
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
        <!-- 包含 menu.jsp 的導航部分 -->
        <div class="content-wrapper">
            <div class="upload-container">
                <div class="upload-header">上傳貼文</div>
                <div class="upload-body">
                    <form name="form" action="uploadPicToDatabase.jsp" method="post" enctype="multipart/form-data">
    <!-- Image Upload -->
    <!-- 图片预览容器 -->
 <input type="file" name="pic"  required>
    <!-- Description -->
    <div class="upload-description">
        <label for="description">新增文字:</label>
        <textarea id="description" name="wearId" placeholder="有什麼想法..."></textarea>
    </div>
<p>
    <!-- Hidden memberId field -->
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
    <script>
        const fileInput = document.getElementById("fileInput");
        const filePlaceholder = document.getElementById("filePlaceholder");

        // Update placeholder when image is selected
        fileInput.addEventListener("change", function () {
            if (fileInput.files.length > 0) {
                filePlaceholder.textContent = fileInput.files[0].name;
            } else {
                filePlaceholder.textContent = "Click to upload an image";
            }
        });
        
        
        // Cancel post function
        function cancelPost() {
            fileInput.value = ""; // Clear file input
            filePlaceholder.textContent = "Click to upload an image";
            document.getElementById("description").value = ""; // Clear description
        }

        // Post content function (fake)
        function postContent() {
            const fileName = fileInput.files.length > 0 ? fileInput.files[0].name : "No file selected";
            const description = document.getElementById("description").value || "No description";
            alert(`Posted!\nImage: ${fileName}\nCaption: ${description}`);
            cancelPost(); // Reset the form
        }
    </script>
</body>
</html>
