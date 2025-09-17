package org.springframework.boot.loader;

// Compatibility bridge for Spring Boot 3 relocation.
// Spring Boot 3 moved JarLauncher to org.springframework.boot.loader.launch.JarLauncher.
// Our generated MANIFEST.MF (from the rules_spring singlejar invocation) still points to
// the legacy Main-Class: org.springframework.boot.loader.JarLauncher
// causing runtime failures when the old FQN cannot be resolved. This shim preserves the
// older entrypoint while delegating to the relocated launcher.
//
// Once rules_spring is updated (or configured) to emit the new Main-Class, this shim can
// be removed and the manifest adjusted. It is intentionally minimal and has no additional
// dependencies beyond the relocated launcher.

public final class JarLauncher {
    private JarLauncher() {
        // Not instantiable
    }

    public static void main(String[] args) throws Exception {
        org.springframework.boot.loader.launch.JarLauncher.main(args);
    }
}
