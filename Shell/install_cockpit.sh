#!/bin/bash

# 启用向后移植存储库
echo "deb http://deb.debian.org/debian $(. /etc/os-release && echo $VERSION_CODENAME)-backports main" > /etc/apt/sources.list.d/backports.list
# 配置45Drives Repo安装脚本（用于安装Navigator、File Sharing、Identities组件）
curl -sSL https://repo.45drives.com/setup | bash
apt update

# 安装Cockpit及其附属组件（Navigator、File Sharing、Identities组件）
apt install -y -t $(. /etc/os-release && echo $VERSION_CODENAME)-backports cockpit cockpit-pcp cockpit-machines
apt install -y cockpit-navigator cockpit-file-sharing cockpit-identities

# 配置首页展示信息
tee /etc/motd > /dev/null <<EOF
我们信任您已经从系统管理员那里了解了日常注意事项。总结起来无外乎这三点：
1、尊重别人的隐私。
2、输入前要先考虑(后果和风险)。
3、权力越大，责任越大。
EOF

# 安装Tuned系统调优工具
apt install tuned -y

# 检查/etc/cockpit/issue.cockpit配置文件是否存在，不存在则创建
if [ ! -f "/etc/cockpit/issue.cockpit" ]; then
    echo "基于Debian搭建HomeNAS！" > /etc/cockpit/issue.cockpit
fi

# 设置Cockpit接管网络配置（网络管理工具由network改为NetworkManager）
setup_network_configuration() {
    local interfaces_file="/etc/network/interfaces"
    
    if [ -f "$interfaces_file" ]; then
        # 注释掉未注释的行
        sed -i '/^[^#].*/ s/^/#/' "$interfaces_file"
    else
        echo "文件 '$interfaces_file' 不存在，跳过操作。"
    fi
}
# 重启Network Manager服务
restart_network_manager() {
    systemctl restart NetworkManager && echo "已重启 Network Manager 服务。"
}
# 执行主程序
setup_network_configuration
restart_network_manager

# 重启cockpit服务
systemctl try-restart cockpit
