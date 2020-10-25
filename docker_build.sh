#!/bin/sh
image_name=rustapp
package_name=$(sed -n '2p' Cargo.toml|cut -d '"' -f 2)


docker build . -t rust_musl -f rust_musl.dockerfile --force-rm

if [ "$(sed -n '1p' Cargo.toml )" = "[package]" ] && [ "$(sed -n '2p' Cargo.toml|cut -d ' ' -f 1)" = "name" ]
then
    if [ "$(docker images |grep $image_name)" != "" ]
    then
    	echo "remove old  $image_name image."
    	docker rmi "$image_name"
    fi
    
    #docker build
    docker build . -t "$image_name" --build-arg name="$package_name" --force-rm
    
    while [ "$(docker images -f "dangling=true" -q | sed -n  '2p')" != "" ]
    do
        docker rmi "$(docker images -f "dangling=true" -q | sed -n  '2p')"
    done
    
    #docker run --rm 
    if [ "$1" = "run" ] && [  "$(docker images |grep $image_name)" != "" ]; then
    	echo "resources/docker_entrypoint.sh"
    	echo ''
        docker run --rm -it "$image_name"
    fi
    #docker rm "$(docker ps -aq)"
else
    echo "error: in Cargo.toml line 2 is not package name. "
fi
