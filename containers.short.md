# Linux Container Internals

## Introduction

- Linux containers are a lightweight form of virtualization.
- Containers provide isolation for applications while sharing the host OS kernel.
- They are composed of layered file systems, namespaces, and cgroups.

---

## Key Concepts

### Namespaces

- Namespaces provide process and resource isolation.
- Types of namespaces include:
  - PID (Process ID)
  - Network
  - Mount
  - UTS (Hostname)
  - IPC (Inter-Process Communication)
  - User

---

## Key Concepts (contd.)

### Control Groups (cgroups)

- Cgroups manage resource allocation and usage.
- They control CPU, memory, disk I/O, network, and more.
- Allows limiting, prioritizing, and isolating resources for containers.

---

## File System Layers

- Containers use layered file systems.
- Each layer represents changes to the filesystem.
- Lower layers are shared among containers for efficiency.

---

## Container Image Structure

- Images are a blueprint for containers.
- Composed of multiple read-only layers.
- Top writable layer stores changes made by the container.

---

## Building an Image

1. Create a base layer with the minimal OS.
2. Add subsequent layers with application-specific files.
3. Each layer builds on the previous one.

---

## Running Containers

- When a container starts, a new namespace is created.
- The container's process runs in this isolated namespace.
- The cgroups allocate and control resources for the container.

---

## Dockerfile

- Docker uses Dockerfiles to define images.
- Dockerfile contains instructions to build an image.
- Includes base image, packages, environment setup, and more.

---

## Example Dockerfile

\```Dockerfile
# Use a base image
FROM ubuntu:20.04

# Install packages
RUN apt-get update && apt-get install -y nginx

# Expose a port
EXPOSE 80

# Command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
\```

## Container on host filesystem

TODO

https://blog.px.dev/container-filesystems/

---

## Conclusion

- Linux containers leverage namespaces, cgroups, and layered file systems.
- They provide process isolation, resource control, and filesystem efficiency.
- Dockerfiles simplify image creation and deployment.

---

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Understanding Docker Containers](https://www.redhat.com/sysadmin/understanding-docker-container)
- [Introduction to Control Groups (Cgroups)](https://www.redhat.com/sysadmin/cgroups-part-one)
- [A Deep Dive into Linux Namespaces](https://www.redhat.com/sysadmin/linux-namespaces)
