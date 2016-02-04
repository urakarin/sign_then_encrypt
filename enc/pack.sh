#!/bin/bash

#
#	圧縮は行わないので、事前にzip等で圧縮しておいてください。
#	また、1ファイルを想定しているので、事前に1ファイルに
#	まとめておいてください。
#	署名用に事前に秘密鍵が必要です。(*1)
#	private-key.pem を用意してください。
#	それを前提として、仮にファイル名がrnd.binとした場合、
#	次の手続きで、配布用ファイルが作成できます。
#
#	./pack.sh rnd.bin
#
#	これにより幾つかファイルが出来上がりますが、復号時に必要なものは
#	rnd.bin.encrypted	暗号化された配布用ファイル
#	pass.key			ユーザが解凍時に必要なパスワードファイル
#	の２つです。他は中間ファイルです。
#
#	中間ファイルの説明
#	rnd.bin.sig			秘密鍵による署名ファイル（バイナリ）
#	rnd.bin.tar			rnd.binとrnd.bin.sigをまとめたtarファイル（暗号化対象）
#	cek.key				pass.keyからストレッチされた暗号鍵
#	
#	(*1)
#	秘密鍵 の作成方法
# 	openssl genrsa 1024 > private-key.pem
#
#	秘密鍵から、自己証明書を作成する方法(Keychainに登録可能)
#	openssl req -new -x509 -out oreore.crt -key private-key.pem -days 3
#
#	自己証明書の内容を確認する方法
#	openssl x509 -text -noout -in oreore.crt
#
#	この自己証明書(oreore.crt)をユーザーに渡しておく必要がありまs。
#	かつユーザーはこれを信頼することで、検証が可能です。
#	(自己証明書がありかなしかは置いておくとして）
#
#	これは必須ではないですが、備考として。
#	公開鍵の作成方法（署名検証時に顧客側に存在している必要があります）
#	openssl rsa -in private-key.pem -pubout -out public-key.pem



if [ $# -ne 1 ];then
	echo $0 " file"
	echo "引数は1つ必要です。" 1>&2
	exit 1
fi

file=$1
sig=$file.sig
tar_file=$file.tar
encrypted=$file.encrypted

#
# 署名をつける
./dgst.sh $file $sig

#
# ひとまとめにする
#./make_tgz.sh $file $sig
tar cvf $tar_file $file $sig

# 
# パスワードを作成する
./gen_pass.sh

#
# パスワードをストレッチする
#	1000はストレッチ回数
#
./sha 1000

# 暗号化する
#
openssl aes-256-cbc -e -in $tar_file -out $encrypted -pass file:./cek.key
echo "encrypted $file done."

rm $tar_file
