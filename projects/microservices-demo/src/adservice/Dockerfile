# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=$BUILDPLATFORM eclipse-temurin:17-jdk AS builder

WORKDIR /app

# Install Maven
ENV MAVEN_VERSION=3.9.6
ENV MAVEN_HOME=/usr/share/maven
ENV MAVEN_CONFIG=/root/.m2
ENV PATH="${MAVEN_HOME}/bin:${PATH}"
# Set conservative Maven/JVM options
ENV MAVEN_OPTS="-Xmx512m -XX:+UseSerialGC"

RUN apt-get update && apt-get install -y curl \
    && mkdir -p /usr/share/maven /usr/share/maven/ref \
    && curl -fsSL -o /tmp/apache-maven.tar.gz https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy pom.xml first for dependency resolution (better layer caching)
COPY pom.xml ./
RUN mvn -B dependency:go-offline

# Copy the rest of the source code
COPY src ./src

# Build the application
RUN mvn -B package

FROM eclipse-temurin:17-jre-alpine

# @TODO: https://github.com/GoogleCloudPlatform/microservices-demo/issues/2517
# Download Stackdriver Profiler Java agent
# RUN mkdir -p /opt/cprof && \
#     wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent_alpine.tar.gz \
#     | tar xzv -C /opt/cprof && \
#     rm -rf profiler_java_agent.tar.gz

WORKDIR /app
COPY --from=builder /app/target/appassembler ./

EXPOSE 9555
ENTRYPOINT ["/app/bin/AdService"]
