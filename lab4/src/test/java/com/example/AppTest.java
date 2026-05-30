package com.example;

import io.restassured.RestAssured;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import spark.Spark;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

import static io.restassured.RestAssured.*;
import static org.hamcrest.Matchers.*;

public class AppTest {

    @BeforeAll
    static void setup() throws Exception {

        System.setProperty("APP_HOST", "0.0.0.0");
        System.setProperty("APP_PORT", "3000");

        System.setProperty(
            "DB_URL",
            "jdbc:h2:mem:testdb;MODE=MySQL;DB_CLOSE_DELAY=-1"
        );

        System.setProperty("DB_USER", "sa");
        System.setProperty("DB_PASSWORD", "test");

        createSchema();

        App.main(new String[]{});

        Spark.awaitInitialization();

        RestAssured.baseURI = "http://127.0.0.1";
        RestAssured.port = 3000;
    }

    @BeforeEach
    void cleanupDatabase() throws Exception {
    
        try (
            Connection conn = DriverManager.getConnection(
                "jdbc:h2:mem:testdb;MODE=MySQL;DB_CLOSE_DELAY=-1",
                "sa",
                "test"
            );
    
            Statement stmt = conn.createStatement()
        ) {
    
            stmt.execute("DELETE FROM tasks");
            stmt.execute("ALTER TABLE tasks ALTER COLUMN id RESTART WITH 1");
        }
    }

    @AfterAll
    static void teardown() {
        Spark.stop();
        Spark.awaitStop();
    }

    static void createSchema() throws Exception {
        try (
            Connection conn = DriverManager.getConnection(
                "jdbc:h2:mem:testdb;MODE=MySQL;DB_CLOSE_DELAY=-1",
                "sa",
                "test"
            );

            Statement stmt = conn.createStatement()
        ) {

            stmt.execute("""
                CREATE TABLE tasks (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    title VARCHAR(255) NOT NULL,
                    status VARCHAR(50) NOT NULL DEFAULT 'pending',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """);
        }
    }

    @Test
    void aliveEndpointShouldReturnOk() {
        given()
        .when()
            .get("/health/alive")
        .then()
            .statusCode(200)
            .body(equalTo("OK"));
    }

    @Test
    void readyEndpointShouldReturnOk() {
        given()
        .when()
            .get("/health/ready")
        .then()
            .statusCode(200)
            .body(equalTo("OK"));
    }

    @Test
    void shouldCreateTask() {
        given()
            .queryParam("title", "test task")
        .when()
            .post("/tasks")
        .then()
            .statusCode(200)
            .body(equalTo("Created"));
    }

    @Test
    void shouldReturnTasksJson() {
        given()
        .when()
            .get("/tasks")
        .then()
            .statusCode(200)
            .contentType(containsString("application/json"));
    }

    @Test
    void shouldReturnTasksHtml() {
        given()
            .header("Accept", "text/html")
        .when()
            .get("/tasks")
        .then()
            .statusCode(200)
            .contentType(containsString("text/html"))
            .body(containsString("<table"));
    }

    @Test
    void shouldMarkTaskDone() {

        given()
            .queryParam("title", "done task")
        .when()
            .post("/tasks")
        .then()
            .statusCode(200);

        given()
        .when()
            .post("/tasks/1/done")
        .then()
            .statusCode(200)
            .body(equalTo("Updated"));
    }

    @Test
    void rootEndpointShouldReturnHtml() {
        given()
        .when()
            .get("/")
        .then()
            .statusCode(200)
            .contentType(containsString("text/html"))
            .body(containsString("MyWebApp"));
    }
}
