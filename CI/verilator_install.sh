sudo apt-get install git help2man perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2
sudo apt-get install libfl-dev
sudo apt-get install zlibc zlib1g zlib1g-dev
git clone https://github.com/verilator/verilator
unset VERILATOR_ROOT
cd verilator
git pull
git checkout v5.014
autoconf
./configure
make -j `nproc` 
sudo make install
rm -rf verilator
