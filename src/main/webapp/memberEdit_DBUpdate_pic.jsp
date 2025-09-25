<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="CZ.group.tool.upload.FolderConfig2" %>
<%@ page import="CZ.group.tool.database.DBConfig" %>
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />

<%
try {
    // 文件上传逻辑
    MultipartRequest theMultipartRequest = new MultipartRequest(
        request,
        objFolderConfig.FilePath(), // 上传文件存储路径
        10 * 1024 * 1024, // 最大上传文件大小 10MB
        "UTF-8"  // 指定字符编码
    );

    String fileName = theMultipartRequest.getFilesystemName("theFirstFile");
    String memberId = theMultipartRequest.getParameter("memberId");

    if (fileName != null) {
        // 确保文件已成功保存
        String fullPath = objFolderConfig.FilePath() + fileName;
        File uploadedFile = new File(fullPath);
        if (!uploadedFile.exists()) {
            throw new Exception("文件未成功保存！");
        }

        // 更新数据库图片字段
        String relativePath = objFolderConfig.WebsiteRelativeFilePath() + fileName;
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        Connection con = DriverManager.getConnection(
            "jdbc:ucanaccess://" + objDBConfig.FilePath() + ";"
        );
        String sql = "UPDATE personal_information SET pic = ? WHERE memberId = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, relativePath);
        pstmt.setString(2, memberId);  // 使用从 MultipartRequest 获取的 memberId
        pstmt.executeUpdate();
        
        

        // 关闭资源
        pstmt.close();
        con.close();
        

        // 跳转到更新后的会员页面
        response.sendRedirect("member.jsp?memberId=" + session.getAttribute("accessId") );
    } else {
        out.println("文件上传失败，请重新选择文件！");
    }
} catch (Exception e) {
    e.printStackTrace();
    out.println("发生错误：" + e.getMessage());
}
%>
