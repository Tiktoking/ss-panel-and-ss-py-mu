#!/bin/bash
#Check Root
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Separator_1="——————————————————————————————"
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
install_ss_panel_mod_v3(){
	yum -y remove httpd
	yum install -y unzip zip git
	num=$1
	if [ "${num}" != "1" ]; then
  	  wget -c --no-check-certificate https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/lnmp1.4.zip && unzip lnmp1.4.zip && rm -rf lnmp1.4.zip && cd lnmp1.4 && chmod +x install.sh && ./install.sh lnmp
	fi
	echo -e "请输入网站的目录(在/home/wwwroot/)"
	stty erase '^H' && read -p "(默认: ssr_panel):" webpath
	cd /home/wwwroot/$webpath
	git clone https://github.com/Tiktoking/ss-panel-v3-mod.git tmp -b new_master && mv tmp/.git . && rm -rf tmp && git reset --hard
	cp config/.config.php.example config/.config.php
	chattr -i .user.ini
	mv .user.ini public
	chown -R root:root *
	chmod -R 777 *
	chown -R www:www storage
	chattr +i public/.user.ini
	# wget -N -P  /usr/local/nginx/conf/ --no-check-certificate https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/nginx.conf
	# service nginx restart
	# IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	# sed -i "s#103.74.192.11#${IPAddress}#" /home/wwwroot/default/sql/sspanel.sql
	# mysql -uroot -proot -e"create database sspanel;" 
	# mysql -uroot -proot -e"use sspanel;" 
	# mysql -uroot -proot sspanel < /home/wwwroot/default/sql/sspanel.sql
	cd /home/wwwroot/$webpath
	php -n xcat initdownload
	php xcat initQQWry
	yum -y install vixie-cron crontabs
	rm -rf /var/spool/cron/root
	echo 'SHELL=/bin/bash' >> /var/spool/cron/root
	echo 'PATH=/sbin:/bin:/usr/sbin:/usr/bin' >> /var/spool/cron/root
	echo '*/20 * * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1' >> /var/spool/cron/root
	echo '30 22 * * * php /home/wwwroot/$webpath/xcat sendDiaryMail' >> /var/spool/cron/root
	echo '0 0 * * * php /home/wwwroot/$webpath/xcat dailyjob' >> /var/spool/cron/root
	echo '*/1 * * * * php /home/wwwroot/$webpath/xcat checkjob' >> /var/spool/cron/root
	/sbin/service crond restart
}
Libtest(){
	#自动选择下载节点
	GIT='raw.githubusercontent.com'
	LIB='download.libsodium.org'
	GIT_PING=`ping -c 1 -w 1 $GIT|grep time=|awk '{print $7}'|sed "s/time=//"`
	LIB_PING=`ping -c 1 -w 1 $LIB|grep time=|awk '{print $7}'|sed "s/time=//"`
	echo "$GIT_PING $GIT" > ping.pl
	echo "$LIB_PING $LIB" >> ping.pl
	libAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
	if [ "$libAddr" == "$GIT" ];then
		libAddr='https://raw.githubusercontent.com/Tiktoking/ss-panel-and-ss-py-mu/master/libsodium-1.0.13.tar.gz'
	else
		libAddr='https://download.libsodium.org/libsodium/releases/libsodium-1.0.13.tar.gz'
	fi
	rm -f ping.pl		
}
Get_Dist_Version()
{
    if [ -s /usr/bin/python3 ]; then
        Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1][0])'`
    elif [ -s /usr/bin/python2 ]; then
        Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1][0]'`
    fi
}
python_test(){
	#测速决定使用哪个源
	tsinghua='pypi.tuna.tsinghua.edu.cn'
	pypi='mirror-ord.pypi.io'
	doubanio='pypi.doubanio.com'
	pubyun='pypi.pubyun.com'	
	tsinghua_PING=`ping -c 1 -w 1 $tsinghua|grep time=|awk '{print $7}'|sed "s/time=//"`
	pypi_PING=`ping -c 1 -w 1 $pypi|grep time=|awk '{print $7}'|sed "s/time=//"`
	doubanio_PING=`ping -c 1 -w 1 $doubanio|grep time=|awk '{print $7}'|sed "s/time=//"`
	pubyun_PING=`ping -c 1 -w 1 $pubyun|grep time=|awk '{print $7}'|sed "s/time=//"`
	echo "$tsinghua_PING $tsinghua" > ping.pl
	echo "$pypi_PING $pypi" >> ping.pl
	echo "$doubanio_PING $doubanio" > ping.pl
	echo "$pubyun_PING $pubyun" >> ping.pl
	pyAddr=`sort -V ping.pl|sed -n '1p'|awk '{print $2}'`
	if [ "$pyAddr" == "$tsinghua" ]; then
		pyAddr='https://pypi.tuna.tsinghua.edu.cn/simple'
	elif [ "$pyAddr" == "$pypi" ]; then
		pyAddr='https://mirror-ord.pypi.io/simple'
	elif [ "$pyAddr" == "$doubanio" ]; then
		pyAddr='http://pypi.doubanio.com/simple --trusted-host pypi.doubanio.com'
	elif [ "$pyAddr" == "$pubyun_PING" ]; then
		pyAddr='http://pypi.pubyun.com/simple --trusted-host pypi.pubyun.com'
	fi
	rm -f ping.pl
}
install_centos_ssr(){
	cd /root
	Get_Dist_Version
	if [ $Version == "7" ]; then
		wget --no-check-certificate https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 
		rpm -ivh epel-release-latest-7.noarch.rpm	
	else
		wget --no-check-certificate https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
		rpm -ivh epel-release-latest-6.noarch.rpm
	fi
	rm -rf *.rpm
	yum -y update --exclude=kernel*	
	yum -y install git gcc python-setuptools lsof lrzsz python-devel libffi-devel openssl-devel iptables
	yum -y groupinstall "Development Tools" 
	#第一次yum安装 supervisor pip
	yum -y install supervisor python-pip
	supervisord
	#第二次pip supervisor是否安装成功
	if [ -z "`pip`" ]; then
    curl -O https://bootstrap.pypa.io/get-pip.py
		python get-pip.py 
		rm -rf *.py
	fi
	if [ -z "`ps aux|grep supervisord|grep python`" ]; then
    pip install supervisor
    supervisord
	fi
	#第三次检测pip supervisor是否安装成功
	if [ -z "`pip`" ]; then
		if [ -z "`easy_install`"]; then
    wget http://peak.telecommunity.com/dist/ez_setup.py
		python ez_setup.py
		fi		
		easy_install pip
	fi
	if [ -z "`ps aux|grep supervisord|grep python`" ]; then
    easy_install supervisor
    supervisord
	fi
	pip install --upgrade pip
	Libtest
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	git clone -b manyuser https://github.com/glzjin/shadowsocks.git "/root/shadowsocks"
	cd /root/shadowsocks
	chkconfig supervisord on
	#第一次安装
	python_test
	pip install -r requirements.txt -i $pyAddr	
	if [ $? -eq 0 ];then
     	echo "{$Info} 第一次依赖安装完成"
	else
     	echo "{$Error} 第一次依赖安装失败，进行第二次尝试······"
	fi
	#第二次检测是否安装成功
	if [ -z "`python -c 'import requests;print(requests)'`" ]; then
		pip install -r requirements.txt #用自带的源试试再装一遍
	fi
	if [ $? -eq 0 ];then
     	echo "{$Info} 第二次依赖安装完成"
	else
     	echo "{$Error} 第二次依赖安装失败，进行第三次尝试······"
	fi
	#第三次检测是否成功
	if [ -z "`python -c 'import requests;print(requests)'`" ]; then
		mkdir python && cd python
		git clone https://github.com/shazow/urllib3.git && cd urllib3
		python setup.py install && cd ..
		git clone https://github.com/nakagami/CyMySQL.git && cd CyMySQL
		python setup.py install && cd ..
		git clone https://github.com/requests/requests.git && cd requests
		python setup.py install && cd ..
		git clone https://github.com/pyca/pyopenssl.git && cd pyopenssl
		python setup.py install && cd ..
		git clone https://github.com/cedadev/ndg_httpsclient.git && cd ndg_httpsclient
		python setup.py install && cd ..
		git clone https://github.com/etingof/pyasn1.git && cd pyasn1
		python setup.py install && cd ..
		rm -rf python
	fi
	if [ $? -eq 0 ];then
     	echo "{$Info} 第三次依赖安装完成"
	else
     	echo "{$Error} 第三次依赖安装失败······"
		echo "{$Tip} 您可以通过升级Python和pip来尝试解决这个问题"
	fi
	cp apiconfig.py userapiconfig.py
	cp config.json user-config.json
}
install_ubuntu_ssr(){
	apt-get update -y
	apt-get install supervisor lsof -y
	apt-get install build-essential wget -y
	apt-get install iptables git -y
	wget --no-check-certificate $libAddr
	tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13
	./configure && make -j2 && make install
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	apt-get install python-pip git -y
	pip install cymysql
	cd /root
	git clone -b manyuser https://github.com/glzjin/shadowsocks.git "/root/shadowsocks"
	cd shadowsocks
	pip install -r requirements.txt
	chmod +x *.sh
	# 配置程序
	cp apiconfig.py userapiconfig.py
	cp config.json user-config.json
}
#check OS version
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	 fi
}
install_ssr_for_each(){
	check_sys
	if [[ ${release} = "centos" ]]; then
		install_centos_ssr
	else
		install_ubuntu_ssr
	fi
}
node_config(){
	while true; do
		read -p "Please input your domain(like:https://www.realwww.bid or http://114.114.114.114): " Userdomain
		read -p "Please input your muKey(like:mupass): " Usermukey
		read -p "Please input your Node_ID(like:1): " UserNODE_ID
		read -p "Apply the config?(y/n): " ifdone
		if [[ $ifdone = "n" ]]; then
			echo -e "${Info} Please reinput the config text\n"
		else
			break
		fi
	done
	install_ssr_for_each
	echo -e "${Info} Shadowsocks has been installed\n"
	IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	cd /root/shadowsocks
	echo -e "${Info} Modify userapiconfig.py...\n"
	sed -i "s#'zhaoj.in'#'v.qq.com'#" /root/shadowsocks/userapiconfig.py
	Userdomain=${Userdomain:-"http://${IPAddress}"}
	sed -i "s#https://zhaoj.in#${Userdomain}#" /root/shadowsocks/userapiconfig.py
	Usermukey=${Usermukey:-"mupass"}
	sed -i "s#glzjin#${Usermukey}#" /root/shadowsocks/userapiconfig.py
	UserNODE_ID=${UserNODE_ID:-"3"}
	sed -i '2d' /root/shadowsocks/userapiconfig.py
	sed -i "2a\NODE_ID = ${UserNODE_ID}" /root/shadowsocks/userapiconfig.py
	echo "IP_MD5_SALT = 'randomforsafety'" >> /root/shadowsocks/userapiconfig.py
}
install_node(){
	clear
	echo
	echo "################################################################"
	echo "# One click Install Shadowsocks-Python-Manyuser                #"
	echo "# Github: https://github.com/Tiktoking/ss-panel-and-ss-py-mu   #"
	echo "# Author: Tiktoking     Forked from mmmwhy                     #"
	echo "################################################################"
	echo
	#Check Root
	[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
	#check OS version
	check_sys
	# 系统配置优化
	optimizing_system
	#node_install and config
	node_config
	# 启用supervisord
	service supervisord stop
	#某些机器没有echo_supervisord_conf 
	wget -N -P  /etc/ --no-check-certificate  https://raw.githubusercontent.com/Tiktoking/ss-panel-and-ss-py-mu/master/supervisord.conf
	supervisord
	echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
	chmod +x /etc/rc.d/rc.local
	echo "##############################################################"
	echo "# 安装完成                                                   #"
	echo "# Github: https://github.com/Tiktoking/ss-panel-and-ss-py-mu #"
	echo "# Author: Tiktoking       Forked from mmmwhy                 #"
	echo "##############################################################"
	stty erase '^H' && read -p "需要重启VPS后，才能使配置生效，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} VPS 重启中..."
		reboot
	fi
}
# install_panel_and_node(){
# 	install_ss_panel_mod_v3 $1
# 	# 系统优化配置
# 	optimizing_system
# 	install_centos_ssr
# 	wget -N -P  /root/shadowsocks/ --no-check-certificate  https://raw.githubusercontent.com/mmmwhy/ss-panel-and-ss-py-mu/master/userapiconfig.py
# 	# 启用supervisord
# 	echo_supervisord_conf > /etc/supervisord.conf
#   sed -i '$a [program:ssr]\ncommand = python /root/shadowsocks/server.py\nuser = root\nautostart = true\nautorestart = true' /etc/supervisord.conf
# 	supervisord
# 	#iptables
# 	systemctl stop firewalld.service
# 	systemctl disable firewalld.service
# 	yum install iptables -y
# 	iptables -F
# 	iptables -X  
# 	iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
# 	iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
# 	iptables-save >/etc/sysconfig/iptables
# 	iptables-save >/etc/sysconfig/iptables
# 	echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
# 	echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
# 	chmod +x /etc/rc.d/rc.local
# 	echo "#############################################################"
# 	echo "# 安装完成，登录http://${IPAddress}看看吧~                   #"
# 	echo "# 用户名: 91vps 密码: 91vps                                  #"
# 	echo "# phpmyadmin：http://${IPAddress}:888  用户名密码均为：root  #"
# 	echo "# 安装完成，节点即将重启使配置生效                           #"
# 	echo "# Github: https://github.com/mmmwhy/ss-panel-and-ss-py-mu    #"
# 	echo "#############################################################"
# 	reboot now
# }

#优化系统配置
optimizing_system(){
	sed -i '/fs.file-max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
	sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
	sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
	sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
	sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
	echo "# max open files
fs.file-max = 1024000
# max read buffer
net.core.rmem_max = 67108864
# max write buffer
net.core.wmem_max = 67108864
# default read buffer
net.core.rmem_default = 65536
# default write buffer
net.core.wmem_default = 65536
# max processor input queue
net.core.netdev_max_backlog = 4096
# max backlog
net.core.somaxconn = 4096

# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# turn off fast timewait sockets recycling
net.ipv4.tcp_tw_recycle = 0
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# short keepalive time
net.ipv4.tcp_keepalive_time = 1200
# outbound port range
net.ipv4.ip_local_port_range = 10000 65000
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 4096
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 5000
# TCP receive buffer
net.ipv4.tcp_rmem = 4096 87380 67108864
# TCP write buffer
net.ipv4.tcp_wmem = 4096 65536 67108864
# turn on path MTU discovery
net.ipv4.tcp_mtu_probing = 1

# forward ipv4
net.ipv4.ip_forward = 1">>/etc/sysctl.conf
	sysctl -p
	echo "*               soft    nofile           512000
*               hard    nofile          1024000">/etc/security/limits.conf
	echo "session required pam_limits.so">>/etc/pam.d/common-session
	echo "ulimit -SHn 1024000">>/etc/profile
}


# 设置 防火墙规则
Add_iptables(){
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT
	ip6tables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ssr_port} -j ACCEPT
	ip6tables -I INPUT -m state --state NEW -m udp -p udp --dport ${ssr_port} -j ACCEPT
}
Save_iptables(){
	check_sys
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
	fi
}
Set_iptables(){
	check_sys
	if [[ ${release} == "centos" ]]; then
		service iptables save
		service ip6tables save
		chkconfig --level 2345 iptables on
		chkconfig --level 2345 ip6tables on
	else
		iptables-save > /etc/iptables.up.rules
		ip6tables-save > /etc/ip6tables.up.rules
		echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules\n/sbin/ip6tables-restore < /etc/ip6tables.up.rules' > /etc/network/if-pre-up.d/iptables
		chmod +x /etc/network/if-pre-up.d/iptables
	fi
}
manage_iptables(){
	while true
	do
	echo -e "请输入要设置的ShadowsocksR单端口的端口号"
	stty erase '^H' && read -p "(默认: 80):" ssr_port
	[[ -z "$ssr_port" ]] && ssr_port="80"
	expr ${ssr_port} + 0 &>/dev/null
		if [[ $? == 0 ]]; then
		if [[ ${ssr_port} -ge 1 ]] && [[ ${ssr_port} -le 65535 ]]; then
			echo && echo ${Separator_1} && echo -e "	端口 : ${Green_font_prefix}${ssr_port}${Font_color_suffix}" && echo ${Separator_1} && echo
			break
		else
			echo -e "${Error} 请输入正确的数字(1-65535)"
		fi
	else
		echo -e "${Error} 请输入正确的数字(1-65535)"
	fi
	done
	echo -e "${Info} 开始设置 iptables防火墙..."
	Set_iptables
	echo -e "${Info} 开始添加 iptables防火墙规则..."
	Add_iptables
	echo -e "${Info} 开始保存 iptables防火墙规则..."
	Save_iptables
}
#升级Python2.7.12和pip，解决pip安装依赖的错误
upgarde_python2.7.12(){
	#!/usr/bin/env bash
	#安装依赖
	yum install openssl openssl-devel zlib-devel gcc -y
	# apt-get install libssl-dev
	# apt-get install openssl openssl-devel
	# 下载源码
	wget http://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
	tar -zxvf Python-2.7.12.tgz
	cd Python-2.7.12
	mkdir /usr/local/python2.7.12
	# 开启zlib编译选项
	# sed -i '467c zlib zlibmodule.c -I$(prefix)/include -L$(exec_prefix)/lib -lz' Module/Setup
	sed '467s/^#//g' Module/Setup

	./configure --prefix=/usr/local/python2.7.12 
	make
	make install
	if [ $? -eq 0 ];then
	     echo "{$Info} Python2.7.12升级完成"
	else
	     echo "{$Info} Python2.7.12升级失败，查看报错信息手动安装"
	fi
	cd
	mv /usr/bin/python /usr/bin/python2.6.6
	ln -s /usr/local/python2.7.12/bin/python2.7 /usr/bin/python

	sed -i '1s/python/python2.6/g' /usr/bin/yum
	wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	if [ $? -eq 0 ];then
	     echo "pip升级完成"
	else
	     echo "pip安装失败，查看报错信息手动安装"
	fi
	rm -rf /usr/bin/pip
	ln -s /usr/local/python2.7.12/bin/pip2.7 /usr/bin/pip
}
start_menu(){
	clear
	echo && echo -e " ssrpanel魔改前后端一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
	  -- Tiktoking | realwww --
	 ${Separator_1}
	 ${Green_font_prefix}1.${Font_color_suffix} SS-V3_mod_panel and node One click Install----未完成
	 ${Green_font_prefix}2.${Font_color_suffix} SS-node One click Install
	 ${Green_font_prefix}3.${Font_color_suffix} Apply Iptables Rules
	 ${Green_font_prefix}4.${Font_color_suffix} Upgarde_python2.7.12 and pip
	 ${Green_font_prefix}5.${Font_color_suffix} 退出脚本
	 ${Separator_1} " && echo
	stty erase '^H' && read -p " 请输入数字 [1-5]:" num
		case "$num" in
		1)
		install_ss_panel_mod_v3
		;;
		2)
		install_node
		;;
		3)
		manage_iptables
		;;
		4)
		upgarde_python2.7.12
		;;
		5)
		exit 1
		;;
		*)
		echo "请输入正确数字 [1-5]"
		;;
	esac
}

start_menu

