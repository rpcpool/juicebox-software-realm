# Dockerfile
FROM docker.io/golang:1.22.6

RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get install -y apt-transport-https ca-certificates curl wget gnupg &&\
    apt-get clean

RUN install -m 0755 -d /etc/apt/keyrings &&\
    curl -fsSL https://get.opentofu.org/opentofu.gpg | tee /etc/apt/keyrings/opentofu.gpg >/dev/null &&\
    curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null &&\
    chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg &&\
    echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | tee /etc/apt/sources.list.d/opentofu.list > /dev/null &&\
    chmod a+r /etc/apt/sources.list.d/opentofu.list &&\
    apt-get update &&\
    apt-get install -y tofu &&\
    apt-get clean

RUN mkdir -p /usr/local/bin && apt-get update && apt-get install -y unzip && curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null &&\
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | tee -a /etc/apt/sources.list.d/trivy.list &&\
    apt-get update &&\
    apt-get install -y trivy &&\
    apt-get clean
