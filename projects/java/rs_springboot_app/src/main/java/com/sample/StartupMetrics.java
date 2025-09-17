package com.sample;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import jakarta.annotation.PostConstruct;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/**
 * Registers and updates a simple custom counter metric to demonstrate
 * Micrometer instrumentation within the Bazel-built Spring Boot app.
 *
 * Metric name: app.startup.invocations
 * Tags: { "app" : "rs-springboot-app" }
 */
@Component
public class StartupMetrics {

    private final MeterRegistry registry;
    private Counter startupCounter;

    public StartupMetrics(MeterRegistry registry) {
        this.registry = registry;
    }

    @PostConstruct
    void init() {
        this.startupCounter = Counter.builder("app.startup.invocations")
            .description("Counts how many times the application reports readiness")
            .tag("app", "rs-springboot-app")
            .register(registry);
    System.out.println("StartupMetrics initialized; counter registered.");
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        if (startupCounter != null) {
            startupCounter.increment();
            System.out.println("Incremented app.startup.invocations to " + startupCounter.count());
        }
    }
}
