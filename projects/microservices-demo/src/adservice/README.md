# Ad Service

The Ad service provides advertisement based on context keys. If no context keys are provided then it returns random ads.

## Building locally

The Ad service uses Maven to compile/install/distribute. Maven wrapper is already part of the source code. To build Ad Service, run:

```
./mvnw package
```

It will create an executable app in `target/appassembler/bin/AdService`

### Upgrading Maven version

If you need to upgrade the version of Maven, edit the version number in the wrapper scripts:
- `mvnw` - Update the `MAVEN_VERSION` variable
- `mvnw.cmd` - Update the `MAVEN_VERSION` variable

## Building docker image

From `src/adservice/`, run:

```
docker build ./
```

