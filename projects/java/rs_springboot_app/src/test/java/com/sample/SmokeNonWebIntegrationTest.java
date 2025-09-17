package com.sample;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.test.context.junit4.SpringRunner;

/**
 * Hermetic replacement for the prior shell smoke test. Starts the application
 * with WebApplicationType.NONE (no embedded server) and asserts the context loads
 * and the SampleMain bean (primary configuration) is present.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = SampleMain.class, webEnvironment = SpringBootTest.WebEnvironment.NONE)
public class SmokeNonWebIntegrationTest {

    @Test
    public void contextStartsInNonWebMode() {
        SpringApplication app = new SpringApplication(SampleMain.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        try (ConfigurableApplicationContext ctx = app.run()) {
            assertThat(ctx.isActive()).isTrue();
            assertThat(ctx.getBean(SampleMain.class)).isNotNull();
        }
    }
}
