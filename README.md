# docker-nginx-consul-template
Docker image for nginx + consul-template (supervisord)


Copy the nginx configuration template
````
COPY app.conf.ctmpl /etc/consul-templates/app.conf.ctmpl
````

Configure consul-template:
````
# /etc/supervisor/conf.d/consul-template.sv.conf:
RUN echo '[program:consul-template]\n\
command=consul-template \n\
         -consul consul:8500 \n\
         -template "/etc/consul-templates/app.conf.ctmpl:/etc/nginx/conf.d/app.conf:sv hup nginx || true"\n'\
> /etc/supervisor/conf.d/consul-template.sv.conf
````
