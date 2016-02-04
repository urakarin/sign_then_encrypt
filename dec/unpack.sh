#!/bin/bash
#
#	次の手続きで、配布用ファイルを復元できます。
#
#	./unpack.sh rnd.bin.encrypted
#
#	これにより幾つかファイルが出来上がりますが、復号時に必要なものは
#	rnd.bin.encrypted	暗号化された配布用ファイル
#	pass.key			ユーザが解凍時に必要なパスワードファイル
#	の２つです。他は中間ファイルです。
#
#	中間ファイルの説明
#	cek.key				pass.keyからストレッチされた暗号鍵
#	rnd.bin.encrypted.decrypted.tar		復号化されたrnd.binとrnd.bin.sigをまとめたtarファイル（暗号化対象）
#	rnd.bin				tarによって解かれた配布用ファイル
#	rnd.bin.sig			検証用の署名ファイル（バイナリ）
#	public-key.pem		公開鍵証明書から抜き出された公開鍵
#
#	復元後、以下の手続きで署名検証を行う必要があります。	
#	署名検証にあたり、事前に公開鍵証明書が必要です。
#	oreore.crt			森精機公開鍵証明書
#
#	./veryfy.sh rnd.bin rnd.bin.sig
#	問題なければOKと表示されます。検証に失敗した場合はFailureと表示されます。
#	


if [ $# -ne 1 ];then
	echo $0 " file"
	echo "引数は1つ必要です。" 1>&2
	exit 1
fi

file=$1
decrypted=$file.decrypted.tar

#
# パスワードをストレッチする
#	1000はストレッチ回数
#
./sha 1000

# 復号化する
#
openssl aes-256-cbc -d -in $file -out $decrypted -pass file:./cek.key
echo "decrypted $file done."

#
# ばらす
tar xvf $decrypted
rm $decrypted

