<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>測試上傳</title>
</head>
<body>
<%
if(request.getMethod().equals("POST")) {
    try {
        String savePath = application.getRealPath("/") + File.separator + "images";
        out.println("<h3>測試結果：</h3>");
        out.println("<p>儲存路徑: " + savePath + "</p>");
        
        File saveDir = new File(savePath);
        out.println("<p>資料夾存在: " + saveDir.exists() + "</p>");
        out.println("<p>可寫入: " + saveDir.canWrite() + "</p>");
        out.println("<p>絕對路徑: " + saveDir.getAbsolutePath() + "</p>");
        
        if(!saveDir.exists()) {
            boolean created = saveDir.mkdirs();
            out.println("<p>建立資料夾: " + created + "</p>");
        }
        
        int maxSize = 5 * 1024 * 1024;
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());
        
        String fileName = multi.getFilesystemName("testFile");
        out.println("<p style='color:green;'><strong>成功！檔案名稱: " + fileName + "</strong></p>");
        
        File uploadedFile = new File(savePath + File.separator + fileName);
        out.println("<p>檔案路徑: " + uploadedFile.getAbsolutePath() + "</p>");
        out.println("<p>檔案存在: " + uploadedFile.exists() + "</p>");
        out.println("<p>檔案大小: " + uploadedFile.length() + " bytes</p>");
        
        // 列出 images 資料夾的所有檔案
        out.println("<h4>images 資料夾內容：</h4>");
        File[] files = saveDir.listFiles();
        if(files != null) {
            for(File f : files) {
                out.println("<p>- " + f.getName() + " (" + f.length() + " bytes)</p>");
            }
        }
        
    } catch(Exception e) {
        out.println("<p style='color:red;'>錯誤: " + e.getMessage() + "</p>");
        e.printStackTrace(new PrintWriter(out));
    }
} else {
%>
    <h2>測試檔案上傳</h2>
    <form method="post" enctype="multipart/form-data">
        <input type="file" name="testFile" accept="image/*" required>
        <button type="submit">上傳測試</button>
    </form>
<%
}
%>
</body>
</html>