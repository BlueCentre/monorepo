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
 * Consolidated integration test covering:
 *  - /actuator/health (base health)
 *  - /actuator/health/readiness (probe-enabled readiness)
 *  - custom /readyz controller endpoint
 *  - custom metric app.startup.invocations
 * Combines prior HealthMetricsIntegrationTest + ReadinessIntegrationTest to reduce
 * startup overhead while retaining coverage.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class HealthReadinessMetricsIntegrationTest {

    @Value("${local.server.port}")
    private int port;

    private final TestRestTemplate rest = new TestRestTemplate();

    @Test
    public void health_readiness_custom_endpoint_and_metric() throws Exception {
        assertHealth();
        assertReadiness();
        assertCustomReadyEndpoint();
        assertCustomMetric();
    }

    private void assertHealth() throws Exception {
        URI health = new URI("http://localhost:" + port + "/actuator/health");
        ResponseEntity<Map> healthResp = rest.getForEntity(health, Map.class);
        assertThat(healthResp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(healthResp.getBody()).isNotNull();
        assertThat(healthResp.getBody().get("status")).isEqualTo("UP");
    }

    private void assertReadiness() throws Exception {
        // Readiness probes enabled via application.properties; poll briefly
        URI readiness = new URI("http://localhost:" + port + "/actuator/health/readiness");
        pollFor2xx(readiness, 10);
    }

    private void assertCustomReadyEndpoint() throws Exception {
        URI customReady = new URI("http://localhost:" + port + "/readyz");
        pollFor2xx(customReady, 10);
    }

    private void assertCustomMetric() throws Exception {
        URI metric = new URI("http://localhost:" + port + "/actuator/metrics/app.startup.invocations");
        boolean seen = false;
        long deadline = System.currentTimeMillis() + Duration.ofSeconds(10).toMillis();
        while (System.currentTimeMillis() < deadline) {
            ResponseEntity<Map> metricResp = rest.getForEntity(metric, Map.class);
            if (metricResp.getStatusCode().is2xxSuccessful() && metricResp.getBody() != null) {
                Object measurements = metricResp.getBody().get("measurements");
                if (measurements != null && measurements.toString().contains("value")) {
                    seen = true;
                    break;
                }
            }
            Thread.sleep(250);
        }
        assertThat(seen).as("custom metric app.startup.invocations should be exposed").isTrue();
    }

    private void pollFor2xx(URI uri, int seconds) throws Exception {
        long deadline = System.currentTimeMillis() + Duration.ofSeconds(seconds).toMillis();
        while (System.currentTimeMillis() < deadline) {
            try {
                ResponseEntity<Map> resp = rest.getForEntity(uri, Map.class);
                if (resp.getStatusCode().is2xxSuccessful()) {
                    return;
                }
            } catch (Exception ignored) {}
            Thread.sleep(250);
        }
        throw new AssertionError("Endpoint did not return 2xx in time: " + uri);
    }
}