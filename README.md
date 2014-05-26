Syncthing server docker image
=============================

A simple image for a Syncthing server. https://github.com/calmh/syncthing

Usage
=====

Assuming you want to mount Syncthing' working directories on the host (not very
useful if you don't):

```shellsession
export VOLUMES=/srv/docker/volumes/syncthing
sudo mkdir -p $VOLUMES/{config,data}
docker run -d --name syncthing \
           -p 8080:8080 -p 22000:22000 -p 21025:21025/udp \
           -v $VOLUMES/config:/home/syncthing/.config/syncthing \
           -v $VOLUMES/data:/home/syncthing/Sync \
           ncadou/syncthing
```

The web interface will be accessible at http://127.0.0.1:8080
