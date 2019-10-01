# nginx-cloudflare-real-ip

Configure Nginx to restore Visitors real IP under Cloudflare CDN

## Features

* Get Cloudflare IPv4 + IPv6 list and create nginx configuration to restore visitors real IP in `/etc/nginx/conf.d/cloudflare.conf`
* Whitelist Cloudflare IPs on port 80 & 443 with UFW (optional)
* Whitelist Cloudflare IPs in Nginx (optional)

## Requirements

* Nginx built with http_realip_module
* Nginx built with http_geo_module for whitelisting in Nginx

You can check if http_realip_module available with :

```bash
nginx -V 2>&1 | grep with-http_realip_module
```

If the previous command return nothing, http_realip_module isn't available

You can check if http_geoip_module available with :

```bash
nginx -V 2>&1 | grep with-http_geoip_module
```

If the previous command return nothing, http_geoip_module isn't available

---

## Usage

Nginx IP resolution only

```bash
bash <(wget -O - nginx-cloudflare || curl -sL raw.githubusercontent.com/brahma-dev/nginx-cloudflare-real-ip/master/nginx-cloudflare-real-ip.sh)
```

Nginx configuration + UFW configuration

```bash
bash <(wget -O - nginx-cloudflare || curl -sL raw.githubusercontent.com/brahma-dev/nginx-cloudflare-real-ip/master/nginx-cloudflare-real-ip.sh) --ufw
```

Nginx configuration + Nginx whitelist

```bash
bash <(wget -O - nginx-cloudflare || curl -sL raw.githubusercontent.com/brahma-dev/nginx-cloudflare-real-ip/master/nginx-cloudflare-real-ip.sh) --block
```

```
// Add this to your server blocks
if ($is_cloudflare != 1) {
    return 403;
}
```
