template {
  source = "/etc/consul-template/template/app.conf.ctmpl"
  destination = "/etc/nginx/conf.d/app.conf"
  command = "/etc/consul-template/reload/nginx-reload.sh || true"

  perms = 0644
  backup = true
}
