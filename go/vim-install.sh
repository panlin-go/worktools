#!/bin/bash

# mkdir vim vimrc
VIM=$(readlink -f ~/.vim)
VIMRC=$(readlink -f ~/.vimrc)
BUNDLE=$(readlink -f ~/.vim/bundle)
AUTOLOAD=$(readlink -f ~/.vim/autoload)
GOLANG="/usr/local/go"

function golang()
{
	tar xvzf ./go1.8.3.linux-amd64.tar.gz
	mv go $GOLANG

	echo -e "\nexport GOROOT=/usr/local/go\nexport PATH=$PATH:$GOROOT/bin\n\nexport GOPATH=/root/golang\nexport PATH=$PATH:$GOPATH/bin\n\nexport GOARCH=amd64\nexport GOOS=linux" >> /etc/profile
	source /etc/profile
}

function prepare() 
{
	if [ -d "$VIM" ]; then
		echo "$VIM is exit!"
	else
		mkdir $VIM
	fi

	if [ -f "$VIMRC" ]; then
		echo "$VIMRC is exit!"
	else
		touch $VIMRC
	fi

	if [ -d "$BUNDLE" ]; then
		echo "$BUNDLE is exit!"
	else
		mkdir $BUNDLE
	fi

	if [ -d "$AUTOLOAD" ]; then
		echo "$AUTOLOAD is exit!"
	else
		mkdir $AUTOLOAD
	fi

	# install vim-go
	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim  

	echo -e "set nocompatible              \" be iMproved, required\nfiletype off                  \" required\n\n\" set the runtime path to include Vundle and initialize\nset rtp+=~/.vim/bundle/Vundle.vim\ncall vundle#begin()\n\n\" let Vundle manage Vundle, required\nPlugin 'gmarik/Vundle.vim'\nPlugin 'fatih/vim-go'\n\n\" All of your Plugins must be added before the following line\ncall vundle#end()            \" required\nfiletype plugin indent on    \" required\n\n\" common\nlet g:go_version_warning = 0\n set number\n" > $VIMRC

	# run vim :PluginInstall
	echo "run vim :PluginInstall"
	echo "./vim-install.sh run"
}

function run() 
{
	# install pathogen
	git clone https://github.com/tpope/vim-pathogen.git
	mv ./vim-pathogen/autoload/ $VIM 
	rm -rf ./vim-pathogen/

	echo -e "\n\" pathogen\ncall pathogen#infect()\nsyntax on\nfiletype plugin indent on\n" >> $VIMRC

	# pathogen tarbar NERDTree gocode ctrlp 
	cd $BUNDLE
	git clone https://github.com/majutsushi/tagbar.git
	yum install -y ctags 
	echo -e "\n\" golist\nnmap <F5> :TagbarToggle<CR>\nautocmd VimEnter * nested :call tagbar#autoopen(1)\nlet g:tagbar_ctags_bin = '/usr/bin/ctags'\nlet g:tagbar_width = 40\n"  >> $VIMRC

	git clone http://github.com/scrooloose/nerdtree.git  
	echo -e "\n\" NERDTree\nmap <F6> :NERDTreeToggle<CR>\nautocmd VimEnter * NERDTree\nlet g:NERDTreeWinPos=\"left\"\nlet g:NERDTreeWinSize=25\nlet g:NERDTreeShowLineNumbers=1\nlet g:neocomplcache_enable_at_startup = 1\n"  >> $VIMRC 

	git clone https://github.com/Blackrush/vim-gocode.git
	echo -e "\n\" gocode\nimap <C-c> <C-x><C-o>\n"  >> $VIMRC  

	git clone https://github.com/kien/ctrlp.vim.git
	echo -e "\n\"ctrlp\nlet g:ctrlp_map = '<c-p>'\nlet g:ctrlp_cmd = 'CtrlP'\n"  >> $VIMRC


	# golang tools
	go get -v -u github.com/gpmgo/gopm

	gopm bin -d $GOPATH/bin github.com/gpmgo/gogetdoc
	gopm bin -d $GOPATH/bin github.com/gpmgo/guru
	gopm bin -d $GOPATH/bin github.com/gpmgo/glint
	gopm bin -d $GOPATH/bin github.com/gpmgo/errcheck
	gopm bin -d $GOPATH/bin github.com/gpmgo/impl
	gopm bin -d $GOPATH/bin github.com/gpmgo/goimports
	gopm bin -d $GOPATH/bin github.com/gpmgo/keyify
	gopm bin -d $GOPATH/bin github.com/gpmgo/gorename
	gopm bin -d $GOPATH/bin github.com/gpmgo/asmfmt
	gopm bin -d $GOPATH/bin github.com/gpmgo/gotags
	gopm bin -d $GOPATH/bin github.com/gpmgo/gocode
	gopm bin -d $GOPATH/bin github.com/gpmgo/godef
	gopm bin -d $GOPATH/bin github.com/gpmgo/oracle
}

function clean() 
{
	rm -rf "$VIMRC"  "$VIM"
	#rm -rf $GOPATH/bin/*
}

if [ $# != 1 ]; then 
       echo "script param is error!"
       echo "./vim-install.sh [prepare|run|clean]"	
       exit 1
fi

case $1 in
	"prepare") 
		prepare;
		;;
	
	"run")
		run;
		;;
	
	"clean")
		clean;
		;;

	*)
		echo "$1 is vaild!"
esac
