# GCC support can be specified at major, minor, or micro version
# (e.g. 8, 8.2 or 8.2.0).
# See https://hub.docker.com/r/library/gcc/ for all supported GCC
# tags from Docker Hub.
# See https://docs.docker.com/samples/library/gcc/ for more on how to use this image
FROM gcc:latest

# These commands copy your files into the specified directory in the image
# and set that as the working location
RUN mkdir /usr/src
COPY . /usr/src
WORKDIR /usr/src

RUN apt-get install -y gcc gcc-c++ make wget curl openssl \ 
    autoconf automake libtool unzip

RUN wget http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz && \
    tar -xzvf boost_1_60_0.tar.gz && \
    cd boost_1_60_0 && \
    ./bootstrap.sh --prefix=/usr/local && \
    ./b2 install --with=all && \
    sudo mv boost_1_60_0 /usr/local

ENV PATH $PATH:/usr/local/boost_1_60_0
ENV PATH $PATH:/usr/local/boost_1_60_0/stage/lib

RUN git clone https://github.com/google/protobuf && \
    cd protobuf && \
    ./autogen.sh && \
    ./configure && \
    make && \
    sudo make install \
    sudo ldconfig

RUN git clone https://github.com/redis/hiredis.git && \
    cd hiredis && \
    make && \
    make install

# if ENV invalid, use export
#export   CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/boost_1_60_0
#export   LIBRARY_PATH=$LIBRARY_PATH:/usr/local/boost_1_60_0/stage/lib

# This command compiles your app using GCC, adjust for your source code
RUN make

# This command runs your application, comment out this line to compile only
CMD ["./rpc_server_test"]

LABEL Name=networklibrpc Version=0.0.1