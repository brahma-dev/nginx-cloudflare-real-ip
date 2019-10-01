#!/bin/bash
# Simple bash script to restore visitor real IP under Cloudflare with Nginx
# Script also whitelist cloudflare IP with UFW (if installed)

if [ "$1" = "--ufw" ] || [ "$2" = "--ufw" ]; then
    CF_UFW_SETUP="y"
fi

if [ "$1" = "--block" ] || [ "$2" = "--block" ]; then
    CF_BLOCK_SETUP="y"
fi

if [ -z "$(command -v curl)" ]; then
    echo "####################################"
    echo "Installing CURL"
    echo "####################################"
    apt-get update
    apt-get install curl -y
fi

CURL_BIN=$(command -v curl)
CF_IPV4=$($CURL_BIN -sL https://www.cloudflare.com/ips-v4)
CF_IPV6=$($CURL_BIN -sL https://www.cloudflare.com/ips-v6)

[ ! -d /etc/nginx/conf.d ] && {
    mkdir -p /etc/nginx/conf.d
}

echo '' > /etc/nginx/conf.d/cloudflare.conf
echo "####################################"
echo "Adding Cloudflare IPv4"
echo "####################################"
for cf_ip4 in $CF_IPV4; do
    echo "set_real_ip_from $cf_ip4;" >> /etc/nginx/conf.d/cloudflare.conf
    if [ "$CF_UFW_SETUP" = "y" ]; then
        ufw allow from $cf_ip4 to any port 80
        ufw allow from $cf_ip4 to any port 443
    fi
done
echo "####################################"
echo "Adding Cloudflare IPv6"
echo "####################################"
for cf_ip6 in $CF_IPV6; do
    echo "set_real_ip_from $cf_ip6;" >> /etc/nginx/conf.d/cloudflare.conf
    if [ "$CF_UFW_SETUP" = "y" ]; then
        ufw allow from $cf_ip6 to any port 80
        ufw allow from $cf_ip6 to any port 443
    fi
done
echo 'real_ip_header CF-Connecting-IP;' >> /etc/nginx/conf.d/cloudflare.conf


echo "####################################"
echo "Blocking IPs outside Cloudflare"
echo "####################################"
echo "" >> /etc/nginx/conf.d/cloudflare.conf
echo "geo \$realip_remote_addr \$is_cloudflare {" >> /etc/nginx/conf.d/cloudflare.conf
echo "default 0;" >> /etc/nginx/conf.d/cloudflare.conf
for cf_ip4 in $CF_IPV4; do
    echo "$cf_ip4 1;" >> /etc/nginx/conf.d/cloudflare.conf
done
for cf_ip6 in $CF_IPV6; do
    echo "$cf_ip6 1;" >> /etc/nginx/conf.d/cloudflare.conf
done
echo "}" >> /etc/nginx/conf.d/cloudflare.conf

if [ "$CF_UFW_SETUP" = "y" ]; then
    echo "####################################"
    echo "Reloading UFW"
    echo "####################################"
    ufw reload
fi
