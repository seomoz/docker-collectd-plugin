#!/usr/bin/env bash

set -eo pipefail

deploy_test_app(){
  payload="$(cat <<'EOF'
{
  "container": {
    "type": "DOCKER",
    "docker": {
      "network": "HOST",
      "image": "alpine"
    }
  },
  "cmd": "while true; do sleep 1; done"
}
EOF)"

  curl                                  \
    -X PUT                              \
    -H 'Content-Type: application/json' \
    -d "$payload"                       \
    http://192.168.33.33:8080/v2/apps/test
}

main(){
  deploy_test_app
  script="$(cat <<EOF
    [ ! -d /usr/share/collectd/python ] && sudo mkdir /usr/share/collectd/python
    sudo cp -f /vagrant/config/* /etc/collectd/collectd.conf.d/
    sudo cp -f /vagrant/dockerplugin.py /usr/share/collectd/python/
    sudo cp -f /vagrant/dockerplugin.db /usr/share/collectd/
    # Need this, otherwise we get a parse error
    echo "" | sudo tee -a /etc/collectd/collectd.conf.d/test.conf
    sudo service collectd restart
EOF)"
  vagrant ssh -c "$script"
}

main
