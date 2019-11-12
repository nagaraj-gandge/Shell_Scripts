#/bin/bash
set -x
if [ $# -ne 2 ]
  then
    echo "Please pass your web Server IPs/DNS Names as arguments to the script(exactly 2 arguments allowed)"
exit 1
fi
apt-get install haproxy -y
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/haproxy

echo "listen webfarm *:80
	mode http
	stats enable
	stats uri /haproxy?stats
	balance roundrobin
	option httpclose
	option forwardfor

cookie SRV_ID prefix
	server webserver01 $1:80 cookie webserver01 check
	server webserver02 $2:80 cookie webserver02 check" >> /etc/haproxy/haproxy.cfg
service haproxy restart

exit 0