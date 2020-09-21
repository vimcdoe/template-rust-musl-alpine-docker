#!/bin/sh
docker build . -t rust_musl -f rust_musl.dockerfile
docker build . -t rustapp 
#docker rm "$(docker ps -aq)"
while [ "$(docker images -f "dangling=true" -q | sed -n  '2p')" != "" ]
do
docker rmi "$(docker images -f "dangling=true" -q | sed -n  '2p')"
done
if [ "$1" = "run" ]; then
docker run --rm -it rustapp
fi