#include <stdio.h>
#include <stdlib.h>
#include <openssl/sha.h>

#define PASSLEN	4

#define PASS_FILE		"pass.key"
#define CEK_FILE		"cek.key"

/*
	ビルド方法
	gcc sha.c -lcrypto -o sha
 */

 
/*
 *	SHA256を取得する
 */
static void getSHA256hash(unsigned char *password, const int passLen, unsigned char* hashBuf)
{
	SHA256_CTX ctx256;

	SHA256_Init(&ctx256);
	SHA256_Update(&ctx256, password, passLen);
	SHA256_Final(hashBuf, &ctx256);

	/* ハッシュ値を出力 */
	for(int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
		printf("%02X",hashBuf[i]);
	}
	printf("\n");
}


int main(int argc, char *argv[])
{
	int stretch = 100;
	unsigned char	hashBuf[SHA256_DIGEST_LENGTH];
	unsigned char	passBuf[PASSLEN + 1];

	if (argc < 2) {
		printf("Usage: %s {stretch}\n", argv[0]);
		exit(-1);
	}
	stretch = atoi(argv[1]);
	printf("file=%s, stretch=%d\n", PASS_FILE, stretch);

	{
		FILE *fp;
		int size;

		fp = fopen(PASS_FILE, "rb" );
		if( fp == NULL ){
			printf( "%sファイルが開けない\n", PASS_FILE );
			exit(-1);
		}
		 
		size = fread(passBuf, 1, PASSLEN, fp);
		if (size < PASSLEN) {
			printf("パスワードの長さが%d文字に満たない (%d)\n", PASSLEN, size);
			fclose(fp);
			exit(-1);
		}
		fclose(fp);
	}

	getSHA256hash(passBuf, PASSLEN, hashBuf);
	for (int i = 0; i < stretch -1; i++) {
		printf("%04d: ", i);
		getSHA256hash(hashBuf, SHA256_DIGEST_LENGTH, hashBuf);
	}
	
	{
		FILE *fp;
		fp = fopen(CEK_FILE, "wb" );
		if( fp == NULL ){
			printf( "%sファイルが開けない\n", CEK_FILE );
			exit(-1);
		}

		/* ハッシュ値を出力 */
		for(int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
			fprintf(fp, "%02X", hashBuf[i]);
		}
		fclose(fp);
	}

	return 0;
}
