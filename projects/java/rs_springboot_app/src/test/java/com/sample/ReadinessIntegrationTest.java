package com.sample;

import static org.assertj.core.api.Assertions.assertThat;

import java.net.URI;
import java.time.Duration;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

/**
 * Hermetic readiness integration test replacing the shell-based readyz functional test.
 * Starts the full embedded web server on a random port, then probes both the custom
 * /readyz controller endpoint and (if exposed) the actuator readiness group endpoint.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ReadinessIntegrationTest {

    @Value("${local.server.port}")
    private int port;

    private final TestRestTemplate rest = new TestRestTemplate();

    @Test
    public void readinessEndpointsReachable() throws Exception {
        URI customReady = new URI("http://localhost:" + port + "/readyz");
        boolean customOk = pollFor(customReady, 10);
        assertThat(customOk).as("/readyz should become available").isTrue();

        // Optional: actuator readiness group (may not be present depending on exposure config)
        URI actuatorReady = new URI("http://localhost:" + port + "/actuator/health/readiness");
        pollFor(actuatorReady, 5); // best-effort, ignore result
    }

    private boolean pollFor(URI uri, int seconds) throws InterruptedException {
        long deadline = System.currentTimeMillis() + Duration.ofSeconds(seconds).toMillis();
        while (System.currentTimeMillis() < deadline) {
            try {
                ResponseEntity<Map> resp = rest.getForEntity(uri, Map.class);
                if (resp.getStatusCode().is2xxSuccessful()) {
                    return true;
                }
            } catch (Exception ignored) {
            }
            Thread.sleep(250);
        }
        return false;
    }
}
