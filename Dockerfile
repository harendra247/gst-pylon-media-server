FROM ubuntu:18.04
LABEL maintainer=harendra247@hotmail.com

# docker container run --net=host --env DISPLAY=unix:0.0 --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -v /dev/:/dev/ -v /persistent/:/persistent/ -it harendra247/gstreamer:gst_latest /bin/bash

# docker build -t harendra247/gstreamer:gst_latest -f ./Dockerfile_gstreamer .

USER root

# Set TERM as xterm for readline
ENV TERM xterm
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/lib/cm:/usr/lib

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root/
#add-apt-repository universe
#add-apt-repository multiverse
RUN apt-get update && apt-get -y --no-install-recommends install \
    vim \
    cmake \
    wget \
    git \
    build-essential \
    autoconf \
    automake \
    autopoint \
    libtool \
    pkg-config

RUN apt-get -y --no-install-recommends install \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-pulseaudio
    #gstreamer1.0-gl \
    #gstreamer1.0-gtk3 \
    #gstreamer1.0-qt5 \

RUN apt-get -y --no-install-recommends install \
    gtk-doc-tools \
    libglib2.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    libgstreamer-plugins-bad1.0-dev

RUN wget --no-check-certificate -O pylon-5.2.0.13457-x86_64.tar.gz https://www.baslerweb.com/fp-1551786516/media/downloads/software/pylon_software/pylon-5.2.0.13457-x86_64.tar.gz && \
        tar -xzvf pylon-5.2.0.13457-x86_64.tar.gz && cd pylon-5.2.0.13457-x86_64 && \
        tar -C /opt -xzvf pylonSDK*.tar.gz && cd ../ && rm -rf pylon-5.2.0.13457*

ENV PYLON_ROOT=/opt/pylon5
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/lib/cm:/usr/lib:/opt/pylon5/lib64

RUN apt-get -y --no-install-recommends install --reinstall ca-certificates

RUN git clone -c http.sslverify=false https://github.com/GStreamer/gst-rtsp-server.git && cd gst-rtsp-server/ && \
        git checkout 1.8.3 && ./autogen.sh && ./configure && make && make install && cd examples && \
        gcc -o gst-rtsp-server-launch test-launch.c  `pkg-config --cflags --libs gstreamer-rtsp-server-1.0` && \
        cp gst-rtsp-server-launch /usr/local/bin/gst-rtsp-server-launch && cd ../../ && rm -rf gst-rtsp-server

RUN apt-get -y --no-install-recommends install liborc-0.4-0 libgstreamer-plugins-base1.0-dev liborc-0.4-dev

RUN git clone https://github.com/joshdoe/gst-plugins-vision.git && cd gst-plugins-vision && \
        mkdir build && cd build && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/opt/gst/plugins .. \
        && make && make install && cd ../../ && rm -rf gst-plugins-vision

ENV GST_PLUGIN_PATH=/opt/gst/plugins

RUN git clone https://github.com/MattsProjects/pylon_gstreamer.git && cd pylon_gstreamer/Samples/demopylongstreamer && \
    sed -i 's/camera.ResetCamera();$/\/\/camera.ResetCamera();/g' demopylongstreamer.cpp && sed -i 's/cin.get();$/\/\/cin.get();/g' CPipelineHelper.cpp \
    && make && cp ./demopylongstreamer /usr/local/bin/ && cd ../../../ && rm -rf pylon_gstreamer

# this is how the library can be used
# if [ ! -z "$IP_ADDR" ]; then
#     echo "Running the gst-rtsp-server"
#     pylon_streamer_running=true
#     /usr/local/bin/gst-rtsp-server-launch "( udpsrc port=554 ! application/x-rtp, media=video, clock-rate=90000, encoding-name=H264, payload=96 ! rtph264depay ! h264parse ! rtph264pay name=pay0 pt=96 )" &
#     gst_rtsp_server_pid=$!
#     #echo -ne '\n' | /usr/local/bin/demopylongstreamer -rescale 640 480 -h264stream $IP_ADDR &
#     /usr/local/bin/demopylongstreamer -rescale 640 480 -h264stream $IP_ADDR &
#     pylon_gstreamer_pid=$!
# fi


RUN ldconfig
