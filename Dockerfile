FROM ocaml/opam

# some of the following apt packages are likely already installed
RUN sudo apt-get install -y git make
RUN sudo apt-get install -y curl
RUN sudo apt-get install -y gcc
RUN sudo apt-get install -y bzip2
RUN sudo apt-get install -y wget
RUN sudo apt-get install -y unzip m4
RUN sudo apt-get install -y time
RUN sudo apt-get install -y rsync bubblewrap

RUN opam update

# install some common packages, so they are cached in future docker builds
RUN opam install dune ocamlfind odoc
RUN opam install core_kernel 
RUN opam install core
RUN opam install re

RUN sudo apt-get -y update
RUN sudo apt-get -y install gnuplot-x11 libgmp-dev pkg-config libffi-dev libkyotocabinet-dev librocksdb-dev libxxhash-dev liblmdb-dev libsqlite3-dev # FIXME aren't these deps of particular packages?


# clone repos we need ----------

RUN git clone https://github.com/tomjridge/mini-btree.git
RUN git clone https://github.com/tomjridge/kv-hash.git
RUN git clone https://github.com/tomjridge/kv-lite.git
RUN git clone https://github.com/mirage/repr.git
RUN git clone https://github.com/mirage/index.git
RUN git clone https://github.com/mirage/irmin.git
RUN (cd irmin && git submodule update --init --recursive)

RUN for f in index irmin; do (cd $f; git remote add tom https://github.com/tomjridge/$f; git fetch --all); done


# install dependencies of each repo ----------

RUN for f in mini-btree kv-hash kv-lite repr index irmin; do (cd $f; opam install . --deps-only --with-doc --with-test -y --ignore-pin-depend); done

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
# run something like: docker cp  docker-irmin-container:/home/opam/tree.exe .

# run test
# RUN ./tree.exe --mode=trace --ncommits-trace=1343496 --keep-stat-trace /data_1343496commits.repr 




