package com.sample;

import jakarta.annotation.PostConstruct;

/**
 * Simplified auto configuration. Original SignalUtils-based signal handling removed because
 * spring-boot-loader-tools isn't currently exposed via the resolved maven repos in this workspace.
 * TODO: Reintroduce if the artifact becomes available (org.springframework.boot:spring-boot-loader-tools).
 */
public class SampleAutoConfiguration {

    @PostConstruct
    public void init() {
        // no-op initialization hook
    }
}
