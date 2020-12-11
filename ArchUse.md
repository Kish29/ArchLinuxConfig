/*********************************************************
记录一下ArchLinux的配置以及安装ArchLinux过程需要注意的地方
逻辑上按照时间顺序来写，中间的一些安装可能会出错，请自行百度
*********************************************************/

1->> Install nvidia driver
	pacman -S nvidia nvidia-settins
	reboot
	
	query nouveau is running:
	lsmod | grep nouveau
	if output message is null, indicates that your nvidia driver is running instead of nouveau;
	or query nvidia
	lsmod | grep nvidia
2->> Install nvidia switch tool
	pacman -S nvidia-prime <- seems it can not work in ArchLinux...

3->> Install sunpinyin (Chinese Input)
	pacman -S fcitx fcitx-im fcitx-configtool
	pacman -S fcitx-sunpinyin

	fcitx # to start fcitx
	
	fcitx-configtool add sunpinyin

	add 'exec --no-startup-id fcitx' in i3config file

	add in /etc/fish/config.fish or /etc/profile

	export GTK_IM_MODULE=fcitx
	export QT_IM_MODULE=fcitx
	export XMODIFIERS="@im=fcitx"
