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

# If you want to include it directly in the image (e.g. a sample or empty config),
# copy your nginx configuration template file into the container
# COPY app.conf.ctmpl /etc/consul-templates/app.conf.ctmpl
# Otherwise, mount the config templates folder or individual file(s) into /etc/consul-templates/ when running the image.

# consul-template config
COPY consul-template.hcl /etc/consul-template.hcl

# Configure consul-template to use this template file
# Either directly in image or mount from outside.
# /etc/supervisor/conf.d/consul-template.sv.conf:
RUN echo '[program:consul-template]\n\
# Log to stdout/stderr\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
command=VAULT_ADDR=vault1 VAULT_TOKEN=the-vault-token \n\
        consul-template \n\
         -config /etc/consul-template.hcl \n\
         -consul consulx1:8500 \n\
         -token  the-consul-token \n\
         -template "/etc/consul-templates/app.conf.ctmpl:/etc/nginx/conf.d/app.conf:sv hup nginx || true"\n'\
> /etc/supervisor/conf.d/consul-template.sv.conf


# CMD like the one used in the based of Dockerfile
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
````
