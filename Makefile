all:
	docker build -t docker-irmin-container .

# https://stackoverflow.com/questions/25292198/docker-how-can-i-copy-a-file-from-an-image-to-a-host
cp_from_container:
	docker run --rm --entrypoint cat docker-irmin-container  /home/opam/tree.exe > ./tree.exe
	chmod u+x ./tree.exe

# strip leading "RUN" from Dockerfile
init.sh: Dockerfile FORCE
	cat Dockerfile | sed 's/^RUN //g' | sed 's/FROM.*//' >$@

FORCE:
