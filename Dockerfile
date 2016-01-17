FROM nginx:1.9


# supervisor
RUN apt-get update \
 && apt-get install -y supervisor

# Set up supervisord to start consul-template together with nginx
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# /etc/supervisor/conf.d/nginx.sv.conf:
RUN echo '[program:nginx]\n\
# Log to stdout/stderr\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
command=nginx\n'\
> /etc/supervisor/conf.d/nginx.sv.conf

RUN echo '\ndaemon off;' >> /etc/nginx/nginx.conf


# consul-template binary
RUN apt-get update \
 && apt-get install -y wget unzip

ENV consul_template_version "0.12.0"
RUN wget -q -O- "https://releases.hashicorp.com/consul-template/${consul_template_version}/consul-template_${consul_template_version}_linux_amd64.zip" \
    | funzip > /usr/bin/consul-template \
 && chmod +x /usr/bin/consul-template

RUN apt-get autoremove --purge -y wget unzip \
 && apt-get clean


CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# nginx listen ports
EXPOSE 80
EXPOSE 443
