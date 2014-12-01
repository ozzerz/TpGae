package code;

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobInfo;
import com.google.appengine.api.blobstore.BlobInfoFactory;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class UploadServlet extends HttpServlet {
	/**
	 * Permet de gerer l'ajout de nouveau message dans le dataStore et dans le
	 * BlobStore
	 */
	private static final long serialVersionUID = 1L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	@Override
	public void doPost(HttpServletRequest req, HttpServletResponse res)
			throws ServletException, IOException {

		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("uploadedFile");
		BlobInfo blobInfo = new BlobInfoFactory().loadBlobInfo(blobKey);

		if (blobKey == null) {
			res.sendRedirect("/erreur");// si il n'y a pas de Blob on redirige
										// vers une erreur ; ce cas ne devrait
										// en principe JAMAIS se présenter
		} else {

			// Préparation des services
			UserService userService = UserServiceFactory.getUserService();
			DatastoreService datastore = DatastoreServiceFactory
					.getDatastoreService();
			// récupération des données qui nous intéresse
			User user = userService.getCurrentUser();
			String filename = blobInfo.getFilename();
			String extension = filename
					.substring(filename.lastIndexOf(".") + 1);
			String guestbookName = req.getParameter("guestbookName");
			String content = req.getParameter("content");
			Date date = new Date();

			// creation de l'entité pour le DataStore
			Entity greeting = new Entity("Greeting");
			greeting.setProperty("user", user);
			greeting.setProperty("date", date);
			greeting.setProperty("content", content);

			// si le fichier n'est pas un png
			if (!extension.equals("png")) {
				blobstoreService.delete(blobKey);// on supprime le blob
				greeting.setProperty("blobKey", null);
				datastore.put(greeting);// on ajoute dans le dataStore notre
										// entité
				res.sendRedirect("/");// on redirige

			} else {
				// sinon on ajoute en propriété la clef de l'image

				greeting.setProperty("blobKey", blobKey);
				datastore.put(greeting);// on ajout dans le dataStore

				res.sendRedirect("/");
			}
		}

	}
}
