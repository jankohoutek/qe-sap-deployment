# syntax=docker/dockerfile:experimental

FROM opensuse/tumbleweed:latest

## AZURE
# way suggested on https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=zypper
RUN zypper ref && zypper up -y && \
    zypper install -y tar gzip unzip curl python311-pip openssh && \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    zypper addrepo --name 'Azure CLI' --check https://packages.microsoft.com/yumrepos/azure-cli azure-cli && \
    zypper install --from azure-cli -y azure-cli && \
    zypper clean --all

WORKDIR /root

## GCP
# Methods are described in:
#  - https://cloud.google.com/sdk/docs/install
#  - https://github.com/os-autoinst/os-autoinst-distri-opensuse/blob/3270ae9ac3a8b4e455fe2109cadb65b432b910a3/tests/publiccloud/prepare_tools.pm#L113
#
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-linux-x86_64.tar.gz && \
    google-cloud-sdk/install.sh --quiet --usage-reporting false --command-completion true && \
    echo 'source /root/google-cloud-sdk/completion.bash.inc' >> ~/.bashrc && \
    echo 'source ~/google-cloud-sdk/path.bash.inc' >> ~/.bashrc && \
    rm google-cloud-cli-linux-x86_64.tar.gz

## Terraform
RUN curl https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin && \
    terraform -install-autocomplete && \
    rm terraform.zip

ENV VIRTUAL_ENV=/opt/venv
RUN python3.11 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
COPY requirements.txt .
COPY requirements.yml .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    ansible-galaxy install -r requirements.yml

RUN mkdir /src
WORKDIR /src
