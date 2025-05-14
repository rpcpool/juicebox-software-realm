# Dockerfile
FROM golang:1.22.6

RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y apt-transport-https &&\
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
    apt-get update &&\
    apt-get install google-cloud-cli -y &&\
    apt-get clean