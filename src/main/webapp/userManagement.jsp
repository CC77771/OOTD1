<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />

<%!
    // 資料庫連線方法
    public Connection getConnection(String dbPath) throws Exception {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        return DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
    }
%>

<%
    String dbPath = objDBConfig.FilePath();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String message = "";
    String messageType = "";
    
    // 處理黑名單切換請求
    String action = request.getParameter("action");
    String memberId = request.getParameter("memberId");
    
    if (action != null && memberId != null && !memberId.trim().isEmpty()) {
        try {
            conn = getConnection(dbPath);
            
            if ("toggle".equals(action)) {
                // 先查詢當前狀態
                String selectSql = "SELECT blacklist, nickName FROM personal_information WHERE memberId = ?";
                pstmt = conn.prepareStatement(selectSql);
                pstmt.setString(1, memberId);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    boolean currentStatus = rs.getBoolean("blacklist");
                    String nickName = rs.getString("nickName");
                    rs.close();
                    pstmt.close();
                    
                    // 更新為相反狀態
                    String updateSql = "UPDATE personal_information SET blacklist = ? WHERE memberId = ?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setBoolean(1, !currentStatus);
                    pstmt.setString(2, memberId);
                    int result = pstmt.executeUpdate();
                    
                    if (result > 0) {
                        String displayName = (nickName != null && !nickName.trim().isEmpty()) ? nickName : memberId;
                        if (!currentStatus) {
                            message = "使用者「" + displayName + "」已停權，該帳號將無法登入系統";
                            messageType = "danger";
                        } else {
                            message = "使用者「" + displayName + "」已解除停權，可以正常登入";
                            messageType = "success";
                        }
                    }
                }
            }
        } catch (Exception e) {
            message = "操作失敗：" + e.getMessage();
            messageType = "danger";
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
    // 計算統計數據
    int totalUsers = 0;
    int normalUsers = 0;
    int bannedUsers = 0;
    
    try {
        conn = getConnection(dbPath);
        
        String countSql = "SELECT COUNT(*) as total, " +
                        "SUM(IIF(blacklist = True, 1, 0)) as banned, " +
                        "SUM(IIF(blacklist = False, 1, 0)) as normal " +
                        "FROM personal_information";
        pstmt = conn.prepareStatement(countSql);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            totalUsers = rs.getInt("total");
            bannedUsers = rs.getInt("banned");
            normalUsers = rs.getInt("normal");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<%@include file="menu.jsp" %>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>使用者管理 - CZ_OOTD</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Jost:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        /* Tabs 容器 - 置中 & 下移 & 緊湊 */
        #adminTab {
            display: flex !important;          
            justify-content: center !important; 
            flex-wrap: wrap;                   
            gap: 30px;                         
            margin: 50px auto 20px auto;       
        }

        /* Tab 按鈕美化 - 卡片風格 */
        .nav-tabs .nav-link {
            font-size: 35px;          
            padding: 15px 30px;       
            font-weight: 600;
            color: #333;
            border-radius: 15px;
            text-align: center;
            background: #ffffff;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            border: 1px solid #ddd;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        /* Hover 效果 */
        .nav-tabs .nav-link:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            background: #f9f9f9;
        }

        /* Active 卡片 - 藍色背景 */
        .nav-tabs .nav-link.active {
            background: #0d6efd !important;
            color: #ffffff !important;
            border: 1px solid #0d6efd;
            box-shadow: 0 6px 15px rgba(13,110,253,0.3);
            transform: translateY(-3px);
        }

        /* 移除底線 */
        .nav-tabs {
            border-bottom: none !important;
        }

        body {
            background-color: #f8f9fa;
            font-family: 'Jost', sans-serif;
        }
        
        .admin-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .admin-header {
            background: linear-gradient(135deg, #a89f91 0%, #8f8c7f 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .admin-header h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 600;
        }
        
        .back-btn {
            background: white;
            color: #a89f91;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .back-btn:hover {
            background: #f0f0f0;
            transform: translateY(-2px);
        }
        
        .content-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }
        
        .search-box input {
            width: 300px;
            border: 2px solid #ddd;
            border-radius: 8px;
            padding: 8px 15px;
            font-size: 14px;
        }
        
        .search-box input:focus {
            border-color: #a89f91;
            outline: none;
            box-shadow: 0 0 0 0.2rem rgba(168, 159, 145, 0.25);
        }
        
        table {
            width: 100%;
            margin: 0;
        }
        
        thead {
            background-color: #f8f9fa;
        }
        
        th {
            padding: 15px 12px;
            text-align: left;
            font-weight: 600;
            color: #495057;
            font-size: 14px;
            white-space: nowrap;
        }
        
        th.center, td.center {
            text-align: center;
        }
        
        tbody tr {
            border-bottom: 1px solid #dee2e6;
            transition: background-color 0.2s;
        }
        
        tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        tbody tr.blacklisted {
            background-color: #fff5f5;
        }
        
        td {
            padding: 15px 12px;
            color: #495057;
            font-size: 14px;
        }
        
        .status-badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
        }
        
        .status-badge.normal {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-badge.banned {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .btn-action {
            padding: 7px 15px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.3s;
            margin: 2px;
            white-space: nowrap;
        }
        
        .btn-ban {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-ban:hover {
            background-color: #c82333;
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(220, 53, 69, 0.3);
        }
        
        .btn-unban {
            background-color: #28a745;
            color: white;
        }
        
        .btn-unban:hover {
            background-color: #218838;
            transform: translateY(-1px);
            box-shadow: 0 2px 5px rgba(40, 167, 69, 0.3);
        }
        
        .message-alert {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 350px;
            animation: slideIn 0.3s ease-out;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        .stats-row {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            flex: 1;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
        }
        
        .stat-card h3 {
            font-size: 36px;
            font-weight: 700;
            color: #a89f91;
            margin: 10px 0 5px 0;
        }
        
        .stat-card p {
            color: #666;
            margin: 0;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="admin-container">
        <div class="admin-header">
            <h1>🛠️ 管理者控制台</h1>
            <p>歡迎回來 | 管理 CZ_OOTD 平台內容與使用者</p>
        </div>

        <!-- 分頁導航 -->
        <ul class="nav nav-tabs" id="adminTab" role="tablist">
            <li class="nav-item">
                <a class="nav-link" href="commentManagement.jsp">💬 評論審核</a>
            </li>
            
            <li class="nav-item">
                <a class="nav-link" href="postManagement.jsp">📝 貼文審核</a>
            </li>

            <li class="nav-item">
                <a class="nav-link active">👥 一般會員管理</a>
            </li>
            
            <li class="nav-item">
                <a class="nav-link" href="analyticsManagement.jsp">📊 點擊率分析</a>
            </li>
        </ul>
        
        <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= messageType %> alert-dismissible fade show message-alert" role="alert">
            <strong><%= messageType.equals("success") ? "✓ 成功！" : "⚠ 注意！" %></strong> <%= message %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <script>
            setTimeout(function() {
                var alert = document.querySelector('.message-alert');
                if (alert) {
                    var bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                }
            }, 4000);
        </script>
        <% } %>
        
        <!-- 統計卡片 -->
        <div class="stats-row">
            <div class="stat-card">
                <p>總使用者數</p>
                <h3><%= totalUsers %></h3>
            </div>
            <div class="stat-card">
                <p>正常使用者</p>
                <h3 style="color: #28a745;"><%= normalUsers %></h3>
            </div>
            <div class="stat-card">
                <p>已停權使用者</p>
                <h3 style="color: #dc3545;"><%= bannedUsers %></h3>
            </div>
        </div>
        
        <!-- 使用者列表 -->
        <div class="content-card">
            <div class="d-flex justify-content-between mb-3">
                <h5 class="mb-0">會員列表</h5>
                <div class="search-box">
                    <input type="text" id="userSearch" class="form-control" placeholder="🔍 搜尋使用者名稱或電子郵件...">
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>帳號</th>
                            <th>使用者名稱</th>
                            <th>電子郵件</th>
                            <th>註冊日期</th>
                            <th class="center">狀態</th>
                            <th class="center">操作</th>
                        </tr>
                    </thead>
                    <tbody id="userTableBody">
                        <%
                            try {
                                conn = getConnection(dbPath);
                                
                                String sql = "SELECT * FROM personal_information ORDER BY register_date DESC";
                                pstmt = conn.prepareStatement(sql);
                                rs = pstmt.executeQuery();
                                
                                while (rs.next()) {
                                	String userId = rs.getString("memberId");
                                	String userNickName = rs.getString("nickName");
                                	String userEmail = rs.getString("Email");
                                	String userRegisterDate = rs.getString("register_date");
                                	// 格式化日期,只顯示日期部分
                                	if (userRegisterDate != null && userRegisterDate.contains(" ")) {
                                	    userRegisterDate = userRegisterDate.split(" ")[0];
                                	}
                                	boolean userBlacklist = rs.getBoolean("blacklist");
                                    
                                    String rowClass = userBlacklist ? "blacklisted" : "";
                                    String displayName = (userNickName != null && !userNickName.trim().isEmpty()) ? userNickName : "未設定";

                        %>
                        <tr class="<%= rowClass %>" data-search="<%= userId %> <%= userNickName %> <%= userEmail %>">
                           <td><strong><%= userId != null ? userId : "" %></strong></td>
                            <td><%= displayName %></td>
                            <td><%= userEmail != null ? userEmail : "" %></td>
                            <td><%= userRegisterDate != null ? userRegisterDate : "" %></td>
                            <td class="center">
                                <% if (userBlacklist) { %>
                                    <span class="status-badge banned">已停權</span>
                                <% } else { %>
                                    <span class="status-badge normal">正常</span>
                                <% } %>
                            </td>
                            <td class="center">
                                <form action="userManagement.jsp" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="memberId" value="<%= userId %>">
                                    <% if (userBlacklist) { %>
                                        <button type="submit" class="btn-action btn-unban" 
                                                onclick="return confirm('確定要解除停權使用者「<%= userId %>」嗎？\n\n解除後該會員將可以正常登入系統。');">
                                            解除停權
                                        </button>
                                    <% } else { %>
                                        <button type="submit" class="btn-action btn-ban" 
                                                onclick="return confirm('確定要停權使用者「<%= userId %>」嗎？\n\n停權後該會員將無法登入系統，\n嘗試登入時會看到停權提示訊息。');">
                                            停權
                                        </button>
                                    <% } %>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='6' style='text-align:center; color:red; padding: 30px;'>");
                                out.println("<strong>資料讀取錯誤</strong><br>");
                                out.println("錯誤訊息：" + e.getMessage() + "<br>");
                                out.println("請確認：<br>");
                                out.println("1. 資料庫路徑是否正確<br>");
                                out.println("2. UCanAccess 相關 JAR 檔是否已加入<br>");
                                out.println("3. 資料表名稱是否為 personal_information");
                                out.println("</td></tr>");
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch(Exception e) {}
                                if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                                if (conn != null) try { conn.close(); } catch(Exception e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="alert alert-info mt-4" style="border-left: 4px solid #2196F3;">
            <h6 class="alert-heading"><strong>📌 功能說明</strong></h6>
            <ul class="mb-0" style="padding-left: 20px;">
                <li>點擊「停權」按鈕將使用者加入黑名單，該帳號將無法登入系統</li>
                <li>被停權的帳號嘗試登入時會顯示：<span style="color: #dc3545; font-weight: 500;">「該帳號已被停權封禁，請聯繫系統管理員進行帳號解鎖」</span></li>
                <li>點擊「解除停權」可恢復會員的登入權限</li>
                <li>使用上方搜尋框可快速查找特定使用者</li>
                <li>被停權的使用者該列會以紅色背景標示</li>
            </ul>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 搜尋功能
        document.getElementById('userSearch').addEventListener('input', function(e) {
            var searchText = e.target.value.toLowerCase();
            var rows = document.querySelectorAll('#userTableBody tr');
            
            rows.forEach(function(row) {
                var searchData = row.getAttribute('data-search');
                if (searchData && searchData.toLowerCase().includes(searchText)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    </script>
</body>
</html>