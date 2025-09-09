package com.sample;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping(path = "/healthz", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> health() {
        Map<String, Object> m = new HashMap<>();
        m.put("status", "ok");
        m.put("timestamp", Instant.now().toString());
        return m;
    }

    @GetMapping(path = "/readyz", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> ready() {
        // Future: add dependency checks (DB, cache, etc.)
        Map<String, Object> m = new HashMap<>();
        m.put("ready", true);
        return m;
    }
}
