# docker-nginx-consul-template
Docker image for nginx + consul-template


Rationale
---------
- chaperone process manager runs the service processes in the container, consul agent, consul-template and nginx, as best practice for multiple services in a docker container.
- HCL configuration files used by consul-template don't support interpolation of environment variables, 
  this has been solved by letting chaperone pass the available consul-template environment variables 
  (mapped to the consul-template options) as command line arguments to consul-template.
  This allows to set the consul-template options using ENV in the Dockerfile.
- chaperone, consul agent and consul-template both use configuration folders into which further configuration files for more services + templates can be put in based of images.
- One single consul-template configuration file should handle all (multiple) template configuration files of a service (reload).
- The reload script, which should be used by consul-template for reloading nginx, also toggles the maintenance mode for the consul service. This is done when the environment variable SERVICE_NAME has been set (e.g. used for Docker + Registrator + Consul) (otherwise the toggling is skipped).
- The image comes already with a base configuration for consul-template, main.hcl.
- A local consul agent is used over which consul-template or consul actions can connect to a consul server.
- See the example Dockerfile below and the file contents in ./example folder.


Usage
-----
Before intended usage, an image with consul-template configuration/configuration template files has to be built based of this image 
or mounted into the container (e.g. by using docker-compose).

### Example Dockerfile
In this repository there is already a folder ./example which contains 
an empty placeholder configuration template file 
and a consul-template configuration file for using the configuration template file.

````
FROM strarsis/nginx-consul-template:1.9.15-0.15.0-0.7.0


# Set consul/vault settings for consul-template directly in Dockerfile using ENV

# Note: CONSUL_HTTP_ADDR without http(s)://
ENV CONSUL_HTTP_ADDR "consul:8500"
ENV CONSUL_TOKEN     "the-token-for-consul"

ENV VAULT_ADDR       "https://vault.service.consul:8200"
ENV VAULT_TOKEN      "the-token-for-vault"


# Configuration template files
COPY example/consul-template/template.d/app.conf.ctmpl /etc/consul-template/template.d/app.conf.ctmpl
# another.conf.ctmpl ...
# yet-another.conf.ctmpl

# Consul-template configuration for using these configuration template files (+ service reload)
COPY example/consul-template/confid.d/nginx.hcl /etc/consul-template/config.d/nginx.hcl

````

### Run example with this Dockerfile / image
The example files can also be directly mounted into the container instance:
````
docker run [...] -v $PWD/example/consul-template/template.d/app.conf.ctmpl:/etc/consul-template/template.d/app.conf.ctmpl -v $PWD/example/consul-template/config.d/nginx.hcl:/etc/consul-template/config.d/nginx.hcl [...] strarsis/nginx-consul-template:1.9.15-0.15.0-0.7.0
````

