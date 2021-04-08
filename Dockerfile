FROM centos:centos8

MAINTAINER Filipe Santos 

ENV OPENSHIFT_VERSION=4.7.5

RUN echo "retrieve and Install oc-client" && \
    curl -Lo /tmp/client-tools.tar.gz "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$OPENSHIFT_VERSION/openshift-client-linux-$OPENSHIFT_VERSION.tar.gz" && \
    tar zxf /tmp/client-tools.tar.gz -C /usr/local/bin oc && \
    rm /tmp/client-tools.tar.gz

RUN echo "installing Epel release" && \
    dnf install epel-release -y

RUN echo "Updating the baseline image" && \
    dnf update -y 

RUN echo "Installing jq" && \
    yum install jq -y

ADD ./startup.sh startup.sh

USER 1000

CMD ["sleep", "3600"]