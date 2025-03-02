# Upgrading to Bazel 8.x

This document provides instructions for upgrading the project from Bazel 6.x/7.x to Bazel 8.x.

## Installation

### macOS

Using Homebrew:
```bash
brew install bazel
# or if you already have it installed
brew upgrade bazel
```

To verify the installation:
```bash
bazel --version
# Should show something like: bazel 8.0.1
```

### Linux

Using Bazelisk (recommended):
```bash
npm install -g @bazel/bazelisk
```

Or direct installation:
```bash
# Get the latest version from https://github.com/bazelbuild/bazel/releases
wget https://github.com/bazelbuild/bazel/releases/download/8.0.1/bazel-8.0.1-installer-linux-x86_64.sh
chmod +x bazel-8.0.1-installer-linux-x86_64.sh
./bazel-8.0.1-installer-linux-x86_64.sh --user
```

## Configuration Changes

The following changes were made to support Bazel 8.x:

1. Updated `.bazelrc` with:
   - `--nolegacy_external_runfiles` flag to disable the legacy external runfiles system
   - `--enable_bzlmod` flag (now the default in Bazel 8.x)
   - Added compatibility flags including:
     - `--incompatible_default_to_explicit_init_py`
     - `--incompatible_config_setting_private_default_visibility`
     - `--incompatible_strict_action_env`
   - Set Java toolchain version to Java 17
   - Added fallback mechanisms for Bazel 8.x and 7.x configuration presets

2. Updated `.bazelversion` to use 8.0.1

3. Updated `MODULE.bazel` with:
   - Explicitly declared the module name with `module(name = "monorepo")`
   - Updated all dependency versions to their latest compatible versions for Bazel 8.x
   - Enabled Java toolchain configuration with rules_java 7.3.2
   - Added proper repository visibility configurations

4. Updated `WORKSPACE` file with:
   - Added migration notice comments and references to the upgrade guide
   - Updated dependency versions to be compatible with Bazel 8.x:
     - Updated rules_cc to 0.0.8
     - Updated rules_jvm_external to 6.0

5. Updated `third_party/python/BUILD.bazel` with:
   - Switched to the newer pip integration mechanism
   - Added a `compile_pip_requirements` rule using rules_python 0.28.0
   - Added a compatibility layer for multi-version Python support
   - Added a simple test to verify Python requirements can be loaded

6. Added `third_party/java/BUILD.bazel` with:
   - Export statements for the Maven lock files
   - Helper rules to update the Maven dependency pins

7. Added `tools/update_aspect_bazelrc.sh` to download and setup Aspect Bazelrc presets

## Known Issues and Workarounds

1. CC toolchain for cross-compilation:
   The `aarch64_linux` platform still needs proper toolchain registration. If you need
   to build for ARM64 Linux, you'll need to configure the appropriate toolchains.

2. Some warnings about deprecated function definitions might appear during the build process.
   These are coming from dependencies (like zlib and protobuf) and can be ignored as they don't
   affect functionality.

3. If you encounter errors with the Aspect Bazelrc presets, you can update them using:
   ```bash
   ./tools/update_aspect_bazelrc.sh
   ```

4. You may see libtool warnings about duplicate member names from protobuf. These are
   harmless warnings that can be ignored.

## Migration to Bzlmod

Bazel 8.x strongly encourages using Bzlmod (MODULE.bazel) instead of WORKSPACE.
This project is currently in a hybrid state, with some dependencies managed through
MODULE.bazel and others through WORKSPACE.

The long-term goal should be to fully migrate to Bzlmod:
1. Move remaining WORKSPACE dependencies to MODULE.bazel
2. Remove the WORKSPACE file entirely
3. Use Bzlmod extensions for dependency management

To update Maven dependency locks, you can use the following commands:
```bash
# Update Maven POJO dependencies
bazel run //third_party/java:update_maven_pojo

# Update Maven Spring Boot dependencies
bazel run //third_party/java:update_maven_springboot

# Update Maven Spring Boot v2 dependencies
bazel run //third_party/java:update_maven_springboot_v2
```

## Additional Resources

- [Bazel 8.0 Release Notes](https://github.com/bazelbuild/bazel/releases/tag/8.0.0)
- [Bzlmod Documentation](https://bazel.build/external/overview)
- [Migrating from WORKSPACE to Bzlmod](https://bazel.build/external/migration)
- [Rules JVM External Migration Guide](https://github.com/bazelbuild/rules_jvm_external/blob/master/docs/bzlmod.md)
- [Rules Python Bzlmod Examples](https://github.com/bazelbuild/rules_python/tree/main/examples/bzlmod) 