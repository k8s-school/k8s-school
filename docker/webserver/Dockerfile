# A Dockerfile is a simple text-file that contains a list of commands
# that the Docker client calls while creating an image.
# It's a simple way to automate the image creation process.
# The best part is that the commands you write in a Dockerfile are almost
# identical to their equivalent Linux commands. This means you don't really
# have to learn new syntax to create your own dockerfiles.

# Use ubuntu as base image, it will be downloaded automatically
FROM ubuntu:latest
MAINTAINER Jacques Celere "jacques.celere@gmail.com"

# Update and install python-3
RUN xxxx 

# Create /home/www
RUN xxxx

# Set /home/www as WORKDIR
WORKDIR xxxx

# Copy index.html inside container, in /home/www
# NOTE: code could also be retrieved from git repository
ADD xxxx

# Copy hello.py inside container, in /home/src
# NOTE: putting this command to the last line 
# would allow to rebuild only this layer if if hello.py is changed
ADD xxxx

# Launch /home/src/hello.py at container startup 
# It will serve files located where it has been launch
CMD xxxx 

