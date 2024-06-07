#!/bin/bash

read -p "是否安装防火墙Firewalld? (y/n): " choice
if [[ $choice =~ ^[Yy]$ ]]; then
    # 安装 firewalld
    sudo apt update && sudo apt install firewalld -y
else
    echo "跳过安装防火墙 firewalld."
    exit 0
fi

# 停止 firewalld 服务
sudo systemctl stop firewalld

# 检查 public.xml 文件是否存在
if [ ! -f /etc/firewalld/zones/public.xml ]; then
    # 如果不存在，则创建并添加配置
    cat <<EOF | sudo tee /etc/firewalld/zones/public.xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <forward/>
</zone>
EOF
else
    # 如果存在，则检查是否存在 cockpit 配置项
    if ! grep -q '<service name="cockpit"/>' /etc/firewalld/zones/public.xml; then
        # 如果不存在，则添加 cockpit 配置项
        sudo sed -i '/<forward\/>/i \  <service name="cockpit"/>' /etc/firewalld/zones/public.xml
    fi
fi
