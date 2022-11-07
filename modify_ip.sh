#! /bin/bash
#  Description：初始化服务器的时候修改主机名和固定IP

NETNAME=`ip ro |awk 'NR==1 {print $5}'`
NETPATH="/etc/sysconfig/network-scripts/ifcfg-${NETNAME}"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DNS="114.114.114.114"

modify() {
    # 修改主机名
    read -p "请输入要修改的主机名: " NAME
    /usr/bin/hostnamectl set-hostname ${NAME}

    # 修改IP地址
    read -p "请输入要修改的IP地址: " IP
    sed -i '/ONBOOT/ s/no/yes/g' ${NETPATH}
    sed -i '/BOOTPROTO/ s/dhcp/none/g' ${NETPATH}
    echo -e "IPADDR=${IP}\nNETMASK=${NETMASK}\nGATEWAY=${GATEWAY}\nDNS1=${DNS}" >> ${NETPATH}
    clear; echo "------------------------查看IP地址配置-----------------------------"
    cat ${NETPATH}

    # 重启网卡
    read -p "如果确认无误，输入y表示立即重启网卡，输入任意键退出: " SURE
    S=`echo ${SURE} |tr 'A-Z' 'a-z'`
    if [ ${S} == 'y' ];then 
        echo "正在重启网络使修改的IP生效，请用新IP地址尝试登陆……"
        systemctl restart network
    else
        echo "还没有重启网络，修改的IP地址未生效，请手动重启使其生效"
    fi
}

modify
