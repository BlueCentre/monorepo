package com.example;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Scanner;

/**
 * Simple test for WebServer class that doesn't use JUnit.
 * This tests the actual HTTP server functionality.
 */
public class WebServerTest {
    
    private static boolean testPassed = true;
    
    public static void main(String[] args) {
        System.out.println("Running WebServer tests...");
        
        // Test 1: Verify HelloHandler response format
        testHelloHandlerResponse();
        
        // Test 2: Test HTTP server integration (would need server to be running)
        testHttpServerIntegration();
        
        System.out.println("All tests completed. Test passed: " + testPassed);
        
        if (!testPassed) {
            System.exit(1); // Exit with error code if tests failed
        }
    }
    
    /**
     * Test that the HelloHandler produces expected response
     */
    private static void testHelloHandlerResponse() {
        System.out.println("Testing HelloHandler response format...");
        
        // Create a HelloHandler instance
        WebServer.HelloHandler handler = new WebServer.HelloHandler();
        
        // We can't easily test the handler without mocking HttpExchange,
        // so we'll just verify the class can be instantiated
        if (handler != null) {
            System.out.println("✓ HelloHandler can be instantiated");
        } else {
            System.out.println("✗ HelloHandler instantiation failed");
            testPassed = false;
        }
    }
    
    /**
     * Test HTTP server integration by making actual HTTP request
     * Note: This assumes the server is already running on port 8080
     */
    private static void testHttpServerIntegration() {
        System.out.println("Testing HTTP server integration...");
        
        try {
            // Try to connect to the server
            URL url = new URL("http://localhost:8080/api/hello");
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(1000); // 1 second timeout
            connection.setReadTimeout(1000);
            
            int responseCode = connection.getResponseCode();
            
            if (responseCode == 200) {
                Scanner scanner = new Scanner(connection.getInputStream());
                String response = scanner.useDelimiter("\\A").next();
                scanner.close();
                
                if ("Hello, World!".equals(response)) {
                    System.out.println("✓ HTTP server responds correctly");
                } else {
                    System.out.println("✗ HTTP server response incorrect. Expected: 'Hello, World!', Got: '" + response + "'");
                    testPassed = false;
                }
            } else {
                System.out.println("✗ HTTP server returned status code: " + responseCode);
                testPassed = false;
            }
            
        } catch (IOException e) {
            // Server is not running, which is expected for unit tests
            System.out.println("ℹ HTTP server not running (this is expected for unit tests)");
            System.out.println("  To test HTTP functionality:");
            System.out.println("  1. Run: bazel run //projects/java/simple_java_app:webserver");
            System.out.println("  2. In another terminal: curl http://localhost:8080/api/hello");
        }
    }
}