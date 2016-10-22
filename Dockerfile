# Notice: Disable conntrack.

FROM nginx:1.9.15


# Install chaperone process manager
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-pip && \
    pip3 install chaperone
RUN mkdir -p /etc/chaperone.d/
ENTRYPOINT ["/usr/local/bin/chaperone"]


# Install consul-template + consul agent (binary)
ENV consul_template_version "0.15.0"
ENV consul_version          "0.7.0"

RUN apt-get update \
 && apt-get install --no-install-recommends -y wget unzip

RUN wget -q -O- "https://releases.hashicorp.com/consul-template/${consul_template_version}/consul-template_${consul_template_version}_linux_amd64.zip" \
    | funzip > /usr/bin/consul-template \
 && chmod +x /usr/bin/consul-template

RUN wget -q -O- "https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip" \
    | funzip > /usr/bin/consul \
 && chmod +x /usr/bin/consul

# clean up
RUN apt-get autoremove --purge -y wget unzip \
 && apt-get clean


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
