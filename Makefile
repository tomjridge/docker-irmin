# flgs: --no-cache

all: minimal

default:
	docker build -t docker-irmin-container .

# https://stackoverflow.com/questions/25292198/docker-how-can-i-copy-a-file-from-an-image-to-a-host
cp_from_container:
	docker run --rm --entrypoint cat docker-irmin-container  /home/opam/tree.exe > ./tree.exe
	chmod u+x ./tree.exe

# strip leading "RUN" from Dockerfile
init.sh: Dockerfile FORCE
	cat Dockerfile | sed 's/^RUN //g' | sed 's/FROM.*//' >$@

download_repr:
	export COMANCHE=128.232.124.177 && scp tom@${COMANCHE}:/bench/tom/data_1343496commits.repr /tmp

minimal:
	docker build -t docker-irmin-minimal -f Dockerfile.minimal .

main:
	docker build -t docker-irmin-main -f Dockerfile.main .

FORCE:
