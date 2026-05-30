package com.example;

import static spark.Spark.*;
import com.google.gson.Gson;

import java.sql.*;
import java.util.*;

public class App {
	private static Gson GSON = new Gson();


    public static final void main(String[] args) {
    	String bindAddress = requireEnv("APP_HOST");
    	
    	int appPort = Integer.parseInt(requireEnv("APP_PORT"));
    	
    	ipAddress(bindAddress);
    	port(appPort);

        get("/health/alive", (req, res) -> "OK");

        get("/health/ready", (req, res) -> {
        	try (Connection ignored = connect()) {
        		return "OK";
        	} catch (Exception e) {
        		res.status(500);
        		return "DB not ready";
        	}
        });

        get("/tasks", (req, res) -> {
            List<Task> tasks = new ArrayList<>();
        
            try (
                Connection conn = connect();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM tasks")
            ) {
        
                while (rs.next()) {
                    Task t = new Task();
                    t.id = rs.getInt("id");
                    t.title = rs.getString("title");
                    t.status = rs.getString("status");
                    t.created_at = rs.getString("created_at");
        
                    tasks.add(t);
                }
            }
        
            if (req.headers("Accept") != null &&
                req.headers("Accept").contains("text/html")) {
        
                res.type("text/html");
        
                StringBuilder html = new StringBuilder("<table border=1>");
        
                html.append("<tr><th>ID</th><th>Title</th><th>Status</th><th>Created</th></tr>");
        
                for (Task t : tasks) {
                    html.append("<tr>")
                        .append("<td>").append(t.id).append("</td>")
                        .append("<td>").append(t.title).append("</td>")
                        .append("<td>").append(t.status).append("</td>")
                        .append("<td>").append(t.created_at).append("</td>")
                        .append("</tr>");
                }
        
                html.append("</table>");
        
                return html.toString();
            }
        
            res.type("application/json");
        
            return GSON.toJson(tasks);
        });

        post("/tasks", (req, res) -> {
            String title = req.queryParams("title");
        
            try (
                Connection conn = connect();
                PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO tasks(title) VALUES (?)"
                )
            ) {
        
                stmt.setString(1, title);
                stmt.executeUpdate();
            }
        
            return "Created";
        });

        post("/tasks/:id/done", (req, res) -> {
            String id = req.params(":id");
        
            try (
                Connection conn = connect();
                PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE tasks SET status='done' WHERE id=?"
                )
            ) {
        
                stmt.setInt(1, Integer.parseInt(id));
                stmt.executeUpdate();
            }
        
            return "Updated";
        });

        get("/", (req, res) -> {
        	res.type("text/html");
        	return "<h1>MyWebApp</h1><p>Available endpoint:</p>"
	        	+ "<ul>"
	        	+ "<li>GET /tasks</li>"
	        	+ "<li>POST /tasks</li>"
	        	+ "<li>GET /tasks/{id}/done</li>"
	        	+ "</ul>";
        });
    }

    private static Connection connect() throws Exception {
    	String url = requireEnv("DB_URL");
        String user = requireEnv("DB_USER");
        String password = requireEnv("DB_PASSWORD");

        return DriverManager.getConnection(url, user, password);
    }

    private static String requireEnv(String name) {
        String value = System.getProperty(name);
        
        if (value == null || value.isBlank()) {
             value = System.getenv(name);
        }
    
         if (value == null || value.isBlank()) {
             throw new IllegalStateException(
             	"Environment variable " + name + " is required"
             );
         }

         return value;
    }
}
