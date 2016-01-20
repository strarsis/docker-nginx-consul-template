FROM nginx:1.9


# Install supervisord
RUN apt-get update \
 && apt-get install -y supervisor

# supervisord main configuration
COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Install consul-template (binary)
RUN apt-get update \
 && apt-get install -y wget unzip

ENV consul_template_version "0.12.2"
RUN wget -q -O- "https://releases.hashicorp.com/consul-template/${consul_template_version}/consul-template_${consul_template_version}_linux_amd64.zip" \
    | funzip > /usr/bin/consul-template \
 && chmod +x /usr/bin/consul-template

# clean up
RUN apt-get autoremove --purge -y wget unzip \
 && apt-get clean


# consul-template supervisord service
COPY supervisord/consul-template.sv.conf /etc/supervisor/conf.d/consul-template.sv.conf

# consul-template configuration
RUN mkdir -p /etc/consul-template

# consul-template main configuration
COPY consul-template/config/main.hcl /etc/consul-template/config/main.hcl


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


# Service specific configuration (nginx)

# nginx supervisord service
COPY supervisord/nginx.sv.conf /etc/supervisor/conf.d/nginx.sv.conf

# Reload script for nginx for consul maintenance mode
# Expects SERVICE_NAME environment variable or skips the maintenance toggle
COPY consul-template/reload/nginx-reload.sh /etc/consul-template/reload/nginx-reload.sh

# empty env variables pass to consul-template
ENV CONSUL_HTTP_ADDR ""
ENV CONSUL_TOKEN     ""
ENV VAULT_ADDR       ""
ENV VAULT_TOKEN      ""


# nginx listen ports
EXPOSE 80
EXPOSE 443
