# Only passable by argument line instead option:
# -consul / CONSUL_HTTP_ADDR
# -token  / CONSUL_TOKEN
# VAULT_ADDR
# VAULT_TOKEN


retry = "10s"
max_stale = "10m"

vault {
  renew = true
  ssl {
    enabled = false
  }
}

ssl {
  enabled = false
}

syslog {
  enabled  = false
  facility = "LOCAL0"
}

deduplicate {
  enabled = true
  prefix  = "consul-template/dedup/"
}


# Multiple template files in folder are supported,
# put them into /etc/consul-template/config.d/ .
