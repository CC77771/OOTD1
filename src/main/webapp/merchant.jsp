<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@include file ="menu.jsp" %>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>蝦皮商店授權系統</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .modal-overlay { backdrop-filter: blur(4px); }
        .fade-in { animation: fadeIn 0.5s ease; }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .tag-label {
            cursor: move;
            user-select: none;
            position: absolute;
            z-index: 10;
        }
        .tag-label:hover { transform: scale(1.05); }
        .image-container {
            position: relative;
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
        }
        .image-container img {
            width: 100%;
            height: auto;
            display: block;
        }
        .delete-tag-btn {
            position: absolute;
            top: -8px;
            right: -8px;
            width: 20px;
            height: 20px;
            background: red;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.2s;
        }
        .tag-label:hover .delete-tag-btn { opacity: 1; }
    </style>
</head>
<body class="bg-gradient-to-br from-stone-50 to-stone-100">
    <div id="app" class="min-h-screen p-6"></div>

    <script>
        const authSteps = [
            { title: 'API 授權設定', desc: '允許存取您的蝦皮商店資料' },
            { title: '個資使用同意', desc: '同意使用訂單資料進行管理' },
            { title: '資料撷取授權', desc: '授權自動同步訂單資料' }
        ];

        let state = {
            isConnected: false,
            showAuthModal: false,
            showStyleSetModal: false,
            showEditTagModal: false,
            authStep: 0,
            loading: false,
            shopInfo: null,
            styleSets: [],
            currentEditingSet: null,
            tempImageData: null
        };

        function loadData() {
            const saved = localStorage.getItem('shopeeAuthData');
            if (saved) {
                const data = JSON.parse(saved);
                state.isConnected = data.isConnected || false;
                state.shopInfo = data.shopInfo || null;
                state.styleSets = data.styleSets || [];
            }
        }

        function saveData() {
            localStorage.setItem('shopeeAuthData', JSON.stringify({
                isConnected: state.isConnected,
                shopInfo: state.shopInfo,
                styleSets: state.styleSets
            }));
        }

        function render() {
            const app = document.getElementById('app');
            let html = '<div class="max-w-7xl mx-auto">';
            
            html += '<div class="bg-white rounded-lg shadow-lg p-8 mb-6 fade-in">';
            html += '<div class="flex items-center justify-center mb-6">';
            html += '<svg class="w-12 h-12 mr-4" style="color: #a89f91;" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg>';
            html += '<div><h1 class="text-3xl font-bold text-gray-800">蝦皮商店授權系統</h1>';
            html += '<p class="text-gray-500 text-sm mt-1">連接您的蝦皮賣場,開始管理訂單與商品</p></div></div>';
            
            if (state.isConnected && state.shopInfo) {
                html += '<div class="border-2 rounded-lg p-6" style="background-color: #f5f3f1; border-color: #d4cdc5;">';
                html += '<div class="flex items-center justify-between">';
                html += '<div class="flex items-center gap-4">';
                html += '<div class="rounded-full p-3" style="background-color: #a89f91;"><svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg></div>';
                html += '<div><h3 class="text-xl font-bold" style="color: #6b5d52;">授權成功!</h3><p class="mt-1" style="color: #8a7d72;">您的蝦皮商店已成功連接</p></div></div>';
                html += '<button onclick="disconnectShop()" class="px-6 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition font-medium">解除綁定</button></div>';
                
                html += '<div class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">';
                html += '<div class="bg-white rounded-lg p-4 border" style="border-color: #d4cdc5;"><div class="text-gray-500 text-sm mb-1">商店名稱</div><div class="text-gray-800 font-semibold text-lg">' + state.shopInfo.name + '</div></div>';
                html += '<div class="bg-white rounded-lg p-4 border" style="border-color: #d4cdc5;"><div class="text-gray-500 text-sm mb-1">穿搭組合數</div><div class="text-gray-800 font-semibold text-lg">' + state.styleSets.length + ' 組</div></div>';
                html += '<div class="bg-white rounded-lg p-4 border" style="border-color: #d4cdc5;"><div class="text-gray-500 text-sm mb-1">授權時間</div><div class="text-gray-800 font-semibold text-lg">' + state.shopInfo.authTime + '</div></div></div></div>';
            } else {
                html += '<div class="text-center py-8">';
                html += '<div class="inline-flex items-center justify-center w-20 h-20 rounded-full mb-4" style="background-color: #f5f3f1;"><svg class="w-10 h-10" style="color: #a89f91;" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg></div>';
                html += '<h2 class="text-2xl font-bold text-gray-700 mb-2">尚未連接蝦皮商店</h2>';
                html += '<p class="text-gray-500 mb-6">請點擊下方按鈕開始授權流程</p>';
                html += '<button onclick="startAuth()" class="text-white px-8 py-3 rounded-lg transition font-medium text-lg shadow-lg" style="background-color: #a89f91;">開始綁定蝦皮商店</button></div>';
            }
            html += '</div>';

            if (state.isConnected) {
                html += '<div class="bg-white rounded-lg shadow-lg p-8 mb-6 fade-in">';
                html += '<div class="flex items-center justify-between mb-6"><h2 class="text-2xl font-bold text-gray-800">穿搭組合管理</h2>';
                html += '<button onclick="openStyleSetModal()" class="text-white px-6 py-2 rounded-lg transition font-medium flex items-center gap-2" style="background-color: #a89f91;"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>新增穿搭組合</button></div>';

                if (state.styleSets.length === 0) {
                    html += '<div class="text-center py-12 text-gray-500"><svg class="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>';
                    html += '<p class="text-lg">尚未新增任何穿搭組合</p></div>';
                } else {
                    html += '<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">';
                    state.styleSets.forEach(function(set, index) {
                        html += '<div class="border border-gray-200 rounded-lg overflow-hidden hover:shadow-lg transition">';
                        html += '<div class="relative"><img src="' + set.image + '" class="w-full h-64 object-cover">';
                        html += '<div class="absolute top-2 right-2 bg-white px-2 py-1 rounded text-sm font-medium">' + set.tags.length + ' 個商品</div></div>';
                        html += '<div class="p-4"><h3 class="font-semibold text-lg text-gray-800 mb-3">' + set.title + '</h3>';
                        html += '<div class="flex gap-2">';
                        html += '<button onclick="editStyleSet(' + index + ')" class="flex-1 px-4 py-2 text-white text-sm rounded transition" style="background-color: #a89f91;">編輯</button>';
                        html += '<button onclick="toggleStyleSet(' + index + ')" class="flex-1 px-4 py-2 ' + (set.isActive ? 'bg-orange-500' : 'bg-green-500') + ' text-white text-sm rounded">' + (set.isActive ? '下架' : '上架') + '</button>';
                        html += '<button onclick="deleteStyleSet(' + index + ')" class="px-4 py-2 bg-red-500 text-white text-sm rounded">刪除</button></div></div></div>';
                    });
                    html += '</div>';
                }
                html += '</div>';
            }

            if (state.showAuthModal) html += renderAuthModal();
            if (state.showStyleSetModal) html += renderStyleSetModal();
            if (state.showEditTagModal) html += renderEditTagModal();
            
            html += '</div>';
            app.innerHTML = html;
        }

        function renderAuthModal() {
            let html = '<div class="fixed inset-0 bg-black bg-opacity-50 modal-overlay flex items-center justify-center z-50 p-4">';
            html += '<div class="bg-white rounded-2xl shadow-2xl max-w-lg w-full"><div class="p-6 text-white" style="background: linear-gradient(135deg, #a89f91 0%, #93897d 100%);">';
            html += '<div class="flex items-center justify-between mb-4"><h2 class="text-2xl font-bold">蝦皮商店授權</h2><button onclick="closeModal()"><svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg></button></div>';
            html += '<div class="flex gap-2">';
            for (let i = 0; i < authSteps.length; i++) {
                html += '<div class="h-2 flex-1 rounded-full" style="background-color: ' + (i <= state.authStep ? '#ffffff' : '#c4bab0') + ';"></div>';
            }
            html += '</div><div class="mt-3 text-sm">步驟 ' + (state.authStep + 1) + ' / ' + authSteps.length + '</div></div>';
            html += '<div class="p-8"><h3 class="text-2xl font-semibold text-gray-800 mb-3 text-center">' + authSteps[state.authStep].title + '</h3>';
            html += '<p class="text-gray-600 text-center mb-8">' + authSteps[state.authStep].desc + '</p><div class="flex gap-3">';
            if (state.authStep > 0) html += '<button onclick="prevStep()" class="flex-1 px-6 py-3 border-2 text-gray-700 rounded-lg" style="border-color: #d4cdc5;">上一步</button>';
            html += '<button onclick="nextStep()" class="flex-1 px-6 py-3 text-white rounded-lg" style="background-color: #a89f91;">' + (state.authStep === authSteps.length - 1 ? '完成授權' : '同意並繼續') + '</button></div></div></div></div>';
            return html;
        }

        function renderStyleSetModal() {
            let html = '<div class="fixed inset-0 bg-black bg-opacity-50 modal-overlay flex items-center justify-center z-50 p-4">';
            html += '<div class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full overflow-y-auto max-h-[90vh]">';
            html += '<div class="p-6 text-white" style="background: linear-gradient(135deg, #a89f91 0%, #93897d 100%);"><div class="flex items-center justify-between">';
            html += '<h2 class="text-2xl font-bold">新增穿搭組合</h2><button onclick="closeStyleSetModal()"><svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg></button></div></div>';
            html += '<div class="p-8"><div class="mb-6"><label class="block text-gray-700 font-semibold mb-2">組合標題 <span class="text-red-500">*</span></label>';
            html += '<input type="text" id="setTitle" placeholder="例如：秋冬簡約穿搭" class="w-full px-4 py-3 border rounded-lg" style="border-color: #d4cdc5;"></div>';
            html += '<div class="mb-6"><label class="block text-gray-700 font-semibold mb-2">上傳穿搭圖片 <span class="text-red-500">*</span></label>';
            html += '<input type="file" id="styleImage" accept="image/*" onchange="previewImage(event)" class="w-full px-4 py-3 border rounded-lg" style="border-color: #d4cdc5;">';
            html += '<p class="text-sm text-gray-500 mt-2">建議尺寸：800x1000 像素</p></div>';
            html += '<div id="imagePreview" class="mb-6 hidden"><label class="block text-gray-700 font-semibold mb-2">圖片預覽</label>';
            html += '<div class="border rounded-lg p-4" style="border-color: #d4cdc5;"><img id="previewImg" src="" class="max-w-full h-auto mx-auto"></div></div>';
            html += '<div class="flex gap-3"><button onclick="closeStyleSetModal()" class="flex-1 px-6 py-3 border-2 text-gray-700 rounded-lg" style="border-color: #d4cdc5;">取消</button>';
            html += '<button onclick="saveStyleSet()" class="flex-1 px-6 py-3 text-white rounded-lg" style="background-color: #a89f91;">下一步：添加商品標籤</button></div></div></div></div>';
            return html;
        }

        function renderEditTagModal() {
            const set = state.currentEditingSet;
            if (!set) return '';
            
            let html = '<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">';
            html += '<div class="bg-white rounded-2xl shadow-2xl max-w-5xl w-full overflow-y-auto max-h-[90vh]">';
            html += '<div class="p-6 text-white" style="background: linear-gradient(135deg, #a89f91 0%, #93897d 100%);"><div class="flex items-center justify-between">';
            html += '<h2 class="text-2xl font-bold">編輯商品標籤 - ' + set.title + '</h2><button onclick="closeEditTagModal()"><svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg></button></div></div>';
            html += '<div class="p-8"><div class="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg"><p class="text-sm text-blue-800"><strong>💡 操作說明：</strong></p>';
            html += '<ul class="text-sm text-blue-700 mt-2 ml-4"><li>• 點擊圖片添加商品標籤</li><li>• 拖動標籤可調整位置</li><li>• 移到標籤上方可看到刪除按鈕</li></ul></div>';
            
            html += '<div class="image-container" id="tagContainer" onclick="addTagAtClick(event)"><img src="' + set.image + '" id="editImage">';
            
            set.tags.forEach(function(tag, index) {
                html += '<div class="tag-label" style="left: ' + tag.x + '%; top: ' + tag.y + '%;" onmousedown="startDrag(event, ' + index + ')">';
                html += '<div class="bg-white bg-opacity-90 px-3 py-2 rounded-lg shadow-lg border-2" style="border-color: #a89f91; position: relative;">';
                html += '<div class="text-xs text-gray-600">' + tag.name + '</div><div class="font-bold" style="color: #a89f91;">$' + tag.price + '</div>';
                html += '<div class="delete-tag-btn" onclick="deleteTag(event, ' + index + ')">×</div></div></div>';
            });
            
            html += '</div><div class="mt-6 p-4 border rounded-lg" style="border-color: #d4cdc5; background: #f9f9f9;"><h3 class="font-semibold text-gray-800 mb-4">新增商品標籤</h3>';
            html += '<div class="grid grid-cols-1 md:grid-cols-3 gap-4">';
            html += '<div><label class="block text-gray-700 text-sm font-medium mb-2">商品名稱</label><input type="text" id="tagName" placeholder="咖啡外套" class="w-full px-3 py-2 border rounded-lg" style="border-color: #d4cdc5;"></div>';
            html += '<div><label class="block text-gray-700 text-sm font-medium mb-2">價格</label><input type="text" id="tagPrice" placeholder="750" class="w-full px-3 py-2 border rounded-lg" style="border-color: #d4cdc5;"></div>';
            html += '<div><label class="block text-gray-700 text-sm font-medium mb-2">蝦皮連結</label><input type="url" id="tagUrl" placeholder="https://shopee.tw/..." class="w-full px-3 py-2 border rounded-lg" style="border-color: #d4cdc5;"></div>';
            html += '</div><p class="text-sm text-gray-500 mt-3">填寫完成後，點擊圖片上的位置即可添加標籤</p></div>';
            html += '<div class="flex gap-3 mt-6"><button onclick="closeEditTagModal()" class="flex-1 px-6 py-3 border-2 text-gray-700 rounded-lg" style="border-color: #d4cdc5;">取消</button>';
            html += '<button onclick="saveTagsAndClose()" class="flex-1 px-6 py-3 text-white rounded-lg" style="background-color: #a89f91;">完成編輯</button></div></div></div></div>';
            return html;
        }

        function previewImage(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    state.tempImageData = e.target.result;
                    document.getElementById('previewImg').src = e.target.result;
                    document.getElementById('imagePreview').classList.remove('hidden');
                };
                reader.readAsDataURL(file);
            }
        }

        let draggedIndex = null;
        let offsetX = 0;
        let offsetY = 0;

        function startDrag(event, index) {
            event.preventDefault();
            draggedIndex = index;
            const tag = event.currentTarget;
            const rect = tag.getBoundingClientRect();
            offsetX = event.clientX - rect.left;
            offsetY = event.clientY - rect.top;
            
            document.addEventListener('mousemove', onDrag);
            document.addEventListener('mouseup', stopDrag);
        }

        function onDrag(event) {
            if (draggedIndex === null) return;
            
            const container = document.getElementById('tagContainer');
            const img = document.getElementById('editImage');
            const imgRect = img.getBoundingClientRect();
            
            const x = ((event.clientX - offsetX - imgRect.left) / imgRect.width) * 100;
            const y = ((event.clientY - offsetY - imgRect.top) / imgRect.height) * 100;
            
            if (x >= 0 && x <= 100 && y >= 0 && y <= 100) {
                state.currentEditingSet.tags[draggedIndex].x = x;
                state.currentEditingSet.tags[draggedIndex].y = y;
                render();
            }
        }

        function stopDrag() {
            draggedIndex = null;
            document.removeEventListener('mousemove', onDrag);
            document.removeEventListener('mouseup', stopDrag);
        }

        function addTagAtClick(event) {
            if (event.target.id !== 'editImage') return;
            
            const name = document.getElementById('tagName').value.trim();
            const price = document.getElementById('tagPrice').value.trim();
            const url = document.getElementById('tagUrl').value.trim();
            
            if (!name || !price || !url) {
                alert('請先填寫完整的商品資訊');
                return;
            }
            
            const img = document.getElementById('editImage');
            const rect = img.getBoundingClientRect();
            const x = ((event.clientX - rect.left) / rect.width) * 100;
            const y = ((event.clientY - rect.top) / rect.height) * 100;
            
            state.currentEditingSet.tags.push({ name, price, url, x, y });
            
            document.getElementById('tagName').value = '';
            document.getElementById('tagPrice').value = '';
            document.getElementById('tagUrl').value = '';
            
            render();
        }

        function deleteTag(event, index) {
            event.stopPropagation();
            if (confirm('確定要刪除這個標籤嗎？')) {
                state.currentEditingSet.tags.splice(index, 1);
                render();
            }
        }

        function startAuth() {
            state.showAuthModal = true;
            state.authStep = 0;
            render();
        }

        function closeModal() {
            if (!state.loading) {
                state.showAuthModal = false;
                render();
            }
        }

        function prevStep() {
            if (state.authStep > 0) {
                state.authStep--;
                render();
            }
        }

        function nextStep() {
            if (state.authStep < authSteps.length - 1) {
                state.authStep++;
                render();
            } else {
                state.loading = true;
                render();
                setTimeout(function() {
                    const now = new Date();
                    state.shopInfo = {
                        name: 'attention2015',
                        authTime: now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0')
                    };
                    state.isConnected = true;
                    state.showAuthModal = false;
                    state.loading = false;
                    saveData();
                    render();
                    alert('🎉 授權成功！');
                }, 2000);
            }
        }

        function disconnectShop() {
            if (confirm('確定要解除綁定嗎？')) {
                state.isConnected = false;
                state.shopInfo = null;
                state.styleSets = [];
                saveData();
                render();
            }
        }

        function openStyleSetModal() {
            state.showStyleSetModal = true;
            state.tempImageData = null;
            render();
        }

        function closeStyleSetModal() {
            state.showStyleSetModal = false;
            render();
        }

        function saveStyleSet() {
            const title = document.getElementById('setTitle').value.trim();
            if (!title) {
                alert('請輸入組合標題');
                return;
            }
            if (!state.tempImageData) {
                alert('請上傳穿搭圖片');
                return;
            }
            
            const newSet = {
                title: title,
                image: state.tempImageData,
                tags: [],
                isActive: false,
                createdAt: new Date().toISOString()
            };
            
            state.styleSets.push(newSet);
            state.currentEditingSet = newSet;
            state.showStyleSetModal = false;
            state.showEditTagModal = true;
            render();
        }

        function editStyleSet(index) {
            state.currentEditingSet = state.styleSets[index];
            state.showEditTagModal = true;
            render();
        }

        function closeEditTagModal() {
            state.showEditTagModal = false;
            state.currentEditingSet = null;
            render();
        }

        function saveTagsAndClose() {
            saveData();
            closeEditTagModal();
            alert('✅ 穿搭組合已儲存！');
        }

        function toggleStyleSet(index) {
            state.styleSets[index].isActive = !state.styleSets[index].isActive;
            saveData();
            render();
        }

        function deleteStyleSet(index) {
            if (confirm('確定要刪除這個穿搭組合嗎？')) {
                state.styleSets.splice(index, 1);
                saveData();
                render();
            }
        }

        loadData();
        render();
    </script>
</body>
</html>