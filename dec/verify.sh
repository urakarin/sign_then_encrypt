#!/bin/bash

#
# 署名検証
#
# 事前に公開鍵の証明書を入手しておくこと(oreore.crt)

if [ $# -ne 2 ];then
	echo $0 " file signature"
	echo "引数は2つ必要です。" 1>&2
	exit 1
fi

file=$1
sig=$2

# 公開鍵証明書から公開鍵を取り出す
openssl x509 -in oreore.crt -pubkey -noout > public-key.pem

# 署名検証を行う
openssl dgst -sha256 -verify public-key.pem -signature $sig $file
