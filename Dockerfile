FROM --platform=$TARGETPLATFORM debian:bullseye-slim

# User, home (app) and data folders
ARG USER=jenkins
ARG DATA=/data
ENV HOME /usr/src/$USER
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-armhf

# Match the guid as on host
ARG DOCKER_GROUP_ID=995
ARG DOCKER_GROUP_NAME=docker

ENV JENKINS_HOME $DATA
ENV JENKINS_WEB_PORT 8080
ENV JENKINS_SLAVE_PORT 50000

# Extra runtime packages
RUN apt-get update && \
    apt-get install -y -qq --no-install-recommends \
      openjdk-11-jre-headless \
      git ssh wget time procps && \
    rm -rf /var/lib/apt/lists/* && \
# Prepare data and app folder
    mkdir -p $DATA && \
    mkdir -p $HOME && \
# Add $USER user so we aren't running as root
    adduser --home $DATA --no-create-home -gecos '' --disabled-password $USER && \
    chown -R $USER:$USER $HOME && \
    chown -R $USER:$USER $DATA && \
# Add $USER to docker group, same guid as pi on host
    groupadd -g $DOCKER_GROUP_ID $DOCKER_GROUP_NAME && \
    usermod -aG $DOCKER_GROUP_NAME $USER

RUN wget https://updates.jenkins-ci.org/download/war/latest/jenkins.war \
    && mv jenkins.war $HOME

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Jenkins web interface, connected slave agents
EXPOSE $JENKINS_WEB_PORT $JENKINS_SLAVE_PORT

# VOLUME $DATA
WORKDIR $DATA

USER $USER

# exec java -jar $HOME/jenkins.war --prefix=$PREFIX
ENTRYPOINT [ "/entrypoint.sh" ]
