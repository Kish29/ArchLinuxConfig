/*********************************************************
记录一下ArchLinux的配置以及安装ArchLinux过程需要注意的地方
逻辑上按照时间顺序来写，中间的一些安装可能会出错，请自行百度
*********************************************************/

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

## 安装i3wm
	以下为必须步骤
	pacman -S xorg-server xorg-xinit
	pacman -S i3-wm i3lock i3status
	pacman -S 能在X window下显示的自体 如：wqy-zenhei
	pacman -S xterm
	可选
	pacman -S xorg-xrandr


## 安装Monaco字体
	wget http://d.xiazaiziti.com/en_fonts/fonts/m/Monaco.ttf
	fc-cache -v生成自体
	然后用fc-list | grep -i monaco 找一下是不是正确生成了字体

## 修改xterm字体
	在用户目录下新建文件：.Xresources
	写入：xterm*faceName: Monaco:antialias=True:style=Regular
	加载配置：xrdb -load .Xresources
	中文自体配置: xterm*faceNameDoublesize: 中文字体名字(要和fc-list | grep -i名字相同，不然无法识别)

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

	然后copy到/usr/bin目录下
	cp cp /usr/bin/xcp
	cp mv /usr/bin/xcp
	然后在shell脚本中添加，-g参数显示详情
	alias xcp='xcp -g'
	alias xmv='xmv -g'
