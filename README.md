# prosody-filer-docker
This docker image packages [prosody-filer](https://github.com/ThomasLeister/prosody-filer) to be used with [nginx-proxy](https://github.com/jwilder/nginx-proxy).

# Example docker-compose.yml
```version: '2.1'
services:
  prosody:
    restart: unless-stopped
    container_name: prosody
    image: unclev/prosody-docker-extended:0.11
    ports:
      - "5000:5000"
      - "5222:5222"
      - "5223:5223"
      - "5269:5269"
    hostname: xmpp
    domainname: example.com
    environment:
      - VIRTUAL_HOST=xmpp.example.com
      - VIRTUAL_HOST_ALIAS=proxy.example.com,conference.example.com
      - VIRTUAL_PORT=5280
    volumes:
      - ./config:/etc/prosody
      - ./data:/var/lib/prosody
      - ./log:/var/log/prosody
      - ./modules/community:/usr/lib/prosody/modules-community
    networks:
      nginx-proxy-network:
  prosody-filer:
    restart: unless-stopped
    container_name: prosody-filer
    build: ./prosody-filer-docker
    environment:
      - SECRET=change-me
      - VIRTUAL_HOST=upload.example.com
    volumes:
      - ./uploads:/prosody-filer/uploads
    networks:
      nginx-proxy-network:

networks:
  nginx-proxy-network:
    external:
      name: nginx-proxy-network```

Add this to your `prosody.cfg.lua` and make sure to enable the `http_upload_external` module:
```http_upload_external_base_url = "https://upload.example.com/upload/"
http_upload_external_secret = "change-me"
http_upload_external_file_size_limit = 100000000```

There is one more step if you're using `nginx-proxy`. You need to create a vhost configuration in `/etc/nginx/vhost.d/upload.example.com` and add:
```client_max_body_size 100m;

location /upload/ {
    if ( $request_method = OPTIONS ) {
            add_header Access-Control-Allow-Origin '*';
            add_header Access-Control-Allow-Methods 'PUT, GET, OPTIONS, HEAD';
            add_header Access-Control-Allow-Headers 'Authorization, Content-Type';
            add_header Access-Control-Allow-Credentials 'true';
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 200;
    }

    proxy_pass http://prosody-filer;
    proxy_request_buffering off;
}```

**Make sure you use the correct `proxy_pass` hostname, as in your `container_name` or copy it from the generated `default.conf`**
