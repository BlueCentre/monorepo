package com.sample;

import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;

import org.springframework.boot.actuate.info.Info;
import org.springframework.boot.actuate.info.InfoContributor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

/**
 * Custom InfoContributor that post-processes the canonical Spring Boot build-info.properties
 * generated via Bazel stamping (META-INF/build-info.properties) to expose a structured object:
 * {
 *   "build": {
 *     "version": "...",
 *     "time": "...",
 *     "user": "...",
 *     "host": "...",
 *     "git": {
 *        "branch": "...",
 *        "commit": "...",
 *        "dirty": "clean|dirty"
 *     }
 *   }
 * }
 *
 * This provides a stable JSON shape independent of property key formatting and shields
 * downstream consumers from needing to parse flattened property names.
 */
@Component
public class BuildInfoContributor implements InfoContributor {

    @Override
    public void contribute(Info.Builder builder) {
        Properties props = new Properties();
        String[] candidates = new String[] {"META-INF/build-info.properties", "rs_springboot_app/META-INF/build-info.properties"};
        for (String c : candidates) {
            ClassPathResource r = new ClassPathResource(c);
            if (r.exists()) {
                try (InputStream in = r.getInputStream()) {
                    props.load(in);
                    break;
                } catch (IOException ignored) {
                    // try next
                }
            }
        }

        Map<String, Object> build = new LinkedHashMap<>();
        Map<String, Object> git = new LinkedHashMap<>();

        // Map canonical keys
        putIfPresent(props, build, "build.version", "version");
        putIfPresent(props, build, "build.time", "time");
        putIfPresent(props, build, "build.user", "user");
        putIfPresent(props, build, "build.host", "host");
        putIfPresent(props, git, "git.branch", "branch");
        putIfPresent(props, git, "git.commit.id.abbrev", "commit");
        putIfPresent(props, git, "git.dirty", "dirty");
        if (!git.isEmpty()) {
            build.put("git", git);
        }
        builder.withDetail("build", build);
    }

    private static void putIfPresent(Properties props, Map<String, Object> target, String key, String mappedKey) {
        Object v = props.get(key);
        if (v != null) {
            target.put(mappedKey, v);
        }
    }
}
