package com.example.myproject;

/**
 * Simple tests for AppSimple class that doesn't use JUnit.
 */
public class TestAppSimple {

  private static boolean testPassed = true;

  public static void main(String[] args) {
    System.out.println("Running tests for AppSimple...");
    
    AppSimple app = new AppSimple();
    
    // Test 1: Equal numbers should return 0
    testEqualNumbers(app);
    
    // Test 2: First number greater should return positive
    testFirstNumberGreater(app);
    
    // Test 3: First number smaller should return negative
    testFirstNumberSmaller(app);
    
    System.out.println("All tests completed. Test passed: " + testPassed);
    
    if (!testPassed) {
      System.exit(1); // Exit with error code if tests failed
    }
  }
  
  private static void testEqualNumbers(AppSimple app) {
    System.out.println("Testing equal numbers...");
    int result = app.compare(1, 1);
    if (result == 0) {
      System.out.println("✓ Equal numbers test passed");
    } else {
      System.out.println("✗ Equal numbers test failed. Expected: 0, Got: " + result);
      testPassed = false;
    }
  }
  
  private static void testFirstNumberGreater(AppSimple app) {
    System.out.println("Testing first number greater...");
    int result = app.compare(2, 1);
    if (result > 0) {
      System.out.println("✓ First number greater test passed");
    } else {
      System.out.println("✗ First number greater test failed. Expected: >0, Got: " + result);
      testPassed = false;
    }
  }
  
  private static void testFirstNumberSmaller(AppSimple app) {
    System.out.println("Testing first number smaller...");
    int result = app.compare(1, 2);
    if (result < 0) {
      System.out.println("✓ First number smaller test passed");
    } else {
      System.out.println("✗ First number smaller test failed. Expected: <0, Got: " + result);
      testPassed = false;
    }
  }
}