CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    echo "-- First container startup --"
    # 此处插入你要执行的命令或者脚本文件
    # 根据参数修改config.json
    # 再执行trojan -c config.json
    # T 服务类型
    # S 服务器地址
    # P 密码
    # SP Socks Port 端口
    
    if [ ! -d "/etc/trojan-go/" ];then
        mkdir /etc/trojan-go/
    else
        echo "文件夹已经存在,无需创建"
    fi
    if [[ $1 == 'c' ||$1 == 'C' || $1 == '' ]];then
        # 类型是c,或者直接回车，代表客户端类型
        if [ $# -lt 3 ]; then 
            echo 缺失参数，eg:./init.sh c your-trojan-server.com your-trojan-password
            exit 1
        fi
        if [ -z "$2" ]; then
            echo "请输入参数2，Trojan服务器地址后充实"
            exit 1
        fi
        if [ -z "$3" ]; then
            echo "请输入参数3，Trojan连接密码"
            exit 1
        fi
        if [[ $# -lt 3 || -z "$4" ]];then
            socksport=1080
        else
            socksport=${4}
        fi
        cat > "/etc/trojan-go/config.json" << EOF
{
    "run_type": "client",
    "local_addr": "0.0.0.0",
    "local_port": $socksport,
    "remote_addr": "$2",
    "remote_port": 443,
    "password": [
        "$3"
    ],
    "ssl": {
        "sni": "$2"
    },
    "mux": {
        "enabled": true
    },
    "router": {
        "enabled": true,
        "bypass": [
            "geoip:cn",
            "geoip:private",
            "geosite:cn",
            "geosite:private"
        ],
        "block": [
            "geosite:category-ads"
        ],
        "proxy": [
            "geosite:geolocation-!cn"
        ],
        "default_policy": "proxy",
        "geoip": "/etc/trojan-go/geoip.dat",
        "geosite": "/etc/trojan-go/geosite.dat"
    }
}
EOF
    else
        # 类型是c,或者直接回车，代表客户端类型
        cat > "/etc/trojan-go/config.json" << EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "$2",
    "remote_port": 80,
    "password": [
        "$3"
    ],
    "ssl": {
        "cert": "your_cert.crt",
        "key": "your_key.key",
        "sni": "your-domain-name.com"
    },
    "router": {
        "enabled": true,
        "block": [
            "geoip:private"
        ],
        "geoip": "/etc/trojan-go/geoip.dat",
        "geosite": "/etc/trojan-go/geosite.dat"
    }
}
EOF
    fi
    touch $CONTAINER_ALREADY_STARTED
    # /usr/local/bin/trojan-go-c -config /etc/trojan-go/config.json
else
    echo "-- Not first container startup --"
    # /usr/local/bin/trojan-go-c -config /etc/trojan-go/config.json
fi
