#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
caddy_zip="/tmp/caddy.tar.gz"
caddy_download_link="https://caddyserver.com/download/linux/amd64?license=personal"

_download_caddy_file() {


	caddy_tmp="/tmp/install_caddy/"

	[[ -d $caddy_tmp ]] && rm -rf $caddy_tmp
	mkdir -p $caddy_tmp

  if !-f /usr/bin/apt; then
    if ! wget --no-check-certificate -O $caddy_zip $caddy_download_link; then
      echo -e "$red 下载 Caddy 失败！$none" && exit 1
    fi
  fi

	tar zxf $caddy_zip -C $caddy_tmp
	cp -f ${caddy_tmp}caddy /usr/local/bin/

	if [[ ! -f /usr/local/bin/caddy ]]; then
		echo -e "$red 安装 Caddy 出错！" && exit 1
	fi
}
_install_caddy_service() {
	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/caddy


  cp -f ${caddy_tmp}init/linux-systemd/caddy.service /lib/systemd/system/
  # sed -i "s/www-data/root/g" /lib/systemd/system/caddy.service
  sed -i "s/on-abnormal/always/" /lib/systemd/system/caddy.service
  systemctl enable caddy


	mkdir -p /etc/ssl/caddy

	if [ -z "$(grep www-data /etc/passwd)" ]; then
		useradd -M -s /usr/sbin/nologin www-data
	fi
	chown -R www-data.www-data /etc/ssl/caddy

	mkdir -p /etc/caddy/

}



# 笨笨的检测方法
if [[ -f /usr/bin/apt  ]] && [[ -f /bin/systemctl ]]; then
  _download_caddy_file
  _install_caddy_service
else

	echo -e " 
	哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi



