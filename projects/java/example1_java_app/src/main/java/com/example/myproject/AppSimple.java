package com.example.myproject;

/**
 * Simplified version of the application without external dependencies.
 * This compares two numbers using built-in Java methods.
 */
public class AppSimple {

  public static int compare(int a, int b) {
    // Use Integer.compare instead of Guava's Ints.compare
    return Integer.compare(a, b);
  }

  public static void main(String... args) throws Exception {
    AppSimple app = new AppSimple();
    
    System.out.println("Comparing numbers using AppSimple:");
    System.out.println("compare(2, 1) = " + app.compare(2, 1)); // Should return 1
    System.out.println("compare(1, 2) = " + app.compare(1, 2)); // Should return -1
    System.out.println("compare(1, 1) = " + app.compare(1, 1)); // Should return 0
    
    System.out.println("Success: Application completed without external dependencies!");
  }
}