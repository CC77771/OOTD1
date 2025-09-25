<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>服裝店管理</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            height: 100vh;
            background-color: #f5f5f5;
        }
        .sidebar {
            width: 20%;
            background-color: #fff;
            border-right: 1px solid #ddd;
            overflow-y: auto;
            box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
        }
        .content {
            width: 80%;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .category {
            padding: 15px;
            cursor: pointer;
            text-align: center;
            border-bottom: 1px solid #ddd;
            font-size: 16px;
            color: #333;
            background-color: #f8f8f8;
            transition: background-color 0.3s, color 0.3s;
        }
        .category:hover {
            background-color: #d9d1c7;
            color: #a89f91;
        }
        .category.active {
            background-color: #a89f91;
            color: #fff;
            font-weight: bold;
        }
        .items {
            flex-grow: 1;
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            padding: 20px;
            justify-content: flex-start;
            background-color: #f5f5f5;
        }
        .item {
            width: 150px;
            height: 200px;
            border: 1px solid #ddd;
            background-color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        .item img {
            max-width: 100%;
            max-height: 100%;
            border-radius: 5px;
        }
        .delete-button {
            position: absolute;
            top: 5px;
            right: 5px;
            background-color: #f44336;
            color: #fff;
            border: none;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .delete-button:hover {
            background-color: #e53935;
        }
        .buttons {
            display: flex;
            justify-content: flex-start;
            padding: 10px 20px;
            border-top: 1px solid #ddd;
            background-color: #fff;
        }
        .buttons img {
            width: 50px;
            height: 50px;
            cursor: pointer;
            margin-right: 10px;
        }
        .header {
            padding: 15px 20px;
            border-bottom: 1px solid #ddd;
            background-color: #a89f91;
            font-weight: bold;
            font-size: 20px;
            color: #fff;
        }
        #file-input {
            display: none;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="category" onclick="showCategory('衣服')">衣服</div>
        <div class="category" onclick="showCategory('褲子')">褲子</div>
        <div class="category" onclick="showCategory('裙子')">裙子</div>
        <div class="category" onclick="showCategory('連身裙/褲')">連身裙/褲</div>
        <div class="category" onclick="showCategory('配件')">配件</div>
        <div class="category" onclick="showCategory('鞋子')">鞋子</div>
    </div>
    <div class="content">
        <div class="header" id="header">請選擇分類</div>
        <div class="items" id="items">
            <!-- 動態內容 -->
        </div>
        <div class="buttons">
            <label for="file-input">
                <img src="add-icon.png" alt="新增" title="新增">
            </label>
            <input type="file" id="file-input" accept="image/*" onchange="addItem(event)">
        </div>
    </div>
    <script>
        // 用於存儲每個分類的內容
        const categoriesData = {
            衣服: [],
            褲子: [],
            裙子: [],
            '連身裙/褲': [],
            配件: [],
            鞋子: []
        };
        let currentCategory = '';

        // 顯示特定分類
        function showCategory(category) {
            currentCategory = category;
            const header = document.getElementById('header');
            const itemsContainer = document.getElementById('items');

            // 更新分類標題
            header.textContent = category;

            // 清空現有內容並顯示對應分類內容
            itemsContainer.innerHTML = '';
            categoriesData[category].forEach((imageSrc, index) => {
                const newItem = document.createElement('div');
                newItem.classList.add('item');
                newItem.innerHTML = `
                    <img src="${imageSrc}" alt="圖片">
                    <button class="delete-button" onclick="confirmDelete(${index})">×</button>
                `;
                itemsContainer.appendChild(newItem);
            });

            const categories = document.querySelectorAll('.category');
            categories.forEach(cat => cat.classList.remove('active'));
            event.target.classList.add('active');
        }

        // 新增項目（上傳圖片）
        function addItem(event) {
            const file = event.target.files[0];
            if (!file || !currentCategory) return;

            const reader = new FileReader();
            reader.onload = function (e) {
                categoriesData[currentCategory].push(e.target.result);
                showCategory(currentCategory);
            };
            reader.readAsDataURL(file);

            // 清空 file input 的值以允許重複上傳相同文件
            event.target.value = '';
        }

        // 刪除項目前確認
        function confirmDelete(index) {
            if (confirm('確定要刪除這張圖片嗎？')) {
                categoriesData[currentCategory].splice(index, 1);
                showCategory(currentCategory);
            }
        }
    </script>
</body>
</html>
