<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="CZ.group.tool.upload.FolderConfig2" %>
<%@ page import="CZ.group.tool.database.DBConfig" %>
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>上傳處理</title>
</head>
<body>
<%
try {
    // 確保路徑有斜線
    String uploadPath = objFolderConfig.FilePath();
    if (!uploadPath.endsWith("\\") && !uploadPath.endsWith("/")) {
        uploadPath += File.separator;  // 自動加上系統的分隔符
    }
    
    out.println("<p>上傳路徑：" + uploadPath + "</p>");
    
    // 文件上傳邏輯
    MultipartRequest theMultipartRequest = new MultipartRequest(
        request,
        uploadPath,  // 使用修正後的路徑
        10 * 1024 * 1024,
        "UTF-8"
    );
    
    String fileName = theMultipartRequest.getFilesystemName("theFirstFile");
    String memberId = theMultipartRequest.getParameter("memberId");
    
    out.println("<p>文件名稱：" + fileName + "</p>");
    
    if (fileName != null && !fileName.isEmpty()) {
        // 檢查文件是否成功保存
        String fullPath = uploadPath + fileName;
        File uploadedFile = new File(fullPath);
        
        out.println("<p>完整路徑：" + fullPath + "</p>");
        out.println("<p>文件是否存在：" + uploadedFile.exists() + "</p>");
        
        if (!uploadedFile.exists()) {
            // 列出目錄中的所有文件，看看文件是否在別的地方
            File dir = new File(uploadPath);
            out.println("<p>目錄內容：</p><ul>");
            File[] files = dir.listFiles();
            if(files != null) {
                for(File f : files) {
                    out.println("<li>" + f.getName() + "</li>");
                }
            }
            out.println("</ul>");
            
            throw new Exception("文件未成功保存！");
        }
        
        // 更新數據庫圖片字段
        String relativePath = objFolderConfig.WebsiteRelativeFilePath() + fileName;
        
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection(
            "jdbc:ucanaccess://" + objDBConfig.FilePath() + ";"
        );
        
        String sql = "UPDATE personal_information SET pic = ? WHERE memberId = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, relativePath);
        pstmt.setString(2, memberId);
        
        int updateCount = pstmt.executeUpdate();
        
        pstmt.close();
        con.close();
        
        if(updateCount > 0) {
        	response.sendRedirect("member.jsp?memberId=" + session.getAttribute("accessId"));
        } else {
            out.println("<p style='color:red;'>✗ 數據庫更新失敗！</p>");
        }
        
    } else {
        out.println("<p style='color:red;'>✗ 未選擇文件或文件名稱為空！</p>");
    }
    
} catch (Exception e) {
    e.printStackTrace();
    out.println("<h3 style='color:red;'>發生錯誤：</h3>");
    out.println("<pre>" + e.getMessage() + "</pre>");
    out.println("<p><a href='member.jsp?memberId=" + session.getAttribute("accessId") + "'>返回會員頁面</a></p>");
}
%>
</body>
</html>