FROM --platform=$TARGETPLATFORM debian:bullseye-slim

# User, home (app) and data folders
ARG USER=jens
ARG DATA=/data
ENV HOME /usr/src/$USER
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-armhf

# Match the guid as on host
ARG DOCKER_GROUP_ID=995
ARG DOCKER_GROUP_NAME=docker

ENV JENKINS_HOME $DATA
ENV JENKINS_WEB_PORT 8080
ENV JENKINS_SLAVE_PORT 50000

RUN lsof /var/lib/dpkg/lock-frontend

# Extra runtime packages
RUN apt-get update && \
    apt-get install -y -qq --no-install-recommends \
      openjdk-11-jre-headless \
      git ssh wget time procps curl qemu-user-static
# Install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    chmod +x /get-docker.sh && \
    sh get-docker.sh
RUN docker buildx create --use --name multiarch
RUN docker buildx inspect --bootstrap

# Prepare data and app folder
RUN rm -rf /var/lib/apt/lists/* &&\
    mkdir -p $DATA && \
    mkdir -p $HOME && \
# Add $USER user so we aren't running as root
    adduser --home $DATA --no-create-home -gecos '' --disabled-password $USER && \
    chown -R $USER:$USER $HOME && \
    chown -R $USER:$USER $DATA && \
# Add $USER to docker group, same guid as pi on host
#    groupadd -g $DOCKER_GROUP_ID $DOCKER_GROUP_NAME && \
#    groupmod -n $DOCKER_GROUP_NAME root && \
    usermod -aG $DOCKER_GROUP_NAME $USER

RUN wget https://updates.jenkins-ci.org/download/war/latest/jenkins.war \
    && mv jenkins.war $HOME

RUN wget https://raw.githubusercontent.com/jb-home/rpi-jenkins/main/entrypoint.sh
RUN chmod +x /entrypoint.sh

# Jenkins web interface, connected slave agents
EXPOSE $JENKINS_WEB_PORT $JENKINS_SLAVE_PORT

# VOLUME $DATA
WORKDIR $DATA

USER $USER

# exec java -jar $HOME/jenkins.war --prefix=$PREFIX
ENTRYPOINT [ "/entrypoint.sh" ]
