<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file="menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>編輯個人資料 - CZ Web</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f1f1f0;
            margin: 0;
            padding: 0;
        }
        
        .container {
            max-width: 650px;
            margin: 40px auto;
            background: #fff;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        .page-title {
            text-align: center;
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
            font-weight: 600;
        }
        
        .page-subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        
        .profile-image-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 10px;
        }
        
        .profile-image-section img {
            width: 140px;
            height: 140px;
            border-radius: 50%;
            border: 3px solid #a89f91;
            object-fit: cover;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            margin-bottom: 15px;
        }
        
        .upload-btn-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
        }
        
        .upload-btn {
            background-color: #a89f91;
            color: white;
            padding: 10px 25px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .upload-btn:hover {
            background-color: #8b8d7a;
        }
        
        .upload-btn-wrapper input[type=file] {
            font-size: 100px;
            position: absolute;
            left: 0;
            top: 0;
            opacity: 0;
            cursor: pointer;
        }
        
        .form-section {
            margin-bottom: 25px;
        }
        
        .form-section label {
            display: block;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-section label i {
            margin-right: 5px;
            color: #a89f91;
        }
        
        .required {
            color: #e74c3c;
            margin-left: 3px;
        }
        
        .form-section input[type="text"],
        .form-section input[type="email"],
        .form-section input[type="date"],
        .form-section input[type="password"],
        .form-section select {
            width: 100%;
            padding: 12px 15px;
            font-size: 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            box-sizing: border-box;
            background-color: #f9f9f9;
            transition: border-color 0.3s, background-color 0.3s;
        }
        
        .form-section input:focus,
        .form-section select:focus {
            outline: none;
            border-color: #a89f91;
            background-color: #fff;
        }
        
        .form-section input:disabled {
            background-color: #e9ecef;
            cursor: not-allowed;
            color: #6c757d;
        }
        
        .form-section .hint {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
            display: block;
        }
        
        .password-section {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin: 25px 0;
            border: 1px solid #e9ecef;
        }
        
        .password-section h4 {
            margin: 0 0 15px 0;
            color: #333;
            font-size: 16px;
        }
        
        .password-toggle {
            margin-bottom: 15px;
        }
        
        .password-toggle label {
            display: flex;
            align-items: center;
            cursor: pointer;
            font-weight: normal;
        }
        
        .password-toggle input[type="checkbox"] {
            margin-right: 8px;
            width: 18px;
            height: 18px;
            cursor: pointer;
        }
        
        .password-fields {
            display: none;
        }
        
        .password-fields.active {
            display: block;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn {
            flex: 1;
            padding: 14px 20px;
            font-size: 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s, transform 0.1s;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .btn:active {
            transform: scale(0.98);
        }
        
        .btn-primary {
            background-color: #a89f91;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #8b8d7a;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
        }
        
        .info-box {
            background-color: #e8f4f8;
            border-left: 4px solid #17a2b8;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 25px;
        }
        
        .info-box p {
            margin: 0;
            color: #0c5460;
            font-size: 14px;
        }
        
        .danger-zone {
            margin-top: 40px;
            padding: 20px;
            background-color: #fff5f5;
            border: 2px solid #feb2b2;
            border-radius: 8px;
        }
        
        .danger-zone h4 {
            color: #c53030;
            margin: 0 0 10px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .danger-zone p {
            color: #742a2a;
            font-size: 14px;
            margin-bottom: 15px;
        }
        
        @media screen and (max-width: 600px) {
            .container {
                margin: 20px;
                padding: 25px;
            }
            
            .button-group {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
            
            .profile-image-section img {
                width: 120px;
                height: 120px;
            }
        }
    </style>
</head>
<body>
<%
try {
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
    Statement smt = con.createStatement();
    
    String memberId = request.getParameter("memberId");
    if (memberId == null || memberId.trim().isEmpty()) {
        memberId = (String) session.getAttribute("accessId");
    }
    
    if (memberId == null || memberId.trim().isEmpty()) {
        out.println("<div class='container'>");
        out.println("<h2>❌ 錯誤</h2>");
        out.println("<p>無法取得會員ID，請先登入</p>");
        out.println("<a href='login.jsp'>返回登入</a>");
        out.println("</div>");
        out.println("</body></html>");
        return;
    }
    
    String sql = "SELECT pi.*, g.gender, p.positionName " +
                 "FROM personal_information pi " +
                 "LEFT JOIN gender g ON pi.gendercode = g.gendercode " +
                 "LEFT JOIN position p ON pi.positionId = p.positionId " +
                 "WHERE pi.memberId = '" + memberId + "'";
    
    ResultSet rs = smt.executeQuery(sql);
    
    if (!rs.next()) {
        out.println("<div class='container'>");
        out.println("<h2>❌ 找不到會員資料</h2>");
        out.println("<p>memberId = " + memberId + "</p>");
        out.println("<a href='member.jsp'>返回會員頁面</a>");
        out.println("</div>");
        out.println("</body></html>");
        return;
    }
    
    String profilePic = rs.getString("pic");
    String nickName = rs.getString("nickName");
    String gender = rs.getString("gender");
    String genderCode = rs.getString("gendercode");
    String born = rs.getString("born");
    String email = rs.getString("Email");
    String registerDate = rs.getString("register_date");
    
    if (profilePic == null || profilePic.trim().isEmpty()) profilePic = "images/default-avatar.jpg";
    if (nickName == null) nickName = "";
    if (genderCode == null) genderCode = "";
    if (born == null) born = "";
    if (email == null) email = "";
    if (registerDate == null) registerDate = "";
    
    if (born.contains(" ")) born = born.split(" ")[0];
    if (registerDate.contains(" ")) registerDate = registerDate.split(" ")[0];
    if (email.contains("#")) email = email.split("#")[0];
%>

<div class="container">
    <h2 class="page-title">
        <i class="fas fa-user-edit"></i> 編輯個人資料
    </h2>
    <p class="page-subtitle">更新您的個人資訊</p>
    
    <div class="profile-image-section">
        <img src="<%= profilePic %>?t=<%= System.currentTimeMillis() %>" 
             alt="Profile Picture"
             id="profilePreview"
             onerror="this.src='images/default-avatar.jpg'">
        
        <form action="memberEdit_DBUpdate_pic.jsp" method="post" enctype="multipart/form-data" id="uploadForm">
            <input type="hidden" name="memberId" value="<%= memberId %>">
            <input type="hidden" name="redirectPage" value="member.jsp">
            <div class="upload-btn-wrapper">
                <button type="button" class="upload-btn" onclick="document.getElementById('fileInput').click()">
                    <i class="fas fa-camera"></i> 更換大頭照
                </button>
                <input type="file" name="theFirstFile" id="fileInput" accept="image/*" onchange="previewAndUpload(this)">
            </div>
        </form>
        <span class="hint" style="margin-top: 10px;">支援 JPG、PNG、GIF 格式</span>
    </div>
    
    <div class="info-box">
        <p><i class="fas fa-info-circle"></i> 標記 <span class="required">*</span> 的欄位為必填項目</p>
    </div>
    
    <form action="memberEdit_DBUpdate_info.jsp?memberId=<%= memberId %>" method="post" name="editForm" onsubmit="return validateForm()">
        
        <div class="form-section">
            <label><i class="fas fa-id-card"></i> 會員ID</label>
            <input type="text" value="<%= memberId %>" disabled>
            <span class="hint">此欄位不可修改</span>
        </div>
        
        <div class="form-section">
            <label><i class="fas fa-user"></i> 暱稱 <span class="required">*</span></label>
            <input type="text" name="nickName" id="nickName" value="<%= nickName %>" 
                   required maxlength="50" placeholder="請輸入您的暱稱">
            <span class="hint">最多50個字元</span>
        </div>
        
        <div class="form-section">
            <label><i class="fas fa-venus-mars"></i> 性別 <span class="required">*</span></label>
            <select name="gendercode" id="gendercode" required>
                <option value="">請選擇性別</option>
                <% 
                    Statement smtGender = con.createStatement();
                    ResultSet rsGender = smtGender.executeQuery("SELECT * FROM gender");
                    while (rsGender.next()) { 
                        String selected = rsGender.getString("gendercode").equals(genderCode) ? "selected" : "";
                %>
                    <option value="<%= rsGender.getString("gendercode") %>" <%= selected %>>
                        <%= rsGender.getString("gender") %>
                    </option>
                <% 
                    } 
                    rsGender.close();
                    smtGender.close();
                %>
            </select>
        </div>
        
        <div class="form-section">
            <label><i class="fas fa-birthday-cake"></i> 生日</label>
            <input type="date" name="born" id="born" value="<%= born %>" 
                   max="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            <span class="hint">選填欄位</span>
        </div>
        
        <div class="form-section">
            <label><i class="fas fa-envelope"></i> 電子信箱 <span class="required">*</span></label>
            <input type="email" name="Email" id="Email" value="<%= email %>" 
                   required maxlength="100" placeholder="example@email.com">
            <span class="hint">用於接收重要通知</span>
        </div>
        
        <div class="password-section">
            <h4><i class="fas fa-lock"></i> 密碼設定</h4>
            
            <div class="password-toggle">
                <label>
                    <input type="checkbox" id="changePassword" onclick="togglePasswordFields()">
                    我要修改密碼
                </label>
            </div>
            
            <div class="password-fields" id="passwordFields">
                <div class="form-section">
                    <label><i class="fas fa-key"></i> 目前密碼 <span class="required">*</span></label>
                    <input type="password" name="currentPassword" id="currentPassword" 
                           placeholder="請輸入目前的密碼">
                </div>
                
                <div class="form-section">
                    <label><i class="fas fa-lock"></i> 新密碼 <span class="required">*</span></label>
                    <input type="password" name="newPassword" id="newPassword" 
                           placeholder="請輸入新密碼" minlength="4">
                    <span class="hint">至少4個字元</span>
                </div>
                
                <div class="form-section">
                    <label><i class="fas fa-lock"></i> 確認新密碼 <span class="required">*</span></label>
                    <input type="password" name="confirmPassword" id="confirmPassword" 
                           placeholder="再次輸入新密碼">
                </div>
            </div>
        </div>
        
        <div class="button-group">
            <button type="button" class="btn btn-secondary" onclick="confirmCancel()">
                <i class="fas fa-times"></i> 取消
            </button>
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-save"></i> 儲存變更
            </button>
        </div>
    </form>
    
    <div class="danger-zone">
        <h4>
            <i class="fas fa-exclamation-triangle"></i> 危險區域
        </h4>
        <p>刪除帳號後，所有資料將永久清除且無法復原，請謹慎操作。</p>
        <button type="button" class="btn btn-danger" onclick="confirmDelete()" style="width: auto;">
            <i class="fas fa-trash-alt"></i> 刪除我的帳號
        </button>
    </div>
</div>

<script>
function previewAndUpload(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        const fileSize = file.size / 1024 / 1024;
        
        if (fileSize > 10) {
            alert('檔案大小不能超過 10MB！');
            input.value = '';
            return;
        }
        
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
        if (!allowedTypes.includes(file.type)) {
            alert('只支援 JPG、PNG、GIF 格式的圖片！');
            input.value = '';
            return;
        }
        
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('profilePreview').src = e.target.result;
        };
        reader.readAsDataURL(file);
        
        if (confirm('確定要更換大頭照嗎？')) {
            // 立即提交表單，不等待
            document.getElementById('uploadForm').submit();
        } else {
            input.value = '';
            location.reload();
        }
    }
}

function togglePasswordFields() {
    const checkbox = document.getElementById('changePassword');
    const passwordFields = document.getElementById('passwordFields');
    const currentPassword = document.getElementById('currentPassword');
    const newPassword = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmPassword');
    
    if (checkbox.checked) {
        passwordFields.classList.add('active');
        currentPassword.required = true;
        newPassword.required = true;
        confirmPassword.required = true;
    } else {
        passwordFields.classList.remove('active');
        currentPassword.required = false;
        newPassword.required = false;
        confirmPassword.required = false;
        currentPassword.value = '';
        newPassword.value = '';
        confirmPassword.value = '';
    }
}

function validateForm() {
    const nickName = document.getElementById('nickName').value.trim();
    const gendercode = document.getElementById('gendercode').value;
    const email = document.getElementById('Email').value.trim();
    const changePassword = document.getElementById('changePassword').checked;
    
    if (!nickName) {
        alert('請輸入暱稱！');
        document.getElementById('nickName').focus();
        return false;
    }
    
    if (!gendercode) {
        alert('請選擇性別！');
        document.getElementById('gendercode').focus();
        return false;
    }
    
    if (!email) {
        alert('請輸入電子信箱！');
        document.getElementById('Email').focus();
        return false;
    }
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        alert('電子信箱格式不正確！');
        document.getElementById('Email').focus();
        return false;
    }
    
    if (changePassword) {
        const currentPassword = document.getElementById('currentPassword').value;
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        
        if (!currentPassword) {
            alert('請輸入目前的密碼！');
            document.getElementById('currentPassword').focus();
            return false;
        }
        
        if (!newPassword) {
            alert('請輸入新密碼！');
            document.getElementById('newPassword').focus();
            return false;
        }
        
        if (newPassword.length < 4) {
            alert('新密碼至少需要4個字元！');
            document.getElementById('newPassword').focus();
            return false;
        }
        
        if (newPassword !== confirmPassword) {
            alert('新密碼與確認密碼不一致！');
            document.getElementById('confirmPassword').focus();
            return false;
        }
    }
    
    return confirm('確定要儲存變更嗎？');
}

function confirmCancel() {
    if (confirm('確定要放棄所有變更並返回嗎？')) {
        location.href = 'member.jsp';
    }
}

function confirmDelete() {
    const confirmation = confirm('⚠️ 警告：刪除帳號後，所有資料將永久清除且無法復原！\n\n確定要刪除您的帳號嗎？');
    
    if (confirmation) {
        const doubleConfirm = confirm('❗ 最後確認：您真的要刪除帳號嗎？\n\n此操作無法撤銷！');
        
        if (doubleConfirm) {
            location.href = 'memberDelete.jsp?memberId=<%= memberId %>';
        }
    }
}
</script>

</body>
</html>
<%
    rs.close();
    smt.close();
    con.close();
} catch (Exception e) {
    out.println("<div class='container'>");
    out.println("<h2>❌ 系統錯誤</h2>");
    out.println("<p>" + e.getMessage() + "</p>");
    out.println("<pre>");
    e.printStackTrace(new java.io.PrintWriter(out));
    out.println("</pre>");
    out.println("<a href='member.jsp'>返回會員頁面</a>");
    out.println("</div>");
}
%>