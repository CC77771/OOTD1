<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="CZ.group.tool.upload.FolderConfig2" %>
<%@ page import="CZ.group.tool.database.DBConfig" %>
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />

<%
try {
    MultipartRequest theMultipartRequest = new MultipartRequest(
        request,
        objFolderConfig.FilePath(), 
        10 * 1024 * 1024, 
        "UTF-8"  
    );

    String fileName = theMultipartRequest.getFilesystemName("pic");
    String wearId = theMultipartRequest.getParameter("wearId");
    String memberId = theMultipartRequest.getParameter("memberId");

    if (fileName != null) {
        String fullPath = objFolderConfig.FilePath() + fileName;
        File uploadedFile = new File(fullPath);
        if (!uploadedFile.exists()) {
            throw new Exception("文件未成功保存！");
        }

        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection(
            "jdbc:ucanaccess://" + objDBConfig.FilePath() + ";"
        );

        String relativePath = objFolderConfig.WebsiteRelativeFilePath() + fileName;

        String sql = "INSERT INTO personal_wear (memberId, pic, wearId) VALUES (?, ?, ?)";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, memberId);
        pstmt.setString(2, relativePath);
        pstmt.setString(3, wearId);

        pstmt.executeUpdate();
        pstmt.close();
        con.close();

        // 这里重定向到 index1.jsp，携带 newPost=true 参数
      //  response.setHeader("Content-Type", "image/jpeg");
        response.sendRedirect("index1.jsp?NewPost=true&accessId=" + session.getAttribute("accessId") + "#postArea");
    

    } else {
        out.println("文件上传失败，请重新选择文件！");
    }
} catch (Exception e) {
    e.printStackTrace();
    out.println("发生错误：" + e.getMessage());
}
%>
