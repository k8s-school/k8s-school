# Use ubuntu as base image, it will be downloaded automatically
FROM ubuntu:latest
LABEL org.opencontainers.image.authors="fabrice.jammes@gmail.com"

# Update and install system dependencies
RUN apt-get update && apt-get install -y python3
RUN mkdir -p /home/www
WORKDIR /home/www
# Commands below will all be launched in WORKDIR

# Launch command below at container startup
# It will serve files located where it has been launch
# so /home/www
CMD ["python3", "/home/src/hello.py"]

# Add local file inside container
# code can also be retrieved from git repository
COPY index.html /home/www/index.html

# This command is the last one so, if hello.py is changed
# only this container layer will be changed.
COPY hello.py /home/src/hello.py
