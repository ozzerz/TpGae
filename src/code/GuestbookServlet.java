package code;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GuestbookServlet extends HttpServlet {
	/**
	 * cette servlet sert d'exemple pour le tp
	 */
	private static final long serialVersionUID = 1L;

	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		UserService userService = UserServiceFactory.getUserService();
		User currentUser = userService.getCurrentUser();

		if (currentUser != null) {
			resp.setContentType("text/plain");
			resp.getWriter().println("Hello, " + currentUser.getNickname());
		} else {
			resp.sendRedirect(userService.createLoginURL(req.getRequestURI()));
		}

	}
}