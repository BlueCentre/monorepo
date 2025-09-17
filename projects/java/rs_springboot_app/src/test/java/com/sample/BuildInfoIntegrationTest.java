package com.sample;

import static org.assertj.core.api.Assertions.assertThat;

import java.net.URI;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class BuildInfoIntegrationTest {

    @org.springframework.beans.factory.annotation.Value("${local.server.port}")
    int port;

    TestRestTemplate rest = new TestRestTemplate();

    @Test
    public void actuatorInfoContainsStructuredBuildInfo() throws Exception {
        URI info = new URI("http://localhost:" + port + "/actuator/info");
        ResponseEntity<Map> resp = rest.getForEntity(info, Map.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).isNotNull();
        Map body = resp.getBody();
        assertThat(body.containsKey("build")).isTrue();
        Map build = (Map) body.get("build");
        // Expect canonical keys added by BuildInfoContributor
        assertThat(build).containsKeys("version", "time");
        if (build.containsKey("git")) {
            Map git = (Map) build.get("git");
            assertThat(git).containsKey("commit");
        }
    }
}
