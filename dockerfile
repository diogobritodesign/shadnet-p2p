FROM debian:trixie AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git cmake ninja-build build-essential \
    qt6-base-dev qt6-httpserver-dev qt6-websockets-dev libqt6sql6-sqlite \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --recursive https://github.com/Wozzardman/shadnet-p2p.git /src
WORKDIR /src
RUN cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --parallel
RUN mkdir -p /opt/shadnet && cp build/shadnet build/worlds.cfg build/scoreboards.cfg /opt/shadnet/

FROM debian:trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
    libqt6core6t64 libqt6network6 libqt6sql6 libqt6sql6-sqlite \
    libqt6httpserver6 libqt6websockets6 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /opt/shadnet /opt/shadnet
WORKDIR /opt/shadnet
EXPOSE 31313/tcp 31314/udp 31315/tcp
CMD ["./shadnet"]
