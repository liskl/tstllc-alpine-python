# tstllc-python

A small Python Docker image based on [Alpine Linux](http://alpinelinux.org/).

setting up for [ 2.7, 2.7-slim, 3.4, 3.4-slim ]

## REQUIREMENTS
Docker Containers:
* tstllc-base:latest


## DETAILS
* Installs `build-base` and `python-dev`, allowing the use of more advanced packages such as `gevent`
* Installs `bash` allowing interaction with the container
* Just like the main `python` docker image, it creates useful symlinks that are expected to exist, e.g. `python3.4` > `python`, `pip2.7` > `pip`, etc.)
* Added `testing` and `community` repositories to Alpine's `/etc/apk/repositories` file


## CONTENTS
```
IMAGE-NAME                      SHORT-HASH      SIZE
-------------------------------------------------------
tstllc-python:2.7               e3d9978dea9e     236 MB
tstllc-python:2.7-slim          b55a92ddb491    53.1 MB
tstllc-python:3.4               5419971ab4ac     240 MB
tstllc-python:3.4-slim          82ec5be18ae8    66.5 MB
tstllc-python:latest            5419971ab4ac     240 MB
tstllc-python:latest-slim       82ec5be18ae8    66.5 MB
```


## BUILD
how to get these images into your environment for development;

```bash
docker build --tag 'tstllc-python:2.7' ./2.7/;
docker build --tag 'tstllc-python:2.7-slim' ./2.7-slim/;
docker build --tag 'tstllc-python:3.4' ./3.4/;
docker build --tag 'tstllc-python:3.4-slim' ./3.4-slim/;
docker build --tag 'tstllc-python:latest' ./3.4/;
docker build --tag 'tstllc-python:latest-slim' ./3.4-slim/;
```


## INSTRUCTIONS

**NOTE:** `non-slim` images install the `requirements.txt` of your project from the get go. This allows you to cache your requirements right in the build. _Make sure you are in the same directory of your `requirements.txt` file_.

This image runs `python` command on `docker run`. You can either specify your own command, e.g:
```shell
docker run --rm -ti alpine-python python hello.py
```

You can also access `bash` inside the container:
```shell
docker run --rm -ti alpine-python bash
```

### Usage of `standard` images

These images can be used to bake your dependencies into an image by extending the plain python images. To do so, create a custom `Dockerfile` like this:
```dockerfile
FROM alpine-python:3.4

# for a flask server
EXPOSE 5000
CMD python manage.py runserver
```

Don't forget to build that `Dockerfile`:
```shell
docker build --rm=true -t app .;
docker run --rm -t app;
```

Personally, I build an extended `Dockerfile` version (like shown above), and mount my specific application inside the container:
```shell
docker run --rm -v "$(pwd)":/home/app -w /home/app -p 5000:5000 -ti app;
```

### Usage of `slim` images

These images are very small to download, and can install requirements at run-time via flags. The install only happens the first time the container is run, and dependencies can be baked in (see Creating Images).

#### Via `docker run`
These images can be run in multiple ways. With no arguments, it will run `python` interactively:
```shell
docker run --rm -ti tstllc-python:2.7-slim
```

If you specify a command, they will run that:
```shell
docker run --rm -ti tstllc-python:2.7-slim python hello.py
```

#### Pip Dependencies
Pip dependencies can be installed by the `-p` switch, or a `requirements.txt` file.

If the file is at `/requirements.txt` it will be automatically read for dependencies. If not, use the `-P` or `-r` switch to specify a file.
```shell
# This runs interactive Python with 'simplejson' and 'requests' installed
docker run --rm -ti tstllc-python:2.7-slim -p simplejson -p requests
```
```shell
# Don't forget to add '--' after your dependencies to run a custom command:
docker run --rm -ti tstllc-python:2.7-slim -p simplejson -p requests -- python hello.py
```
```shell
# This accomplishes the same thing by mounting a requirements.txt in:
echo 'simplejson' > requirements.txt
echo 'requests' > requirements.txt
docker run --rm -ti \
  -v requirements.txt:/requirements.txt \
  tstllc-python:2.7-slim python hello.py
```
```shell
# This does too, but with the file somewhere else:
echo 'simplejson requests' > myapp/requirements.txt
docker run --rm -ti \
  -v myapp:/usr/src/app \
  tstllc-python:2.7-slim \
    -r /usr/src/app/requirements.txt \
    -- python /usr/src/app/hello.py
```

#### Run-Time Dependencies
Alpine package dependencies can be installed by the `-a` switch, or an `apk-requirements.txt` file.

If the file is at `/apk-requirements.txt` it will be automatically read for dependencies. If not, use the `-A` switch to specify a file.

You can also try installing some Python modules via this method, but it is possible for Pip to interfere if it detects a version problem.
```shell
# Unknown why you'd need to do this, but you can!
docker run --rm -ti tstllc-python:2.7-slim -a openssl -- python hello.py
```
```shell
# This installs libxml2 module faster than via Pip, but then Pip reinstalls it because Ajenti's dependencies make it think it's the wrong version.
docker run --rm -ti tstllc-python:2.7-slim -a py-libxml2 -p ajenti
```

#### Build-Time Dependencies
Build-time Alpine package dependencies (such as compile headers) can be installed by the `-b` switch, or a `build-requirements.txt` file. They will be removed after the dependencies are installed to save space.

If the file is at `/build-requirements.txt` it will be automatically read for dependencies. If not, use the `-B` switch to specify a file.

`build-base`, `linux-headers` and `python-dev` are always build dependencies, you don't need to include them.
```shell
docker run --rm -ti tstllc-python:2.7-slim \
  -p gevent \
  -p libxml2 \
  -b libxslt-dev \
  -b libxml-dev \
  -- python hello.py
```

#### Creating Images
Similar to the onbuild images, dependencies can be baked into a new image by using a custom `Dockerfile`, e.g:
```dockerfile
FROM tstllc-python:2.7-slim
RUN /entrypoint.sh \
  -p ajenti-panel \
  -p ajenti.plugin.dashboard \
  -p ajenti.plugin.settings \
  -p ajenti.plugin.plugins \
  -b libxml2-dev \
  -b libxslt-dev \
  -b libffi-dev \
  -b openssl-dev \
&& echo
CMD ["ajenti-panel"]
# you won't be able to add more dependencies later though-- see 'Debugging'
```

#### Debugging
The `/entrypoint.sh` script that manages dependencies in the slim images creates an empty file, `/requirements.installed`, telling the script not to install any dependencies after the container's first run. Removing this file will allow the script to work again if it is needed.

You can also access `bash` inside the container:
```shell
docker run --rm -ti tstllc-python:2.7-slim bash
```


## REMOVAL
lets clean up after we are done to we don't have all that messy crap around.

```bash
docker rmi tstllc-python:2.7 \
           tstllc-python:2.7-slim \
           tstllc-python:3.4 \
           tstllc-python:3.4-slim \
           tstllc-python:latest \
           tstllc-python:latest-slim;
```


## RANDOM SNIPPETS AND INFO

Perhaps this could be even smaller, but I'm not an Alpine guru. **Feel free to post a PR.**
```
```

---
Completely ripped off from [jfloff](https://github.com/jfloff/alpine-python), and modded to use the tstllc-base image.
