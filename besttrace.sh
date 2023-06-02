#!/bin/bash
URL="https://cdn.ipip.net/17mon/besttrace4linux.zip"
ARCH=$(uname -m)
FILE_NAME_SPACE="bestTrace"
list=('广州电信,14.215.116.1' '广州联通,157.148.98.30' '广州移动,157.148.98.30')

download_file() {
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
  
  
