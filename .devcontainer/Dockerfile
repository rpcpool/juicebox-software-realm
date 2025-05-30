# Dockerfile
FROM docker.io/golang:1.22.6

RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y apt-transport-https &&\
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
    apt-get update &&\
    apt-get install google-cloud-cli -y &&\
    apt-get clean

RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh &&\
    chmod +x install-opentofu.sh &&\
    ./install-opentofu.sh --install-method deb &&\
    rm -f install-opentofu.sh &&\
    apt-get clean