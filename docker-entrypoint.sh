#!/bin/sh
set -e

if [ "x$SECRET" == "x" ]; then
    echo "SECRET environment variable not set!"
    exit 1
fi

sed -i -r "s/SECRET/$(echo $SECRET | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" /prosody-filer/config.toml
sed -i -r "s/HTTP_UPLOAD_SUB_DIR/$(echo $HTTP_UPLOAD_SUB_DIR | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')/g" /prosody-filer/config.toml

exec "$@"
