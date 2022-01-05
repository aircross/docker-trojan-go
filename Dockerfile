FROM alpine
WORKDIR /
# https://api.github.com/repos/aircross/docker-trojan-go/releases/latest
RUN apk add --no-cache tzdata ca-certificates &&\
    mkdir /trojan-go &&\
    cd /trojan-go &&\
	VER=$(curl -s https://api.github.com/repos/aircross/docker-trojan-go/releases/latest | grep tag_name | cut -d '"' -f 4) && \
	# VER_NUM=bash ${VER:1} && \
	VER_NUM=$(echo $VER|cut -b 2-) && \
	echo VER_NUM && \
	URL=$(curl -s https://api.github.com/repos/aircross/docker-trojan-go/releases/tags/${VER} | jq .assets[0].browser_download_url | tr -d \") && \
    URL=https://github.com/aircross/docker-trojan-go/releases/download/$VER/trojan-go-linux-amd64.zip && \
    wget --no-check-certificate $URL && \
    unzip trojan-go-linux-amd64.zip && \
    wget https://github.com/aircross/docker-trojan-go/raw/release/init.sh -O init.sh && \
    chmod +x init.sh && \
    

# ENTRYPOINT ["/usr/local/bin/docker-trojan-go", "-config"]
# CMD ["/etc/trojan-go/config.json"]
# T 服务类型
# S 服务器地址
# P 密码
# SP Socks Port 端口
ENTRYPOINT /trojan-go/init.sh $T $S $P $SP