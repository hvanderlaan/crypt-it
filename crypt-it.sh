#!/bin/bash

# crypt-it.sh : this script can be used for secure communications and secure file sharing.
#
# author      : harald van der laan
# version     : v0.1
# date        : 2016/03/24
#
# requirements:
# - openssl
#
# change log  :
# - v0.1      : initial version

# functions
function genKeyPair() {
	# this function will create a new public / private key pair
	local name=${1}
	local bits=${2}

	# create a new private key with matching certificate (public key)
	openssl req -x509 -nodes -newkey rsa:${bits} -keyout ${name}.key -out ${name}.pub
	# for security reasons we are encrypting the private key with a password
	openssl enc -bf -in ${name}.key -out ${name}.key.enc
	# remove the clear text private key
	rm ${name}.key
}

function encryptFile() {
	# this function will encrypt a file for secure file sharing
	local fileName=${1}
	local pubKey=${2}
	
	# loop for checking if given files exists
	for f in ${fileName} ${pubFile}; do
		if [ ! -f ${f} ]; then
			echo "encryptFile: ${f} not found"
			exit 1
		fi
	done
	
	# create a random generated password of 2048 bits
	openssl rand -base64 2048 > temp.pass
	# create sha256 file for integrity checking
	sha256sum ${fileName} > ${fileName}.sha256
	# encrypt the file with the 2048 bits generated password
	openssl enc -aes256 -a -salt -in ${fileName} -out ${fileName}.enc -pass file:temp.pass
	# encrypt the 2048 bits generated password file with a public key
	openssl smime -encrypt -binary -in temp.pass -out ${fileName}.pass.enc -aes256 ${pubKey}
	# removing the 2048 bits generated password file and unsecured file 
	rm temp.pass ${fileName}
}

function decryptFile() {
	# this function will decrypt an encrypted file with the private key
	local fileName=${1}
	local passFile=${2}
	local keyFile=${3}
	
	# loop for checking if given files exists
	for f in ${filename} ${passFile} ${keyFile}; do
		if [ ! -f ${f} ]; then
			echo "decryptFile: ${f} not found"
			exit 1
		fi
	done
	
	# create 2 vabiables for filenames without .enc (works like basename)
	local output=$(rev <<< ${fileName} | cut -d. -f2- | rev)
	local privateKey=$(rev <<< ${keyFile} | cut -d. -f2- | rev)

	# decrypting the private key
	openssl enc -bf -d -in ${keyFile} -out ${privateKey}
	# decrypting the password file with the private key
	openssl smime -decrypt -binary -in ${passFile} -out temp.pass -aes256 -inkey ${privateKey}
	# decrypting the file with the 2048 random generated password
	openssl enc -aes256 -a -d -in ${fileName} -out ${output} -pass file:temp.pass
	
	# check if sha256 file is provided
	if [ ! -f ${output}.sha256 ]; then
		echo "warning: could not verify the integrity of ${output}"
	else
		sha256sum ${output} > ${output}.new.sha256
		if [ $(diff ${output}.sha256 ${output}.new.sha256 &> /dev/null; echo ${?}) -ne 0 ]; then
			echo "error: integrirty check failed, file is not decrypted"
		else
			echo "ok: intergity check passed, file is decrypted"
		fi
		rm ${output}.new.sha256
	fi
	
	# removing all insecure files
	rm temp.pass ${privateKey}
}

function usage() {
        echo "usage: ${0} <genkey|enc|denc> [options]"
        echo "--------------------------------------------------------"
        echo "     : ${0} genkey <name of key pair> <bits>"
        echo "     : ${0} genkey foo 2048"
        echo "--------------------------------------------------------"
        echo "     : ${0} enc <file to encrypt> <public key file>"
        echo "     : ${0} enc bar.bin foo.pub"
        echo "--------------------------------------------------------"
        echo "     : ${0} denc <file> <pass file> <private key>"
        echo "     : ${0} denc bar.bin.enc bar.bin.pass.enc foo.key"
        echo ""
        exit 1
}

case ${1} in
	"genkey") genKeyPair ${2} ${3} ;;
	"enc")    encryptFile ${2} ${3} ;;
	"denc")   decryptFile ${2} ${3} ${4} ;;
	*)        usage ;;
esac

exit 0
