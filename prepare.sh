 mkdir -p ~root/.ssh
 cp ~vagrant/.ssh/auth* ~root/.
 cat << EOF >> /etc/hosts
 192.168.255.1 inetRouter
 192.168.255.2 centralRouter
 192.168.254.2 office1Router
 192.168.253.2 office2Router
 192.168.2.66 office1Server
 192.168.1.130 office2Server
 192.168.0.2 centralServer
EOF
 


