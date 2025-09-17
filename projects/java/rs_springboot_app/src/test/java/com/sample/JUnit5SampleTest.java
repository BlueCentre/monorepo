package com.sample;

import org.junit.platform.runner.JUnitPlatform;
import org.junit.runner.RunWith;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * Demonstration placeholder for future native JUnit 5 integration under Bazel.
 * Currently tagged "manual" in BUILD to exclude from //... until a dedicated
 * JUnit Platform runner or console-launcher wrapper strategy is adopted.
 *
 * Why it fails today:
 *  - Bazel's legacy JUnit4 runner + junit-platform-runner 1.10.x combination
 *    does not fully expose the OutputDirectoryProvider needed by the Jupiter engine.
 *  - A stable solution typically involves either a custom test rule or using the
 *    console launcher in a sh_test.
 */

/**
 * Sample JUnit5 test executed via the JUnit Platform runner so Bazel's JUnit4
 * infrastructure can run it. Demonstrates mixed JUnit4 & JUnit5 support.
 */
@RunWith(JUnitPlatform.class)
public class JUnit5SampleTest {
    @Test
    void simpleAssertion() {
        assertThat(2 + 2).isEqualTo(4);
    }
}
