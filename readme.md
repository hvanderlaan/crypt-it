# How to use

    $ ./crypt-it.sh genkey <keyname> <entropy>
    $ ./crypt-it.sh enc <filename> <public key>
    $ ./crypt-it.sh denc <filename> <password file> <private key>

After this you can send the following files
    - <file>.enc
    - <file>.sha256
    - password.txt.enc

# How does it work
`openssl rand -base64 2048 > password.txt` will create a random password that you and receiver do not know. This file is used to encrypt the file or message you are sending me. To secure the password this also is send encrypted with my public key. Only you have the private to it and only you can decrypt the encrypted file. After decrypting the password file you can decrypt the file or message that was encrypted with the random password.

# Is it secure
Yes, the only one who has the private key to the public key and that is you. So you're the only one that could decrypt the password. Even if you try to bruteforce the password you have to have some serious hardware and a lot of time. The password we randomly creates was 2048bit long and is with the current technologies unbreakable.
