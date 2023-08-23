# FROM python:3-alpine3.13 AS installer

# ENV AWSCLI_VERSION=2.2.16

# RUN apk add --no-cache \
#     gcc \
#     git \
#     libc-dev \
#     libffi-dev \
#     openssl-dev \
#     py3-pip \
#     zlib-dev \
#     make \
#     cmake

# RUN git clone --recursive  --depth 1 --branch ${AWSCLI_VERSION} --single-branch https://github.com/aws/aws-cli.git

# WORKDIR /aws-cli

# # # Follow https://github.com/six8/pyinstaller-alpine to install pyinstaller on alpine
# RUN pip install --no-cache-dir --upgrade pip \
#     && pip install --no-cache-dir pycrypto \
#     && git clone --depth 1 --single-branch --branch v$(grep PyInstaller requirements-build.txt | cut -d'=' -f3) https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
#     && cd /tmp/pyinstaller/bootloader \
#     && CFLAGS="-Wno-stringop-overflow -Wno-stringop-truncation" python ./waf configure --no-lsb all \
#     && pip install .. \
#     && rm -Rf /tmp/pyinstaller \
#     && cd - \
#     && boto_ver=$(grep botocore setup.cfg | cut -d'=' -f3) \
#     && git clone --single-branch --branch v2 https://github.com/boto/botocore /tmp/botocore \
#     && cd /tmp/botocore \
#     && git checkout $(git log --grep $boto_ver --pretty=format:"%h") \
#     && pip install . \
#     && rm -Rf /tmp/botocore  \
#     && cd -
# RUN sed -i '/botocore/d' requirements.txt \
#     && scripts/installers/make-exe


# RUN unzip dist/awscli-exe.zip \
#     && ./aws/install --bin-dir /aws-cli-bin


# FROM alpine:3


# RUN apk add --no-cache ca-certificates unzip bash git openssl openssh wget curl gettext jq bind-tools \
#     && wget -q https://amazon-eks.s3.us-west-2.amazonaws.com/1.20.4/2021-04-12/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
#     && wget -q https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator -O /usr/local/bin/aws-iam-authenticator \
#     && chmod +x /usr/local/bin/kubectl \
#     && chmod +x /usr/local/bin/aws-iam-authenticator \
#     && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash \
#     && chmod +x /usr/local/bin/helm \
#     && chmod g+rwx /root \
#     && mkdir /config \
#     && chmod g+rwx /config
    
# COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
# COPY --from=installer /aws-cli-bin/ /usr/local/bin/

# WORKDIR /config
# COPY base /config/base

# CMD bash



FROM alpine:latest

RUN apk update && \
    apk add --no-cache curl bash unzip openssl

# Install AWS CLI
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Set the working directory
WORKDIR /config


# Copy your custom Helm chart into the container
COPY base /config/base

# Set the entrypoint command
ENTRYPOINT ["/bin/bash"]