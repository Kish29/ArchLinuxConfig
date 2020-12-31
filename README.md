# /*********************************************************
# 记录一下ArchLinux的配置以及安装ArchLinux过程需要注意的地方
# 逻辑上按照时间顺序来写，中间的一些安装可能会出错，请自行百度
# *********************************************************/

# 所有的配置文件在config_files中

## 安装arch linux:
	参考b站上的视频
	注：如果是用无限网卡，最后需要添加：
	```shell
	systemctl enable iwd
	systemctl restart iwd
	```

## 切换shell
	pacman -S fish
	chsh -s /bin/fish
	修改主题(需要浏览器)
	fish_config
 
	执行bash脚本
	执行前显示使用bash

## 安装i3wm
	以下为必须步骤
	pacman -S xorg-server xorg-xinit
	pacman -S i3-wm i3lock i3status
	pacman -S 能在X window下显示的自体 如：wqy-zenhei
	pacman -S xterm
	可选
	pacman -S xorg-xrandr
	然后修改xinitrc文件来启动i3
	vim /etc/X11/xinit/xinitrc
	注释掉上面几行，添加
	exec i3


## 安装Monaco字体
	wget http://d.xiazaiziti.com/en_fonts/fonts/m/Monaco.ttf
	fc-cache -v生成自体
	然后用fc-list | grep -i monaco 找一下是不是正确生成了字体

## 修改xterm字体和i3自体
	在用户目录下新建文件：.Xresources
	写入：xterm*faceName: Monaco:antialias=True:style=Regular
	加载配置：xrdb -load .Xresources
	中文自体配置: xterm*faceNameDoublesize: 中文字体名字(要和fc-list | grep -i名字相同，不然无法识别)

	vim ~/.config/i3/config
	font pango:Monaco Regular 8
	fonts you can use in $(fc-list)

## 安装显卡驱动
	pacman -S nvidia nvidia-settins
	reboot
	
	query nouveau is running:
	lsmod | grep nouveau
	if output message is null, indicates that your nvidia driver is running instead of nouveau;
	or query nvidia
	lsmod | grep nvidia

## 修改键位映射
	使用xmodmap -pke生成键位映射
	然后修改xmodmap生成的映射文件，对调想要修改的键位，并把它保存到用户主目录下
	另存文件名为.xmodmap
	然后重新映射:
	xmodmap .xmodmap

## 安装中文输入法
	pacman -S fcitx fcitx-im fcitx-configtool
	pacman -S fcitx-sunpinyin

	fcitx # to start fcitx
	
	fcitx-configtool add sunpinyin

	## 为了让i3启动时就启动输入法程序，在i3config文件中加入
	exec --no-startup-id fcitx

	## 在profile和shell脚本的启动文件中加入环境变量或者主目录下创建.xprofile
	/etc/fish/config.fish or /etc/profile

	export GTK_IM_MODULE=fcitx
	export QT_IM_MODULE=fcitx
	export XMODIFIERS="@im=fcitx"

## 安装advanced copy 和mv
	wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz
	tar xvJf coreutils-8.32.tar.xz
	
	下载补丁
	git clone https://github.com/Kish29/advcpmv.git

	cd coreutils-8.32/
	# 打补丁
	patch -p1 -i ../advanced-0.8.32.patch 
	# 编译，只能非root用户编译
	./configure
	make -j4

	为了区分原本的cp和新cp
	先对原来的cp和mv改名
	cd /usr/bin
	mv cp ocp
	mv mv omv

	然后copy到/usr/bin目录下
	ocp cp /usr/bin/cp
	ocp mv /usr/bin/mv
	然后在你使用的shell脚本(config.fish或者profile或者bashrc)中添加，-g参数显示详情
	alias cp='cp -g'
	alias mv='mv -g'

## 安装MaraDB
	pacman -S mariadb
	cd bin
	mariadb_install_db --user=mysql --basedir=/usr/mysql --datadir=/var/lib/mysql <- you can modify it
	systemctl start mysqld
	mysqladmin -u root passowrd 'passwd'
	mysql -u root -proot

## 使用docker
	expose remote connection:
	vim /lib/systemd/system/docker.service
	add -H tcp://0.0.0.0:2375 to 'ExecStart'
	systemctl restart docker
	pull image:
	docker pull mysql:latest
	docker pull openjdk:latest
	run:
	docker run -d -p local_port:container_port id
	stop:
	docker stop id
	interact:
	docker exec -it id bash(-i -> interact -t -> shell type)
	docker remove container
	docker rm id
	docker remove image:
	docker rmi image_id
	show all process:
	docker ps -a
	修改镜像路径
	在 /lib/systemd/system/docker.service的ExecSart后面加上
	--graph=/data/docker
	然后把原来在/var/lib/docker/下面的所有东西(包括镜像)移动到/data/docker目录下
	重启docker

## 安装vim的markdown插件 instant-markdown
	请看官方的安装文档说明
	你要安装npm包管理器，然后下载全局模块 instant-markdown-d
	如果是linux用户，还得确保装有xdg-utils、nodejs、curl
	修改npm的配置
	使用npm config edit在用户目录下生成.npmrc文件
	然后修改此文件即可生效
	如：修改cache路径（默认是~/.npm/）
	安装路径（默认是/usr/lib/node_modules）
	更换淘宝源:
	https://registry.npm.taobao.org/

## 使用iptable开放端口
	查看端口情况：
	iptables -nvL
	关闭所有端口
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	保存配置
	iptables-save > /etc/iptabless/iptabless.rules
	iptables-restore /etc/iptables/iptables.rules
	开启端口
	iptables -A INPUT -p tcp --dport 5555 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 5555 -j ACCEPT

	注意监听和开启端口的区别

	开放端口：使得远程目标可以访问本机的某个端口
	监听：某个服务软件在该端口运行并监听

## linux使用valgrind检查内存泄露以及使用coredump进行错误排查
	安装valgrind
	pacman -S valgrind

	生成coredump文件
	1. 首先查看是否开启coredump功能：
		ulimint -c 查看core file的限制大小，0代表0KB即没有开启
		ulimint -a 查看所有配置
	2. 修改core_pattern文件，在当前文件生成coredump文件
		echo "core_dump_%e_%p_%t"
	3. 生成coredump文件
		gcc/g++ -g ...
	4. 使用gdb查看出错位置
		where
	5. gdb 可执行文件ELF 你的coredump文件

## 使用peda来做gdb调试插件
	pacman -S peda
	在 /etc/gdb/gdbinit中添加
	source /usr/share/peda/peda.py
	修改peda的颜色：
	由于黑色背景和blue显示不清楚，将blue和purple的颜色号对调一下
	vim /usr/share/peda/lib/utils.py
	将blue改成35就行

## linux下自定义动态链接库要注意的问题
	如：自定义动态链接库sqrt
	需要：sqrt.h sqrt.cpp
	生成动态链接库：
	g++ -fPIC -shared -o libsqrt.so sqrt.cpp
	或者分步：
	g++ -fPIC -c sqrt.cpp
	g++ -shared -o libsqrt.so sqrt.o
	注意：格式必须是libXXX.so

	然后使用：
	在cpp文件中添加.h
	如： main.cpp
		#include "sqrt.h"
	编译：
		g++ -o main main.cpp -L .so文件目录 -lsqrt
	注意，使用的时候，-lsqrt就不再需要加lib前缀了，如-llibsqrt是会报错的

	然后修改运行库配置文件
		vim /etc/ld.so.conf
	添加你的运行时库的目录即可

