# docker-nginx-consul-template
Docker image for nginx + consul-template (supervisord)

Usage
-----
Base of from this image to set up consul-template for nginx configuration.

### Example Dockerfile
````
FROM nginx-consul-template:latest

# Copy the nginx configuration template file
COPY app.conf.ctmpl /etc/consul-templates/app.conf.ctmpl

# Configure consul-template to use this template file
# /etc/supervisor/conf.d/consul-template.sv.conf:
RUN echo '[program:consul-template]\n\
command=consul-template \n\
         -consul consul:8500 \n\
         -template "/etc/consul-templates/app.conf.ctmpl:/etc/nginx/conf.d/app.conf:sv hup nginx || true"\n'\
> /etc/supervisor/conf.d/consul-template.sv.conf


# CMD like the one used in the based of Dockerfile
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
````
