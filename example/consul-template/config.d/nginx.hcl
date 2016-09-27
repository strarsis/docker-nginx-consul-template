template {
  source = "/etc/consul-template/template.d/app.conf.ctmpl"
  destination = "/etc/nginx/conf.d/app.conf"
  command = "/etc/consul-template/reload.d/nginx-reload.sh || true"

  perms = 0644
  backup = true
}
