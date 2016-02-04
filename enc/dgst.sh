#!/bin/bash

#
# 署名生成
#
# 事前にprivate-key.pem, public-key.pemの準備が必要

if [ $# -ne 2 ];then
	echo $0 " file sig"
	echo "引数は2つ必要です。" 1>&2
	exit 1
fi

file=$1
sig=$2

openssl dgst -sha256 -sign private-key.pem $file > $sig
