FROM nginx:1.9


# supervisor
RUN apt-get update \
 && apt-get install -y supervisor

# Start consul-template together with nginx
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# /etc/supervisor/conf.d/consul-template.sv.conf:
RUN echo '[program:consul-template]\n\
command=consul-template \\\n\
         -consul consul:8500 \\\n\
         -template "/etc/consul-templates/app.conf.ctmpl:/etc/nginx/conf.d/app.conf:sv hup nginx || true\n'\
> /etc/supervisor/conf.d/consul-template.sv.conf


# /etc/supervisor/conf.d/nginx.sv.conf:
RUN echo '[program:nginx]\n\
command=nginx'\
> /etc/supervisor/conf.d/nginx.sv.conf



# consul-template binary
RUN apt-get update \
 && apt-get install -y wget unzip

ENV consul_template_version "0.12.0"
RUN wget -O- "https://releases.hashicorp.com/consul-template/${consul_template_version}/consul-template_${consul_template_version}_linux_amd64.zip" \
    | funzip > /usr/bin/consul-template \
 && chmod +x /usr/bin/consul-template

RUN apt-get autoremove --purge -y wget unzip \
 && apt-get clean



CMD ["/usr/bin/supervisord"]

# nginx listen ports
EXPOSE 80
EXPOSE 443
