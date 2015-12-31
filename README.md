# docker-nginx-consul-template
Docker image for nginx + consul-template (supervisord)

Usage
-----
Base of from this image to set up consul-template for nginx configuration.


Extra information
-----------------
For setting up consul-template to use a consul host by address + port injected by docker(-compose):

1. Use a hostname for consul default or fixed port during build (e.g. "consulx1").

2. Use environment variables (in [supervisord config](http://supervisord.org/configuration.html#environment-variables)) (e.g. %{ENV_CONSUL_HOST}:%{ENV_CONSUL_PORT}).

### Set up supervisord to log to stdout/stderr
This is already done in this image for nginx and in the example Dockerfile below for consul-template.


For further information, see this very helpful blog post:
http://veithen.github.io/2015/01/08/supervisord-redirecting-stdout.html

### Mounting your own (main) nginx.conf
Don't forget to add/append this line to it to make it work properly with supervisord:
````
daemon off;
````


### Example Dockerfile
````
FROM nginx-consul-template:latest

# Copy your nginx configuration template file into the container
COPY app.conf.ctmpl /etc/consul-templates/app.conf.ctmpl

# Configure consul-template to use this template file
# /etc/supervisor/conf.d/consul-template.sv.conf:
RUN echo '[program:consul-template]\n\
# Log to stdout/stderr\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
command=consul-template \n\
         -consul consulx1:8500 \n\
         -template "/etc/consul-templates/app.conf.ctmpl:/etc/nginx/conf.d/app.conf:sv hup nginx || true"\n'\
> /etc/supervisor/conf.d/consul-template.sv.conf


# CMD like the one used in the based of Dockerfile
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
````
