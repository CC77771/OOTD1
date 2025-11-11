<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>服飾商家管理系統</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .tab-active {
            border-bottom: 2px solid #a89f91;
            color: #a89f91;
        }
        .tab-inactive {
            color: #6B7280;
        }
        .tab-inactive:hover {
            color: #1F2937;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 50;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }
        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .stat-card {
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-2px);
        }
        .btn-primary {
            background-color: #a89f91;
        }
        .btn-primary:hover {
            background-color: #968d81;
        }
        .btn-secondary {
            background-color: #8a8073;
        }
        .btn-secondary:hover {
            background-color: #756d62;
        }
        .focus-ring:focus {
            outline: none;
            ring: 2px;
            ring-color: #a89f91;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
    <div style="background: linear-gradient(to right, #a89f91, #8a8073);" class="shadow-lg">
        <div class="max-w-7xl mx-auto px-6 py-6">
            <div class="flex items-center gap-3">
                <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
                </svg>
                <div>
                    <h1 class="text-3xl font-bold text-white">服飾商家管理系統</h1>
                    <p class="text-white text-opacity-90 text-sm mt-1">管理您的服裝訂單與庫存</p>
                </div>
            </div>
        </div>
    </div>

    <div class="max-w-7xl mx-auto px-6 py-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded-lg shadow p-6 stat-card" style="border-top: 4px solid #a89f91;">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">總訂單數</p>
                        <p class="text-3xl font-bold text-gray-800 mt-2" id="totalOrders">0</p>
                    </div>
                    <div class="p-3 rounded-lg" style="background-color: #a89f91;">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6 stat-card" style="border-top: 4px solid #8a8073;">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">服裝款式</p>
                        <p class="text-3xl font-bold text-gray-800 mt-2" id="totalCommodities">0</p>
                    </div>
                    <div class="p-3 rounded-lg" style="background-color: #8a8073;">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6 stat-card border-t-4 border-blue-500">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">總庫存量</p>
                        <p class="text-3xl font-bold text-gray-800 mt-2" id="totalInventory">0</p>
                    </div>
                    <div class="bg-blue-500 p-3 rounded-lg">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6 stat-card border-t-4 border-orange-500">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">待處理訂單</p>
                        <p class="text-3xl font-bold text-gray-800 mt-2" id="pendingOrders">0</p>
                    </div>
                    <div class="bg-orange-500 p-3 rounded-lg">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow">
            <div class="border-b" style="background: linear-gradient(to right, rgba(168, 159, 145, 0.1), rgba(138, 128, 115, 0.1));">
                <div class="flex">
                    <button onclick="switchTab('orders')" id="ordersTab" class="px-6 py-4 font-medium tab-active flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                        </svg>
                        服裝訂單
                    </button>
                    <button onclick="switchTab('commodities')" id="commoditiesTab" class="px-6 py-4 font-medium tab-inactive flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                        </svg>
                        服裝商品
                    </button>
                </div>
            </div>

            <div class="p-6 border-b bg-gray-50">
                <div class="flex gap-4 flex-wrap">
                    <div class="flex-1 min-w-64 relative">
                        <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                        </svg>
                        <input type="text" id="searchInput" onkeyup="searchItems()" placeholder="搜尋款式、尺寸、顏色..." class="w-full pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                    </div>
                    <button onclick="clearSearch()" class="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600">清除</button>
                    <button onclick="addItem()" class="btn-primary text-white px-4 py-2 rounded-lg">新增</button>
                    <button onclick="exportData()" class="btn-secondary text-white px-4 py-2 rounded-lg">匯出</button>
                </div>
                <div id="searchResults" class="mt-2 text-sm text-gray-600"></div>
            </div>

            <div id="ordersTable" class="overflow-x-auto">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">訂單編號</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">服裝款式</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">尺寸</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">顏色</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">數量</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">收件人</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">狀態</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">操作</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200" id="ordersBody"></tbody>
                </table>
            </div>

            <div id="commoditiesTable" class="overflow-x-auto" style="display: none;">
                <table class="w-full">
                    <thead class="bg-gray-50 border-b">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">商品編號</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">服裝款式</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">類別</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">尺寸</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">顏色</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">價格</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">庫存</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">操作</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200" id="commoditiesBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="orderModal" class="modal">
        <div class="bg-white rounded-lg shadow-xl p-6 max-w-2xl w-full mx-4">
            <h2 class="text-xl font-bold mb-4" style="color: #a89f91;" id="orderModalTitle">編輯訂單</h2>
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">訂單編號</label>
                    <input type="text" id="editOrderCode" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">服裝款式</label>
                    <input type="text" id="editOrderName" placeholder="例：春季連身裙" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">尺寸</label>
                        <select id="editOrderSize" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                            <option value="XS">XS</option>
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
                            <option value="XXL">XXL</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">顏色</label>
                        <input type="text" id="editOrderColor" placeholder="例：粉紅色" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                    </div>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">數量</label>
                    <input type="number" id="editOrderQuantity" min="1" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">收件人</label>
                    <input type="text" id="editOrderRecipient" placeholder="例：王小明" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">配送地址</label>
                    <input type="text" id="editOrderAddress" placeholder="例：台北市信義區..." class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
            </div>
            <div class="flex gap-3 mt-6">
                <button onclick="saveOrder()" class="flex-1 btn-primary text-white px-4 py-2 rounded-lg">儲存</button>
                <button onclick="closeOrderModal()" class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400">取消</button>
            </div>
        </div>
    </div>

    <div id="commodityModal" class="modal">
        <div class="bg-white rounded-lg shadow-xl p-6 max-w-2xl w-full mx-4 max-h-screen overflow-y-auto">
            <h2 class="text-xl font-bold mb-4" style="color: #8a8073;" id="commodityModalTitle">編輯商品</h2>
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">商品編號</label>
                    <input type="text" id="editCommodityCode" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">服裝款式</label>
                    <input type="text" id="editCommodityName" placeholder="例：復古牛仔外套" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">類別</label>
                    <select id="editCommodityCategory" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                        <option value="上衣">上衣</option>
                        <option value="褲子">褲子</option>
                        <option value="裙子">裙子</option>
                        <option value="外套">外套</option>
                        <option value="洋裝">洋裝</option>
                        <option value="配件">配件</option>
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">尺寸</label>
                        <select id="editCommoditySize" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                            <option value="XS">XS</option>
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
                            <option value="XXL">XXL</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">顏色</label>
                        <input type="text" id="editCommodityColor" placeholder="例：深藍色" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">價格 (NT$)</label>
                        <input type="number" id="editCommodityPrice" min="0" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">庫存</label>
                        <input type="number" id="editCommodityInventory" min="0" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #8a8073;">
                    </div>
                </div>
            </div>
            <div class="flex gap-3 mt-6">
                <button onclick="saveCommodity()" class="flex-1 btn-secondary text-white px-4 py-2 rounded-lg">儲存</button>
                <button onclick="closeCommodityModal()" class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400">取消</button>
            </div>
        </div>
    </div>

    <script>
        var currentTab = 'orders';
        var editingId = null;
        var orders = [
            { id: 1, order_code: 'ORD001', clothing_name: '春季連身裙', size: 'M', color: '粉紅色', quantity: 2, recipient: '陳小美', address: '台北市大安區', status: 'pending' },
            { id: 2, order_code: 'ORD002', clothing_name: '牛仔外套', size: 'L', color: '深藍色', quantity: 1, recipient: '李大華', address: '新北市板橋區', status: 'completed' },
            { id: 3, order_code: 'ORD003', clothing_name: '運動T恤', size: 'XL', color: '黑色', quantity: 3, recipient: '王小明', address: '桃園市中壢區', status: 'processing' }
        ];
        
        var commodities = [
            { id: 1, commodity_code: 'CLO001', clothing_name: '春季連身裙', category: '洋裝', size: 'M', color: '粉紅色', price: 1280, inventory: 45 },
            { id: 2, commodity_code: 'CLO002', clothing_name: '牛仔外套', category: '外套', size: 'L', color: '深藍色', price: 1980, inventory: 30 },
            { id: 3, commodity_code: 'CLO003', clothing_name: '運動T恤', category: '上衣', size: 'XL', color: '黑色', price: 580, inventory: 80 },
            { id: 4, commodity_code: 'CLO004', clothing_name: '高腰牛仔褲', category: '褲子', size: 'S', color: '淺藍色', price: 1480, inventory: 15 }
        ];

        var statusLabels = {
            'pending': { text: '待處理', color: 'bg-yellow-100 text-yellow-800' },
            'processing': { text: '處理中', color: 'bg-blue-100 text-blue-800' },
            'completed': { text: '已完成', color: 'bg-green-100 text-green-800' },
            'cancelled': { text: '已取消', color: 'bg-red-100 text-red-800' }
        };

        function switchTab(tab) {
            currentTab = tab;
            if (tab === 'orders') {
                document.getElementById('ordersTab').className = 'px-6 py-4 font-medium tab-active flex items-center gap-2';
                document.getElementById('commoditiesTab').className = 'px-6 py-4 font-medium tab-inactive flex items-center gap-2';
                document.getElementById('ordersTable').style.display = 'block';
                document.getElementById('commoditiesTable').style.display = 'none';
            } else {
                document.getElementById('ordersTab').className = 'px-6 py-4 font-medium tab-inactive flex items-center gap-2';
                document.getElementById('commoditiesTab').className = 'px-6 py-4 font-medium tab-active flex items-center gap-2';
                document.getElementById('ordersTable').style.display = 'none';
                document.getElementById('commoditiesTable').style.display = 'block';
            }
            clearSearch();
        }

        function clearSearch() {
            document.getElementById('searchInput').value = '';
            document.getElementById('searchResults').textContent = '';
            renderOrders();
            renderCommodities();
        }

        function searchItems() {
            var searchTerm = document.getElementById('searchInput').value.toLowerCase();
            if (currentTab === 'orders') {
                var filtered = orders.filter(function(order) {
                    return order.order_code.toLowerCase().indexOf(searchTerm) > -1 ||
                           order.clothing_name.toLowerCase().indexOf(searchTerm) > -1 ||
                           order.size.toLowerCase().indexOf(searchTerm) > -1 ||
                           order.color.toLowerCase().indexOf(searchTerm) > -1 ||
                           order.recipient.toLowerCase().indexOf(searchTerm) > -1;
                });
                renderOrders(filtered);
                document.getElementById('searchResults').textContent = '找到 ' + filtered.length + ' 筆訂單';
            } else {
                var filtered = commodities.filter(function(commodity) {
                    return commodity.commodity_code.toLowerCase().indexOf(searchTerm) > -1 ||
                           commodity.clothing_name.toLowerCase().indexOf(searchTerm) > -1 ||
                           commodity.category.toLowerCase().indexOf(searchTerm) > -1 ||
                           commodity.size.toLowerCase().indexOf(searchTerm) > -1 ||
                           commodity.color.toLowerCase().indexOf(searchTerm) > -1;
                });
                renderCommodities(filtered);
                document.getElementById('searchResults').textContent = '找到 ' + filtered.length + ' 筆商品';
            }
        }

        function renderOrders(data) {
            if (!data) data = orders;
            var tbody = document.getElementById('ordersBody');
            tbody.innerHTML = '';
            
            for (var i = 0; i < data.length; i++) {
                var order = data[i];
                var status = statusLabels[order.status] || statusLabels['pending'];
                var tr = document.createElement('tr');
                tr.className = 'hover:bg-gray-50';
                tr.innerHTML = 
                    '<td class="px-6 py-4 text-sm font-medium text-gray-800">' + order.order_code + '</td>' +
                    '<td class="px-6 py-4 text-sm text-gray-800">' + order.clothing_name + '</td>' +
                    '<td class="px-6 py-4 text-sm"><span class="px-2 py-1 bg-gray-100 rounded text-gray-700">' + order.size + '</span></td>' +
                    '<td class="px-6 py-4 text-sm"><span class="px-2 py-1 rounded" style="background-color: rgba(168, 159, 145, 0.2); color: #a89f91;">' + order.color + '</span></td>' +
                    '<td class="px-6 py-4 text-sm font-bold text-gray-800">' + order.quantity + ' 件</td>' +
                    '<td class="px-6 py-4 text-sm text-gray-800">' + order.recipient + '</td>' +
                    '<td class="px-6 py-4 text-sm"><span class="px-2 py-1 rounded-full text-xs ' + status.color + '">' + status.text + '</span></td>' +
                    '<td class="px-6 py-4 text-sm">' +
                    '<button onclick="editOrder(' + order.id + ')" class="text-blue-600 hover: