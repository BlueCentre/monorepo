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

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class HealthMetricsIntegrationTest {

    @Value("${local.server.port}")
    private int port;

    private final TestRestTemplate rest = new TestRestTemplate();

    @Test
    public void health_and_custom_metric_available() throws Exception {
        // Hit actuator health (group readiness may not be exposed in include list, so base health)
        URI health = new URI("http://localhost:" + port + "/actuator/health");
        ResponseEntity<Map> healthResp = rest.getForEntity(health, Map.class);
        assertThat(healthResp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(healthResp.getBody()).isNotNull();
        assertThat(healthResp.getBody().get("status")).isEqualTo("UP");

        // Poll metrics endpoint for our custom counter (ensure metrics exposure is enabled)
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
}
