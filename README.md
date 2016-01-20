# docker-nginx-consul-template
Docker image for nginx + consul-template (supervisord)


Usage
-----
Before intended usage, an image with consul-template configuration/configuration template files has to be built based of this image.


Rationale
---------
- supervisord runs the services in the container, consul-template and nginx, as best practice for multiple services in a docker container.
- HCL configuration files used by consul-template don't support interpolation of environment variables, 
  this has been solved by letting supervisord pass the available consul-template environment variables 
  (mapped to the consul-template options) as command line arguments to consul-template.
  This allows to set the consul-template options using ENV in the Dockerfile.
- supervisord + consul-template both use configuration folders into which further configuration files for more services + templates can be put in based of images.
- One single consul-template configuration file should handle all (multiple) template configuration files of a service (reload).
- The reload script, which should be used by consul-template for reloading nginx, also toggles the maintenance mode for the consul service. This is done when the environment variable SERVICE_NAME has been set (e.g. used for Docker + Registrator + Consul) (otherwise the toggling is skipped).
- The image comes already with a base configuration for consul-template, main.hcl.
- See the example Dockerfile below and the file contents in ./example folder.


### Example Dockerfile
In this repository there is already a folder ./example which contains 
an empty placeholder configuration template file 
and a consul-template configuration file for using the configuration template file.

````
FROM nginx-consul-template:1.9-0.12.2

# Set consul/vault settings for consul-template directly in Dockerfile using ENV
ENV CONSUL_HTTP_ADDR "consul"
ENV CONSUL_TOKEN     ""
ENV VAULT_ADDR       "vault"
ENV VAULT_TOKEN      ""


# Configuration template files
COPY example/app.conf.ctmpl /etc/consul-template/templates/app.conf.ctmpl
# another.conf.ctmpl ...
# yet-another.conf.ctmpl

# Consul-template configuration for using these configuration template files (+ service reload)
COPY example/nginx.hcl /etc/consul-template/config/nginx.hcl

````
