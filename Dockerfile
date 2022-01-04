FROM golang:alpine AS builder
WORKDIR /
ARG REF
RUN apk add git make
RUN git clone https://github.com/aircross/docker-trojan-go.git
RUN if [[ -z "${REF}" ]]; then \
        echo "No specific commit provided, use the latest one." \
    ;else \
        echo "Use commit ${REF}" &&\
        cd docker-trojan-go &&\
        git checkout ${REF} \
    ;fi
RUN cd docker-trojan-go &&\
    make &&\
    wget https://github.com/v2fly/domain-list-community/raw/release/dlc.dat -O build/geosite.dat &&\
    wget https://github.com/v2fly/geoip/raw/release/geoip.dat -O build/geoip.dat &&\
    wget https://github.com/v2fly/geoip/raw/release/geoip-only-cn-private.dat -O build/geoip-only-cn-private.dat

FROM alpine
WORKDIR /
RUN apk add --no-cache tzdata ca-certificates
COPY --from=builder /docker-trojan-go/build /usr/local/bin/
COPY --from=builder /docker-trojan-go/example/server.json /etc/trojan-go/server.json
COPY --from=builder /docker-trojan-go/example/client.json /etc/trojan-go/client.json
COPY --from=builder /docker-trojan-go/build/geosite.dat /etc/trojan-go/geosite.dat
COPY --from=builder /docker-trojan-go/build/geoip.dat /etc/trojan-go/geoip.dat
COPY --from=builder /docker-trojan-go/build/geoip-only-cn-private.dat /etc/trojan-go/geoip-only-cn-private.dat
COPY --from=builder /docker-trojan-go/init.sh /etc/trojan-go/init.sh

# ENTRYPOINT ["/usr/local/bin/docker-trojan-go", "-config"]
# CMD ["/etc/trojan-go/config.json"]
# T 服务类型
# S 服务器地址
# P 密码
# SP Socks Port 端口
ENTRYPOINT /bin/bash /init.sh $T $S $P $SP