#!/bin/sh
APP_NAME="hello"

if [ $(docker ps -a -f name="$APP_NAME"-BLUE -q) ]
then
    ENV="GREEN"
    OLD="BLUE"
else
    ENV="BLUE"
    OLD="GREEN"
fi

echo "Starting "$ENV" container"
#app
docker run --rm --name "$APP_NAME"-"$ENV" -v $(pwd)/hello.py:/usr/local/src/hello.py --net hello -d python:3 python /usr/local/src/hello.py

#nginx
docker run --rm -d --name "$APP_NAME"-nginx --net hello -p 8080:80 nginx
docker cp nginx-conf.d/$ENV.conf "$APP_NAME"-nginx:/etc/nginx/conf.d/default.conf
docker run --rm --net hello nginx nginx -t


echo "Stopping "$OLD" container"
docker kill -s HUP $APP_NAME-nginx
docker stop $APP_NAME-$OLD
docker rm -f $APP_NAME-$OLD
