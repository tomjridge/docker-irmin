

# some of the following apt packages are likely already installed
sudo apt-get install -y git make
sudo apt-get install -y curl
sudo apt-get install -y gcc
sudo apt-get install -y bzip2
sudo apt-get install -y wget
sudo apt-get install -y unzip m4
sudo apt-get install -y time
sudo apt-get install -y rsync bubblewrap

opam update

# install some common packages, so they are cached in future docker builds
opam install dune ocamlfind odoc
opam install core_kernel 
opam install core
opam install re

sudo apt-get -y update
sudo apt-get -y install gnuplot-x11 libgmp-dev pkg-config libffi-dev libkyotocabinet-dev librocksdb-dev libxxhash-dev liblmdb-dev libsqlite3-dev # FIXME aren't these deps of particular packages?


# clone repos we need ----------

git clone https://github.com/tomjridge/mini-btree.git
git clone https://github.com/tomjridge/kv-hash.git
git clone https://github.com/tomjridge/kv-lite.git
git clone https://github.com/mirage/repr.git
git clone https://github.com/mirage/index.git
git clone https://github.com/mirage/irmin.git
(cd irmin && git submodule update --init --recursive)

for f in index irmin; do (cd $f; git remote add tom https://github.com/tomjridge/$f; git fetch --all); done


# install dependencies of each repo ----------

#(equinix) eval $(opam env)

for f in mini-btree kv-hash kv-lite repr index irmin; do (cd $f; opam install . --deps-only --with-doc --with-test -y --ignore-pin-depend); done

# missing irmin dep
opam install bentov


# build -----------------------

# kv_lite
# RUN eval $(opam env) && (cd kv-lite && make)

# tree.exe
echo rebuild....
echo `realpath .`
eval $(opam env) && dune build -- ./irmin/bench/irmin-pack/tree.exe
eval $(opam env) && cp _build/default/irmin/bench/irmin-pack/tree.exe .

# extract exe from container ------------
# run something like: docker cp  docker-irmin-container:/home/opam/tree.exe .

# run test
# RUN ./tree.exe --mode=trace --ncommits-trace=1343496 --keep-stat-trace /data_1343496commits.repr 




