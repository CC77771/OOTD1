<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@include file ="menu.jsp" %>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商家管理系統</title>
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
            background-color: #958c7f;
        }
        .btn-secondary {
            background-color: #c4b5a0;
        }
        .btn-secondary:hover {
            background-color: #b3a48f;
        }
        .border-primary {
            border-color: #a89f91;
        }
        .text-primary {
            color: #a89f91;
        }
        .bg-primary {
            background-color: #a89f91;
        }
        .bg-primary-light {
            background-color: #d4cdc3;
        }
        .focus-ring-primary:focus {
            outline: none;
            ring: 2px;
            ring-color: #a89f91;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .animate-pulse {
            animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
    <div class="bg-gradient-to-r from-[#a89f91] to-[#c4b5a0] shadow-lg">
        <div class="max-w-7xl mx-auto px-6 py-6">
            <div class="flex items-center gap-3">
                <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"/>
                </svg>
                <div>
                    <h1 class="text-3xl font-bold text-white">商家管理系統</h1>
                    <p class="text-white/80 text-sm mt-1">管理您的服裝訂單與庫存</p>
                </div>
            </div>
        </div>
    </div>

    <div class="max-w-7xl mx-auto px-6 py-6">
        <!-- 蝦皮綁定狀態卡片 -->
        <div class="bg-white rounded-lg shadow mb-6 overflow-hidden">
            <div class="bg-gradient-to-r from-orange-500 to-orange-600 px-6 py-4">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"/>
                        </svg>
                        <div>
                            <h3 class="text-white font-bold text-lg">蝦皮訂單整合</h3>
                            <p class="text-orange-100 text-sm" id="shopeeStatusText">尚未綁定蝦皮帳號</p>
                        </div>
                    </div>
                    <div>
                        <button onclick="startShopeeBinding()" id="shopeeBindBtn" class="bg-white text-orange-600 px-6 py-2 rounded-lg font-medium hover:bg-orange-50 transition-colors flex items-center gap-2">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                            </svg>
                            立即綁定
                        </button>
                        <button onclick="syncShopeeOrders()" id="shopeeSyncBtn" class="bg-white text-orange-600 px-6 py-2 rounded-lg font-medium hover:bg-orange-50 transition-colors hidden flex items-center gap-2">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                            </svg>
                            同步訂單
                        </button>
                    </div>
                </div>
            </div>
            <div id="shopeeBindingInfo" class="px-6 py-4 bg-gray-50 border-t hidden">
                <div class="flex items-center justify-between text-sm">
                    <div class="flex items-center gap-2 text-green-600">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                        <span>已連接帳號：<strong id="shopeeAccountName">shop_user_2024</strong></span>
                    </div>
                    <div class="text-gray-600">
                        最後同步：<span id="lastSyncTime">--</span>
                    </div>
                    <button onclick="unbindShopee()" class="text-red-600 hover:underline">解除綁定</button>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded-lg shadow p-6 stat-card border-t-4" style="border-top-color: #a89f91;">
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

            <div class="bg-white rounded-lg shadow p-6 stat-card border-t-4" style="border-top-color: #c4b5a0;">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">服裝款式</p>
                        <p class="text-3xl font-bold text-gray-800 mt-2" id="totalCommodities">0</p>
                    </div>
                    <div class="p-3 rounded-lg" style="background-color: #c4b5a0;">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                        </svg>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-lg shadow p-6 stat-card border-t-4" style="border-top-color: #8b7e6f;">
                <div class="flex items-center justify-between">
                    <div>
                        <p class="text-gray-600 text-sm">總庫存量</p>
                        <p class="text-3xl font-bold text-gray-800 mt-2" id="totalInventory">0</p>
                    </div>
                    <div class="p-3 rounded-lg" style="background-color: #8b7e6f;">
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
            <div class="border-b" style="background: linear-gradient(to right, #f5f3f0, #e8e3dc);">
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
                        服裝庫存
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

    <!-- 蝦皮授權綁定流程 Modal -->
    <div id="shopeeBindingModal" class="modal">
        <div class="bg-white rounded-lg shadow-xl p-6 max-w-lg w-full mx-4">
            <div class="text-center mb-6">
                <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-orange-100 mb-4">
                    <svg class="w-10 h-10 text-orange-600" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2L2 7v10c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7l-10-5z"/>
                    </svg>
                </div>
                <h2 class="text-2xl font-bold text-gray-800">蝦皮賣家授權</h2>
                <p class="text-gray-600 mt-2" id="shopeeBindingStep">準備連接您的蝦皮賣場</p>
            </div>

            <!-- 進度指示器 -->
            <div class="mb-6">
                <div class="flex items-center justify-between mb-2">
                    <span class="text-sm font-medium text-gray-700">授權進度</span>
                    <span class="text-sm font-medium text-orange-600" id="shopeeProgressText">0/4</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                    <div id="shopeeProgressBar" class="bg-orange-600 h-2 rounded-full transition-all duration-500" style="width: 0%"></div>
                </div>
            </div>

            <!-- 步驟內容 -->
            <div id="shopeeStepContent" class="bg-gray-50 rounded-lg p-4 mb-6 min-h-48">
                <!-- 動態載入步驟內容 -->
            </div>

            <!-- 操作按鈕 -->
            <div class="flex gap-3">
                <button onclick="nextShopeeStep()" id="shopeeNextBtn" class="flex-1 bg-orange-600 text-white px-4 py-2 rounded-lg hover:bg-orange-700 font-medium">
                    同意並繼續
                </button>
                <button onclick="closeShopeeBindingModal()" id="shopeeCancelBtn" class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400 font-medium">
                    取消
                </button>
            </div>
        </div>
    </div>

    <div id="orderModal" class="modal">
        <div class="bg-white rounded-lg shadow-xl p-6 max-w-2xl w-full mx-4">
            <h2 class="text-xl font-bold mb-4 text-primary" id="orderModalTitle">編輯訂單</h2>
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
            <h2 class="text-xl font-bold mb-4 text-primary" id="commodityModalTitle">編輯商品</h2>
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">商品編號</label>
                    <input type="text" id="editCommodityCode" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">服裝款式</label>
                    <input type="text" id="editCommodityName" placeholder="例：復古牛仔外套" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">類別</label>
                    <select id="editCommodityCategory" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
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
                        <select id="editCommoditySize" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
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
                        <input type="text" id="editCommodityColor" placeholder="例：深藍色" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">價格 (NT$)</label>
                        <input type="number" id="editCommodityPrice" min="0" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">庫存</label>
                        <input type="number" id="editCommodityInventory" min="0" class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2" style="--tw-ring-color: #a89f91;">
                    </div>
                </div>
            </div>
            <div class="flex gap-3 mt-6">
                <button onclick="saveCommodity()" class="flex-1 btn-primary text-white px-4 py-2 rounded-lg">儲存</button>
                <button onclick="closeCommodityModal()" class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-400">取消</button>
            </div>
        </div>
    </div>

    <script>
        // 蝦皮綁定狀態
        let shopeeBinding = {
            isBound: false,
            currentStep: 0,
            accountName: '',
            authCode: '',
            lastSyncTime: null
        };

        // 蝦皮授權步驟內容
        const shopeeSteps = [
            {
                title: '步驟 1：閱讀授權說明',
                content: `
                    <div class="space-y-3">
                        <div class="flex items-start gap-3">
                            <svg class="w-5 h-5 text-orange-600 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            <p class="text-sm text-gray-700">授權後，系統將可以自動讀取您的蝦皮訂單資訊</p>
                        </div>
                        <div class="flex items-start gap-3">
                            <svg class="w-5 h-5 text-orange-600 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            <p class="text-sm text-gray-700">包含訂單編號、商品名稱、買家資訊、配送狀態等</p>
                        </div>
                        <div class="flex items-start gap-3">
                            <svg class="w-5 h-5 text-orange-600 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            <p class="text-sm text-gray-700">您可以隨時在設定中解除授權</p>
                        </div>
                        <div class="bg-orange-50 border border-orange-200 rounded-lg p-3 mt-4">
                            <p class="text-xs text-orange-800"><strong>隱私保護：</strong>我們僅讀取訂單相關資訊，不會存取您的個人財務資料</p>
                        </div>
                    </div>
                `,
                progress: 25
            },
            {
                title: '步驟 2：API 授權設定',
                content: `
                    <div class="space-y-3">
                        <p class="text-sm text-gray-700 mb-3">請確認以下 API 權限設定：</p>
                        <div class="space-y-2">
                            <label class="flex items-center gap-3 p-3 bg-white border rounded-lg cursor-pointer hover:bg-gray-50">
                                <input type="checkbox" checked disabled class="w-4 h-4 text-orange-600">
                                <span class="text-sm text-gray-700">讀取訂單資訊 (order.read)</span>
                            </label>
                            <label class="flex items-center gap-3 p-3 bg-white border rounded-lg cursor-pointer hover:bg-gray-50">
                                <input type="checkbox" checked disabled class="w-4 h-4 text-orange-600">
                                <span class="text-sm text-gray-700">讀取商品資訊 (product.read)</span>
                            </label>
                            <label class="flex items-center gap-3 p-3 bg-white border rounded-lg cursor-pointer hover:bg-gray-50">
                                <input type="checkbox" checked disabled class="w-4 h-4 text-orange-600">
                                <span class="text-sm text-gray-700">讀取物流資訊 (logistics.read)</span>
                            </label>
                        </div>
                        <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mt-4">
                            <p class="text-xs text-blue-800"><strong>提示：</strong>這些權限僅用於訂單同步，不會修改您的蝦皮賣場資料</p>
                        </div>
                    </div>
                `,
                progress: 50
            },
            {
                title: '步驟 3：輸入授權碼',
                content: `
                    <div class="space-y-3">
                        <p class="text-sm text-gray-700 mb-3">請輸入蝦皮提供的授權碼：</p>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">授權碼</label>
                            <input type="text" id="shopeeAuthCodeInput" placeholder="例：SHOPEE_AUTH_2024XXXX" 
                                   class="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                            <p class="text-xs text-gray-500 mt-2">授權碼可在蝦皮開放平台取得</p>
                        </div>
                        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mt-4">
                            <p class="text-xs text-yellow-800"><strong>注意：</strong>授權碼有效期為 30 天，過期後需重新綁定</p>
                        </div>
                        <div class="mt-4 p-3 bg-gray-100 rounded border">
                            <p class="text-xs text-gray-600 mb-2">測試用授權碼（示範）：</p>
                            <code class="text-xs bg-white px-2 py-1 rounded">SHOPEE_TEST_2024ABC123</code>
                        </div>
                    </div>
                `,
                progress: 75
            },
            {
                title: '步驟 4：確認綁定',
                content: `
                    <div class="space-y-3">
                        <div class="text-center py-4">
                            <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 mb-4">
                                <svg class="w-10 h-10 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                            </div>
                            <h3 class="text-lg font-bold text-gray-800 mb-2">準備完成！</h3>
                            <p class="text-sm text-gray-600">點擊「完成綁定」即可開始同步訂單</p>
                        </div>
                        <div class="bg-gray-100 rounded-lg p-4 space-y-2">
                            <div class="flex justify-between text-sm">
                                <span class="text-gray-600">賣場帳號：</span>
                                <span class="font-medium" id="finalAccountName">shop_user_2024</span>
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-gray-600">授權範圍：</span>
                                <span class="font-medium">訂單、商品、物流</span>
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-gray-600">授權期限：</span>
                                <span class="font-medium">30 天</span>
                            </div>
                        </div>
                    </div>
                `,
                progress: 100
            }
        ];

        // 模擬蝦皮訂單資料
        const mockShopeeOrders = [
            {
                orderCode: 'SHOPEE-2024001',
                commodityName: '韓版寬鬆T恤',
                size: 'M',
                color: '白色',
                quantity: 2,
                recipient: '張小美',
                address: '台北市大安區忠孝東路123號',
                status: '待出貨'
            },
            {
                orderCode: 'SHOPEE-2024002',
                commodityName: '高腰牛仔褲',
                size: 'L',
                color: '深藍',
                quantity: 1,
                recipient: '李大明',
                address: '新北市板橋區中山路456號',
                status: '待出貨'
            },
            {
                orderCode: 'SHOPEE-2024003',
                commodityName: '碎花洋裝',
                size: 'S',
                color: '粉紅',
                quantity: 1,
                recipient: '陳小華',
                address: '台中市西屯區台灣大道789號',
                status: '待出貨'
            },
            {
                orderCode: 'SHOPEE-2024004',
                commodityName: '針織外套',
                size: 'XL',
                color: '米色',
                quantity: 1,
                recipient: '王小芳',
                address: '高雄市左營區博愛路321號',
                status: '待出貨'
            },
            {
                orderCode: 'SHOPEE-2024005',
                commodityName: '運動休閒褲',
                size: 'L',
                color: '黑色',
                quantity: 3,
                recipient: '林大偉',
                address: '桃園市中壢區中正路654號',
                status: '待出貨'
            }
        ];

        // 資料儲存
        let orders = [];
        let commodities = [
            { code: 'CLO-001', name: '春季連身裙', category: '洋裝', size: 'M', color: '粉紅色', price: 890, inventory: 15 },
            { code: 'CLO-002', name: '復古牛仔外套', category: '外套', size: 'L', color: '深藍色', price: 1290, inventory: 8 },
            { code: 'CLO-003', name: '寬鬆棉T', category: '上衣', size: 'XL', color: '白色', price: 390, inventory: 25 }
        ];

        let currentTab = 'orders';
        let editingIndex = -1;

        // 初始化
        window.onload = function() {
            loadFromStorage();
            updateStats();
            renderOrders();
            renderCommodities();
            checkShopeeBinding();
        };

        // 檢查蝦皮綁定狀態
        function checkShopeeBinding() {
            const savedBinding = localStorage.getItem('shopeeBinding');
            if (savedBinding) {
                shopeeBinding = JSON.parse(savedBinding);
                updateShopeeStatus();
            }
        }

        // 更新蝦皮綁定狀態顯示
        function updateShopeeStatus() {
            if (shopeeBinding.isBound) {
                document.getElementById('shopeeStatusText').textContent = '已綁定並啟用';
                document.getElementById('shopeeBindBtn').classList.add('hidden');
                document.getElementById('shopeeSyncBtn').classList.remove('hidden');
                document.getElementById('shopeeBindingInfo').classList.remove('hidden');
                document.getElementById('shopeeAccountName').textContent = shopeeBinding.accountName;
                if (shopeeBinding.lastSyncTime) {
                    document.getElementById('lastSyncTime').textContent = shopeeBinding.lastSyncTime;
                }
            } else {
                document.getElementById('shopeeStatusText').textContent = '尚未綁定蝦皮帳號';
                document.getElementById('shopeeBindBtn').classList.remove('hidden');
                document.getElementById('shopeeSyncBtn').classList.add('hidden');
                document.getElementById('shopeeBindingInfo').classList.add('hidden');
            }
        }

        // 開始蝦皮綁定流程
        function startShopeeBinding() {
            shopeeBinding.currentStep = 0;
            showShopeeStep();
            document.getElementById('shopeeBindingModal').classList.add('show');
        }

        // 顯示當前步驟
        function showShopeeStep() {
            const step = shopeeSteps[shopeeBinding.currentStep];
            document.getElementById('shopeeBindingStep').textContent = step.title;
            document.getElementById('shopeeStepContent').innerHTML = step.content;
            document.getElementById('shopeeProgressText').textContent = `${shopeeBinding.currentStep + 1}/4`;
            document.getElementById('shopeeProgressBar').style.width = step.progress + '%';

            // 更新按鈕文字
            const nextBtn = document.getElementById('shopeeNextBtn');
            if (shopeeBinding.currentStep === shopeeSteps.length - 1) {
                nextBtn.textContent = '完成綁定';
            } else {
                nextBtn.textContent = '同意並繼續';
            }
        }

        // 下一步
        function nextShopeeStep() {
            // 如果在步驟3，檢查授權碼
            if (shopeeBinding.currentStep === 2) {
                const authCode = document.getElementById('shopeeAuthCodeInput').value.trim();
                if (!authCode) {
                    alert('請輸入授權碼');
                    return;
                }
                shopeeBinding.authCode = authCode;
                shopeeBinding.accountName = 'shop_user_2024';
            }

            if (shopeeBinding.currentStep < shopeeSteps.length - 1) {
                shopeeBinding.currentStep++;
                showShopeeStep();
            } else {
                // 完成綁定
                completeShopeeBinding();
            }
        }

        // 完成綁定
        function completeShopeeBinding() {
            shopeeBinding.isBound = true;
            shopeeBinding.lastSyncTime = new Date().toLocaleString('zh-TW');
            localStorage.setItem('shopeeBinding', JSON.stringify(shopeeBinding));
            
            closeShopeeBindingModal();
            updateShopeeStatus();
            
            // 顯示成功訊息
            alert('🎉 蝦皮帳號綁定成功！\n\n您現在可以開始同步訂單了。');
            
            // 自動同步一次
            setTimeout(() => {
                syncShopeeOrders();
            }, 500);
        }

        // 關閉綁定 Modal
        function closeShopeeBindingModal() {
            document.getElementById('shopeeBindingModal').classList.remove('show');
            shopeeBinding.currentStep = 0;
        }

        // 同步蝦皮訂單
        function syncShopeeOrders() {
            if (!shopeeBinding.isBound) {
                alert('請先綁定蝦皮帳號');
                return;
            }

            // 顯示同步中提示
            const syncBtn = document.getElementById('shopeeSyncBtn');
            const originalText = syncBtn.innerHTML;
            syncBtn.innerHTML = '<svg class="w-5 h-5 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg><span class="ml-2">同步中...</span>';
            syncBtn.disabled = true;

            // 模擬 API 呼叫延遲
            setTimeout(() => {
                // 將蝦皮訂單加入到系統中
                mockShopeeOrders.forEach(shopeeOrder => {
                    // 檢查是否已存在
                    const exists = orders.some(order => order.orderCode === shopeeOrder.orderCode);
                    if (!exists) {
                        orders.push({...shopeeOrder});
                    }
                });

                // 更新最後同步時間
                shopeeBinding.lastSyncTime = new Date().toLocaleString('zh-TW');
                localStorage.setItem('shopeeBinding', JSON.stringify(shopeeBinding));
                document.getElementById('lastSyncTime').textContent = shopeeBinding.lastSyncTime;

                // 儲存並更新顯示
                saveToStorage();
                updateStats();
                renderOrders();

                // 恢復按鈕
                syncBtn.innerHTML = originalText;
                syncBtn.disabled = false;

                alert(`✅ 同步完成！\n\n已匯入 ${mockShopeeOrders.length} 筆蝦皮訂單`);
            }, 2000);
        }

        // 解除綁定
        function unbindShopee() {
            if (confirm('確定要解除蝦皮帳號綁定嗎？\n\n解除後將無法自動同步訂單。')) {
                shopeeBinding = {
                    isBound: false,
                    currentStep: 0,
                    accountName: '',
                    authCode: '',
                    lastSyncTime: null
                };
                localStorage.removeItem('shopeeBinding');
                updateShopeeStatus();
                alert('已成功解除綁定');
            }
        }

        // 切換分頁
        function switchTab(tab) {
            currentTab = tab;
            document.getElementById('ordersTab').className = tab === 'orders' ? 'px-6 py-4 font-medium tab-active flex items-center gap-2' : 'px-6 py-4 font-medium tab-inactive flex items-center gap-2';
            document.getElementById('commoditiesTab').className = tab === 'commodities' ? 'px-6 py-4 font-medium tab-active flex items-center gap-2' : 'px-6 py-4 font-medium tab-inactive flex items-center gap-2';
            document.getElementById('ordersTable').style.display = tab === 'orders' ? 'block' : 'none';
            document.getElementById('commoditiesTable').style.display = tab === 'commodities' ? 'block' : 'none';
        }

        // 更新統計數據
        function updateStats() {
            document.getElementById('totalOrders').textContent = orders.length;
            document.getElementById('totalCommodities').textContent = commodities.length;
            const totalInv = commodities.reduce((sum, item) => sum + item.inventory, 0);
            document.getElementById('totalInventory').textContent = totalInv;
            const pending = orders.filter(o => o.status === '待出貨').length;
            document.getElementById('pendingOrders').textContent = pending;
        }

        // 渲染訂單表格
        function renderOrders() {
            const tbody = document.getElementById('ordersBody');
            tbody.innerHTML = '';
            orders.forEach((order, index) => {
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50';
                row.innerHTML = `
                    <td class="px-6 py-4 text-sm text-gray-900">${order.orderCode}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.commodityName}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.size}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.color}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.quantity}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.recipient}</td>
                    <td class="px-6 py-4">
                        <span class="px-3 py-1 text-xs font-medium rounded-full ${getStatusClass(order.status)}">
                            ${order.status}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                        <button onclick="editOrder(${index})" class="text-blue-600 hover:underline mr-3">編輯</button>
                        <button onclick="deleteOrder(${index})" class="text-red-600 hover:underline">刪除</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        // 渲染商品表格
        function renderCommodities() {
            const tbody = document.getElementById('commoditiesBody');
            tbody.innerHTML = '';
            commodities.forEach((item, index) => {
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50';
                row.innerHTML = `
                    <td class="px-6 py-4 text-sm text-gray-900">${item.code}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.name}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.category}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.size}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.color}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">NT$ ${item.price.toLocaleString()}</td>
                    <td class="px-6 py-4 text-sm">
                        <span class="px-3 py-1 text-xs font-medium rounded-full ${getInventoryClass(item.inventory)}">
                            ${item.inventory} 件
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                        <button onclick="editCommodity(${index})" class="text-blue-600 hover:underline mr-3">編輯</button>
                        <button onclick="deleteCommodity(${index})" class="text-red-600 hover:underline">刪除</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        // 狀態樣式
        function getStatusClass(status) {
            switch(status) {
                case '待出貨': return 'bg-yellow-100 text-yellow-800';
                case '已出貨': return 'bg-blue-100 text-blue-800';
                case '已送達': return 'bg-green-100 text-green-800';
                case '已取消': return 'bg-red-100 text-red-800';
                default: return 'bg-gray-100 text-gray-800';
            }
        }

        function getInventoryClass(inventory) {
            if (inventory <= 5) return 'bg-red-100 text-red-800';
            if (inventory <= 10) return 'bg-yellow-100 text-yellow-800';
            return 'bg-green-100 text-green-800';
        }

        // 新增項目
        function addItem() {
            editingIndex = -1;
            if (currentTab === 'orders') {
                openOrderModal();
            } else {
                openCommodityModal();
            }
        }

        // 訂單操作
        function editOrder(index) {
            editingIndex = index;
            const order = orders[index];
            document.getElementById('editOrderCode').value = order.orderCode;
            document.getElementById('editOrderName').value = order.commodityName;
            document.getElementById('editOrderSize').value = order.size;
            document.getElementById('editOrderColor').value = order.color;
            document.getElementById('editOrderQuantity').value = order.quantity;
            document.getElementById('editOrderRecipient').value = order.recipient;
            document.getElementById('editOrderAddress').value = order.address || '';
            document.getElementById('orderModalTitle').textContent = '編輯訂單';
            document.getElementById('orderModal').classList.add('show');
        }

        function deleteOrder(index) {
            if (confirm('確定要刪除此訂單嗎？')) {
                orders.splice(index, 1);
                saveToStorage();
                updateStats();
                renderOrders();
            }
        }

        function openOrderModal() {
            document.getElementById('editOrderCode').value = 'ORD-' + Date.now();
            document.getElementById('editOrderName').value = '';
            document.getElementById('editOrderSize').value = 'M';
            document.getElementById('editOrderColor').value = '';
            document.getElementById('editOrderQuantity').value = '1';
            document.getElementById('editOrderRecipient').value = '';
            document.getElementById('editOrderAddress').value = '';
            document.getElementById('orderModalTitle').textContent = '新增訂單';
            document.getElementById('orderModal').classList.add('show');
        }

        function saveOrder() {
            const order = {
                orderCode: document.getElementById('editOrderCode').value,
                commodityName: document.getElementById('editOrderName').value,
                size: document.getElementById('editOrderSize').value,
                color: document.getElementById('editOrderColor').value,
                quantity: parseInt(document.getElementById('editOrderQuantity').value),
                recipient: document.getElementById('editOrderRecipient').value,
                address: document.getElementById('editOrderAddress').value,
                status: '待出貨'
            };

            if (!order.commodityName || !order.recipient) {
                alert('請填寫必填欄位');
                return;
            }

            if (editingIndex === -1) {
                orders.push(order);
            } else {
                orders[editingIndex] = order;
            }

            saveToStorage();
            updateStats();
            renderOrders();
            closeOrderModal();
        }

        function closeOrderModal() {
            document.getElementById('orderModal').classList.remove('show');
        }

        // 商品操作
        function editCommodity(index) {
            editingIndex = index;
            const item = commodities[index];
            document.getElementById('editCommodityCode').value = item.code;
            document.getElementById('editCommodityName').value = item.name;
            document.getElementById('editCommodityCategory').value = item.category;
            document.getElementById('editCommoditySize').value = item.size;
            document.getElementById('editCommodityColor').value = item.color;
            document.getElementById('editCommodityPrice').value = item.price;
            document.getElementById('editCommodityInventory').value = item.inventory;
            document.getElementById('commodityModalTitle').textContent = '編輯商品';
            document.getElementById('commodityModal').classList.add('show');
        }

        function deleteCommodity(index) {
            if (confirm('確定要刪除此商品嗎？')) {
                commodities.splice(index, 1);
                saveToStorage();
                updateStats();
                renderCommodities();
            }
        }

        function openCommodityModal() {
            document.getElementById('editCommodityCode').value = 'CLO-' + Date.now();
            document.getElementById('editCommodityName').value = '';
            document.getElementById('editCommodityCategory').value = '上衣';
            document.getElementById('editCommoditySize').value = 'M';
            document.getElementById('editCommodityColor').value = '';
            document.getElementById('editCommodityPrice').value = '';
            document.getElementById('editCommodityInventory').value = '';
            document.getElementById('commodityModalTitle').textContent = '新增商品';
            document.getElementById('commodityModal').classList.add('show');
        }

        function saveCommodity() {
            const item = {
                code: document.getElementById('editCommodityCode').value,
                name: document.getElementById('editCommodityName').value,
                category: document.getElementById('editCommodityCategory').value,
                size: document.getElementById('editCommoditySize').value,
                color: document.getElementById('editCommodityColor').value,
                price: parseInt(document.getElementById('editCommodityPrice').value),
                inventory: parseInt(document.getElementById('editCommodityInventory').value)
            };

            if (!item.name || !item.price || !item.inventory) {
                alert('請填寫必填欄位');
                return;
            }

            if (editingIndex === -1) {
                commodities.push(item);
            } else {
                commodities[editingIndex] = item;
            }

            saveToStorage();
            updateStats();
            renderCommodities();
            closeCommodity
            
            function saveCommodity() {
            const item = {
                code: document.getElementById('editCommodityCode').value,
                name: document.getElementById('editCommodityName').value,
                category: document.getElementById('editCommodityCategory').value,
                size: document.getElementById('editCommoditySize').value,
                color: document.getElementById('editCommodityColor').value,
                price: parseInt(document.getElementById('editCommodityPrice').value),
                inventory: parseInt(document.getElementById('editCommodityInventory').value)
            };

            if (!item.name || !item.price || !item.inventory) {
                alert('請填寫必填欄位');
                return;
            }

            if (editingIndex === -1) {
                commodities.push(item);
            } else {
                commodities[editingIndex] = item;
            }

            saveToStorage();
            updateStats();
            renderCommodities();
            closeCommodityModal();
        }

        function closeCommodityModal() {
            document.getElementById('commodityModal').classList.remove('show');
        }

        // 搜尋功能
        function searchItems() {
            const keyword = document.getElementById('searchInput').value.toLowerCase();
            const results = document.getElementById('searchResults');
            
            if (!keyword) {
                results.textContent = '';
                if (currentTab === 'orders') {
                    renderOrders();
                } else {
                    renderCommodities();
                }
                return;
            }

            if (currentTab === 'orders') {
                const filtered = orders.filter(order => 
                    order.orderCode.toLowerCase().includes(keyword) ||
                    order.commodityName.toLowerCase().includes(keyword) ||
                    order.size.toLowerCase().includes(keyword) ||
                    order.color.toLowerCase().includes(keyword) ||
                    order.recipient.toLowerCase().includes(keyword)
                );
                results.textContent = `找到 ${filtered.length} 筆訂單`;
                renderFilteredOrders(filtered);
            } else {
                const filtered = commodities.filter(item =>
                    item.code.toLowerCase().includes(keyword) ||
                    item.name.toLowerCase().includes(keyword) ||
                    item.category.toLowerCase().includes(keyword) ||
                    item.size.toLowerCase().includes(keyword) ||
                    item.color.toLowerCase().includes(keyword)
                );
                results.textContent = `找到 ${filtered.length} 筆商品`;
                renderFilteredCommodities(filtered);
            }
        }

        function renderFilteredOrders(filtered) {
            const tbody = document.getElementById('ordersBody');
            tbody.innerHTML = '';
            filtered.forEach((order, index) => {
                const originalIndex = orders.indexOf(order);
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50';
                row.innerHTML = `
                    <td class="px-6 py-4 text-sm text-gray-900">${order.orderCode}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.commodityName}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.size}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.color}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.quantity}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${order.recipient}</td>
                    <td class="px-6 py-4">
                        <span class="px-3 py-1 text-xs font-medium rounded-full ${getStatusClass(order.status)}">
                            ${order.status}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                        <button onclick="editOrder(${originalIndex})" class="text-blue-600 hover:underline mr-3">編輯</button>
                        <button onclick="deleteOrder(${originalIndex})" class="text-red-600 hover:underline">刪除</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        function renderFilteredCommodities(filtered) {
            const tbody = document.getElementById('commoditiesBody');
            tbody.innerHTML = '';
            filtered.forEach((item, index) => {
                const originalIndex = commodities.indexOf(item);
                const row = document.createElement('tr');
                row.className = 'hover:bg-gray-50';
                row.innerHTML = `
                    <td class="px-6 py-4 text-sm text-gray-900">${item.code}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.name}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.category}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.size}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">${item.color}</td>
                    <td class="px-6 py-4 text-sm text-gray-900">NT$ ${item.price.toLocaleString()}</td>
                    <td class="px-6 py-4 text-sm">
                        <span class="px-3 py-1 text-xs font-medium rounded-full ${getInventoryClass(item.inventory)}">
                            ${item.inventory} 件
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm">
                        <button onclick="editCommodity(${originalIndex})" class="text-blue-600 hover:underline mr-3">編輯</button>
                        <button onclick="deleteCommodity(${originalIndex})" class="text-red-600 hover:underline">刪除</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        function clearSearch() {
            document.getElementById('searchInput').value = '';
            document.getElementById('searchResults').textContent = '';
            if (currentTab === 'orders') {
                renderOrders();
            } else {
                renderCommodities();
            }
        }

        // 匯出資料
        function exportData() {
            let data, filename;
            
            if (currentTab === 'orders') {
                data = orders;
                filename = '訂單資料_' + new Date().toISOString().split('T')[0] + '.json';
            } else {
                data = commodities;
                filename = '商品資料_' + new Date().toISOString().split('T')[0] + '.json';
            }

            const dataStr = JSON.stringify(data, null, 2);
            const dataBlob = new Blob([dataStr], { type: 'application/json' });
            const url = URL.createObjectURL(dataBlob);
            const link = document.createElement('a');
            link.href = url;
            link.download = filename;
            link.click();
            URL.revokeObjectURL(url);

            alert('資料已匯出');
        }

        // LocalStorage 操作
        function saveToStorage() {
            localStorage.setItem('orders', JSON.stringify(orders));
            localStorage.setItem('commodities', JSON.stringify(commodities));
        }

        function loadFromStorage() {
            const savedOrders = localStorage.getItem('orders');
            const savedCommodities = localStorage.getItem('commodities');
            
            if (savedOrders) {
                orders = JSON.parse(savedOrders);
            }
            if (savedCommodities) {
                commodities = JSON.parse(savedCommodities);
            }
        }

        // 點擊 Modal 外部關閉
        window.onclick = function(event) {
            const orderModal = document.getElementById('orderModal');
            const commodityModal = document.getElementById('commodityModal');
            const shopeeModal = document.getElementById('shopeeBindingModal');
            
            if (event.target === orderModal) {
                closeOrderModal();
            }
            if (event.target === commodityModal) {
                closeCommodityModal();
            }
            if (event.target === shopeeModal) {
                closeShopeeBindingModal();
            }
        }
    </script>
</body>
</html>