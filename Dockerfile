# Notice: Disable conntrack.

FROM nginx:1.9.15


# Install chaperone process manager
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-pip && \
    pip3 install chaperone
RUN mkdir -p /etc/chaperone.d/
ENTRYPOINT ["/usr/local/bin/chaperone"]


# Install consul-template + consul agent (binary)
ENV CONSUL_TEMPLATE_VERSION "0.15.0"
ENV CONSUL_VERSION          "0.7.0"

# Modified from https://github.com/hashicorp/docker-consul/blob/master/0.X/Dockerfile
RUN apt-get update && \
    apt-get install --no-install-recommends -y unzip wget

RUN gpg --keyserver pgp.mit.edu --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C

# consul-template
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip ./consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS      ./consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig  ./consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig

RUN gpg --batch --verify consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS && \
    grep consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

# consul
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip ./consul_${CONSUL_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS      ./consul_${CONSUL_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig  ./consul_${CONSUL_VERSION}_SHA256SUMS.sig

RUN gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip

# clean up
RUN apt-get autoremove --purge -y unzip wget && \
    apt-get clean && \

    cd /tmp && \
    rm -rf /tmp/build && \
    rm -rf /root/.gnupg


# consul-template configurations folder
RUN mkdir -p /etc/consul-template/config.d/

# consul-template main configuration
COPY consul-template/config.d/ /etc/consul-template/config.d/

# consul-template templates folder
RUN mkdir -p /etc/consul-template/template.d/


# consul agent configuration
RUN mkdir -p /etc/consul.d/

# consul agent main configuration
COPY consul.d/ /etc/consul.d/


# Copy service configuration:
COPY chaperone.d /etc/chaperone.d/


# Service specific configuration (nginx)

# Reload script for nginx for consul maintenance mode
# Expects SERVICE_NAME environment variable or skips the maintenance toggle
COPY consul-template/reload.d/nginx-reload.sh /etc/consul-template/reload.d/nginx-reload.sh

# empty env variables pass to consul-template
ENV CONSUL_HTTP_ADDR  ""
ENV CONSUL_HTTP_TOKEN ""
ENV VAULT_ADDR        ""
ENV VAULT_TOKEN       ""


# nginx listen ports
EXPOSE 80
EXPOSE 443
