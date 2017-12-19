### Dependencies

Install:
* pkg-config
* autogen
* autoconf?

```
cd curl
./configure
make
make install
cd ..

cd miner
./autogen.sh
./configure CFLAGS="-march=arm7-a" --with-crypto= --with-curl=../curl
make
```
