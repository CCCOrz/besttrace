#!/bin/bash
sleep 1
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"
WHITLE="\033[37m"
MAGENTA="\033[35m"
CYAN="\033[36m"
BLUE="\033[34m"
BOLD="\033[01m"

error() {
    echo -e "$RED$BOLD$1$PLAIN"
}

success() {
    echo -e "$GREEN$BOLD$1$PLAIN"
}

warning() {
    echo -e "$YELLOW$BOLD$1$PLAIN"
}

info() {
    echo -e "$PLAIN$BOLD$1$PLAIN"
}

REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora")
PACKAGE_UPDATE=("apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "yum -y install")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove" "yum -y remove")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove")

[[ $EUID -ne 0 ]] && error "请切换至ROOT用户" && exit 1

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

for i in "${CMD[@]}"; do
    SYS="$i"
    if [[ -n $SYS ]]; then
        break
    fi
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}"
        if [[ -n $SYSTEM ]]; then
            break
        fi
    fi
done

[[ -z $SYSTEM ]] && error "操作系统类型不支持" && exit 1

brefore_install() {
    info "更新并安装系统所需软件"
    if [[ ! $SYSTEM == "CentOS" ]]; then
        ${PACKAGE_UPDATE[int]}
    fi
    ${PACKAGE_INSTALL[int]} curl wget sudo socat openssl unzip
    if [[ $SYSTEM == "CentOS" ]]; then
        ${PACKAGE_INSTALL[int]} cronie
        systemctl start crond
        systemctl enable crond
    else
        ${PACKAGE_INSTALL[int]} cron
        systemctl start cron
        systemctl enable cron
    fi
}

#######################################################################

URL="https://cdn.ipip.net/17mon/besttrace4linux.zip"
ARCH=$(uname -m)
FILE_NAME_SPACE="bestTrace"
list=('广州电信,14.215.116.1' '广州联通,157.148.98.30' '广州移动,157.148.98.30')
download_file() {
    brefore_install
    wget -c -O bestTrace.zip $URL
    unzip -o bestTrace.zip -d $FILE_NAME_SPACE
    rm bestTrace.zip
    cd $FILE_NAME_SPACE
    if [ "${ARCH}" == "i686" ]; then
        cp besttrace32 app
    else
        cp besttrace app
    fi
    chmod +x app
}

split() {
    echo "$(printf '=%.0s' {1..100})"
}

run() {
    for item in ${list[@]}
    do
        array=(${item//,/ })
        echo "${array[0]} ${array[1]}"
        ./app -q 1 ${array[1]}
        split
    done
}

download_file
clear
run
  
  
