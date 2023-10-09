# Overview

There are various permutations to local development environments.  Here we show the various approaches that has been tested, but we will also recommend the gold path that will satisfy both development experience and Open Container Initiative ([OCI](https://opencontainers.org/)) standards.

Although Docker created the container movement, they offer a specific implementation of container solutions with commericial implications such as Docker Desktop and their own implementation of containers that are not deployed by default from public cloud providers.  OCI standards decouple container solutions from Docker the company and ensures we do not encounter any licensing conflicts.

Our goal is to develop in an environment exactly how we operate software in the public cloud, but also avoid vendor lockin to Docker, Inc.

## Development Workspace

Our golden path accounts for developers:

1. wanting to do local develpoment from their M1/Intel laptops (allows for offline development)
1. wanting to do remote development from Google Cloud Workstations using local IDE (supports local VSCode/IntelliJ/PyCharm with remote workstation access)
1. wanting to do remote development from Google Cloud Workstations (supports web based VSCode similar to Gitpod, Codespaces, etc)

We will support both development approaches eventhough managed workstations provide the best consistency and lowest friction to start day 1 development tasks. Priority support will be for our managed workstations and best level of effort applied to offline development.

NOTE: Production workloads are deployed on amd64 target.

### Offline Development (Laptops - amd64/arm64)

| Kubernetes Support | Easy to setup | Easy to use | Production Compliant with amd64 |
|:------------------:|:-------------:|:-----------:|:-------------------------------:|
| Colima | 👍 | 👍 | 👍 |
| Docker Desktop | 👍 | 👍 | 👍|
| Rancher Desktop | ☝️ | 👍 | ☝️ |
| Podman Desktop | ☝️ | ☝️ | ☝️ |
| Minikube | ☝️ | 👍 | ☝️ |

NOTE:
1. Colima simply works with no tinkering!
1. Although kubernetes will work with Docker Desktop, it is not production compliant!
1. Although kubernetes will work with Rancher Desktop, running amd64 images does not work without some hacking.
1. Although kubernetes will work with Podman Desktop, running container images only supports Kind.
1. Although kubernetes will work with Minikube, running amd64 images does not work without some hacking.

### Online Development (Cloud Workstations - amd64)

| Kubernetes Support | Easy to setup | Easy to use | Production Compliant with amd64 |
|:------------------:|:-------------:|:-----------:|:-------------------------------:|
| Minikube | 👍 | 👍 | 👍 |

NOTE:
1. No setup required!
