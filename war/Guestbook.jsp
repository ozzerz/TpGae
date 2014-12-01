<%@ page import="com.google.appengine.api.blobstore.*"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page
	import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>


<%@ page import="com.google.appengine.api.blobstore.BlobInfo"%>
<%@ page import="com.google.appengine.api.blobstore.BlobInfoFactory"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="com.google.appengine.api.images.ImagesService"%>
<%@ page import="com.google.appengine.api.images.ImagesServiceFactory"%>
<%@ page import="com.google.appengine.api.images.ServingUrlOptions"%>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<html>
<head>
</head>

<body>

	<%--Gestion des utilisateurs --%>
	<%
		String guestbookName = request.getParameter("guestbookName");
		if (guestbookName == null) {
			guestbookName = "default";
		}
		pageContext.setAttribute("guestbookName", guestbookName);
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();//on récupére l'utilisateur
		if (user != null) {
			pageContext.setAttribute("user", user);
	%>

	<%--si un utilisateur est connecté on lui indique qu'il peut se déconnecter--%>
	<p>
		Hello,${fn:escapeXml(user.nickname)} (You can <a
			href="<%=userService.createLogoutURL(request.getRequestURI())%>">sign
			out</a>.)
	</p>
	<%
		} else {
	%>
	<%--sinon on lui propose de se déconnecter--%>
	<p>
		Hello! <a
			href="<%=userService.createLoginURL(request.getRequestURI())%>">Sign
			in</a> to include your name with greetings you post.
	</p>
	<%
		}
	%>

	<%--Gestion des données --%>

	<%
		BlobstoreService blobstoreService = BlobstoreServiceFactory
				.getBlobstoreService();//récupération du service de Blob
		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();//récupération du service de Data
		Query query = new Query("Greeting").addSort("date",
				Query.SortDirection.DESCENDING);
		List<Entity> greetings = datastore.prepare(query).asList(
				FetchOptions.Builder.withLimit(5));
		//si il n'y aucun message
		if (greetings.isEmpty()) {
	%>
	<%--On indique qu'il n'y a pas de message--%>
	<p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
	<%
		} else {
	%>
	<%--On affiche le contenue  de chaque message--%>
	<p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
	<%
		//pour chaque message on va l'afficher , et on va afficher son propriétaire
			for (Entity greeting : greetings) {
				pageContext.setAttribute("greeting_content",
						greeting.getProperty("content"));
				if (greeting.getProperty("user") == null) {
	%>
	<p>An anonymous person wrote:</p>


	<%
		} else {
					pageContext.setAttribute("greeting_user",
							greeting.getProperty("user"));
	%>
	<p>
		<b>${fn:escapeXml(greeting_user.nickname)}</b> wrote:
	</p>
	<%
		}
	%>
	<blockquote>${fn:escapeXml(greeting_content)}</blockquote>

	<%--Gestion des images --%>

	<%
		ImagesService imagesService = ImagesServiceFactory
						.getImagesService();//récupération du service d'image
				if (greeting.getProperty("blobKey") != null) {
					ServingUrlOptions servingUrlOptions = ServingUrlOptions.Builder
							.withBlobKey((BlobKey) greeting
									.getProperty("blobKey"));
					String imageUrl = imagesService
							.getServingUrl(servingUrlOptions) + "=s200";
					pageContext.setAttribute("image", imageUrl);
	%>
	<p>
		<img src="${fn:escapeXml(image)}" alt=""> <br>
		<%
			}
				}
			}
		%>


		<%--Formulaire --%>
		<label> Answer with picture </label>
	<form action="<%=blobstoreService.createUploadUrl("/upload")%>"
		method="post" enctype="multipart/form-data">
		<p>
			<label>File : <input type="file" name="uploadedFile" /></label>
		</p>
		<div>
			<textarea name="content" rows="3" cols="60"></textarea>
		</div>
		<input type="hidden" name="guestbookName"
			value="${fn:escapeXml(guestbookName)}" />
		<p>
			<input type="submit" />
		</p>
	</form>




	<%--Ce formulaire a pour but de montrer comment recupéré une valeur dans un JSP , voir TP --%>
	<form action="/Guestbook.jsp" method="get">
		<div>
			<input type="text" name="guestbookName"
				value="${fn:escapeXml(guestbookName)}" />
		</div>
		<div>
			<input type="submit" value="Ok" />
		</div>
	</form>

</body>
</html>