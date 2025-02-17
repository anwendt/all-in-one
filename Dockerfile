FROM alpine:latest

LABEL org.opencontainers.image.title="All-in-One Container" \
      org.opencontainers.image.description="Multi-arch All-in-One Container" \
      org.opencontainers.image.vendor="Andres Wendt" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="Apache-2.0"

ARG VERSION=1.0.0

RUN apk upgrade --no-cache && \
    apk add --no-cache \
        bridge-utils \
        busybox-extras \
        ca-certificates \
        conntrack-tools \
        curl \
        bind-tools \
        ethtool \
        iperf \
        iperf3 \
        iproute2 \
        ipset \
        iptables \
        iputils \
        jq \
        kmod \
        openldap-clients \
        less \
        libpcap-dev \
        man-pages \
        mtr \
        net-tools \
        netcat-openbsd \
        openssl \
        openssh-client \
        psmisc \
        socat \
        tcpdump \
        tmux \
        traceroute \
        tree \
        ngrep \
        vim \
        wget

# Install yq based on architecture
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq; \
    elif [ "$ARCH" = "aarch64" ]; then \
        wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && chmod +x /usr/bin/yq

# Install latest kubectl based on architecture
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && chmod +x kubectl && mv kubectl /usr/local/bin/

# Install latest helm based on architecture
RUN ARCH=$(uname -m) && \
    HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -LO "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz"; \
        tar -zxvf helm-$HELM_VERSION-linux-amd64.tar.gz; \
        mv linux-amd64/helm /usr/local/bin/helm; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -LO "https://get.helm.sh/helm-$HELM_VERSION-linux-arm64.tar.gz"; \
        tar -zxvf helm-$HELM_VERSION-linux-arm64.tar.gz; \
        mv linux-arm64/helm /usr/local/bin/helm; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && chmod +x /usr/local/bin/helm && rm -rf linux-amd64 linux-arm64 helm-*.tar.gz

# Create and use non-root user
RUN adduser -D -u 1001 investigator
USER investigator

# Create .kube directory
RUN mkdir -p /home/investigator/.kube

WORKDIR /home/investigator
CMD ["swiss-army-knife"]
