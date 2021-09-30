FROM ocaml/opam

#(equinix) apt-get update && apt-get install docker.io
#(equinix) export COMANCHE=128.232.124.177
#(equinix) scp tom@$COMANCHE:/bench/tom/data_1343496commits.repr . # 35 mins; do concurrently with building Dockerfile

# some of the following apt packages are likely already installed
RUN sudo apt-get update
# sudo apt-get install opam # if not already present
RUN sudo apt-get install -y git make
RUN sudo apt-get install -y curl
RUN sudo apt-get install -y gcc
RUN sudo apt-get install -y bzip2
RUN sudo apt-get install -y wget
RUN sudo apt-get install -y unzip m4
RUN sudo apt-get install -y time
RUN sudo apt-get install -y rsync bubblewrap

#(equinix) mkdir ocaml; cd ocaml # to avoid having to scan entire fs
#(equinix) opam init
#(equinix) eval $(opam env)
#(equinix and docker?) export OPAMYES=true

RUN opam update

# install some common packages, so they are cached in future docker builds
RUN opam install dune ocamlfind odoc
RUN opam install core_kernel 
RUN opam install core
RUN opam install re

RUN sudo apt-get -y update
RUN sudo apt-get -y install gnuplot-x11 libgmp-dev pkg-config libffi-dev libkyotocabinet-dev librocksdb-dev libxxhash-dev liblmdb-dev libsqlite3-dev # FIXME aren't these deps of particular packages?


# clone repos we need ----------

RUN echo rebuild........
RUN git clone https://github.com/tomjridge/tjr_util.git
RUN git clone https://github.com/tomjridge/mini-btree.git
RUN git clone https://github.com/tomjridge/kv-hash.git
RUN git clone https://github.com/tomjridge/kv-lite.git
RUN git clone https://github.com/mirage/repr.git
RUN git clone https://github.com/mirage/index.git
RUN git clone https://github.com/mirage/irmin.git
RUN (cd irmin && git submodule update --init --recursive)

RUN for f in index irmin; do (cd $f; git remote add tom https://github.com/tomjridge/$f; git fetch --all); done

# checkout particular versions ------

RUN (cd index && git checkout 21q3_index-lite)


# test compile FIXME remove --------------

# NOTE some of these are just ocamlfind libs, not opam packages

# dependencies for my packages, since they aren't properly opam'ed yet
# FIXME should be able to get these from opam, without doing something funny
RUN echo rebuild......
RUN eval $(opam env); opam install bigstringaf dune lwt xxhash sexplib base lwt caqti caqti-lwt caqti-driver-sqlite3 kyotocabinet ahrocksdb lmdb
RUN for f in tjr_util mini-btree kv-hash kv-lite; do (eval $(opam env); cd $f; make); done

# install dependencies of each repo ----------

RUN for f in repr index irmin; do (cd $f; opam install . --deps-only --with-doc --with-test -y --ignore-pin-depend); done

# missing irmin dep
RUN opam install bentov


# build -----------------------

# kv_lite
# RUN eval $(opam env) && (cd kv-lite && make)

# tree.exe
RUN echo rebuild....
RUN echo `realpath .`
RUN eval $(opam env) && dune build -- ./irmin/bench/irmin-pack/tree.exe
RUN eval $(opam env) && cp _build/default/irmin/bench/irmin-pack/tree.exe .

# extract exe from container ------------
# see Makefile

# run test
# RUN ./tree.exe --mode=trace --ncommits-trace=1343496 --keep-stat-trace /data_1343496commits.repr 




