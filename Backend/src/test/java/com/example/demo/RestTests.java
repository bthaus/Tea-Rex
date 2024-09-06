package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class RestTests {

    @Autowired
    private TestRestTemplate restTemplate;  // For making HTTP requests

    @Test
    public void testHelloWorld() {
        // Make an HTTP GET request to the running server
        ResponseEntity<String> response = restTemplate.getForEntity("/hello", String.class);

        // Assert the response status and content
        assertThat(response.getStatusCodeValue()).isEqualTo(200);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody()).isEqualTo("hi");
    }
    @Test
    public void testGetUserByID() {
        // Make an HTTP GET request to the running server
        // Create the request body
        String requestBody = "1";

        // Set the headers
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Wrap the body and headers in an HttpEntity
        HttpEntity<String> request = new HttpEntity<>(requestBody, headers);

        // Send a POST request to the server
        ResponseEntity<String> response = restTemplate.postForEntity("/get_user_by_id", request, String.class);

        // Assert the response status and content
        assertThat(response.getStatusCodeValue()).isEqualTo(200);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody()).isEqualTo("John Doe");
    }
}
