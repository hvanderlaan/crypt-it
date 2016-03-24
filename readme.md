# How to use
Download the public key from https://www.haraldvdl.nl/keys/haraldvdlaan.pub and use the following commands to secure the file of message

    $ openssl rand -base64 2048 > password.txt
    $ sha256sum <file> > <file>.sha256
    $ openssl enc -aes256 -a -salt -in <file> -out <file>.enc -pass file:password.txt
    $ openssl smime -encrypt -binary -in password.txt -out password.txt.enc -aes256 haraldvdlaan.pub
    $ rm <file> password.txt

After this you can send me the following files
    - <file>.enc
    - <file>.sha256
    - password.txt.enc

# How does it work
`openssl rand -base64 2048 > password.txt` will create a random password that you and i do not know. This file is used to encrypt the file or message you are sending me. To secure the password this also is send encrypted with my public key. Only i have the private to it and only i can decrypt the encrypted file. After decrypting the password file i can decrypt the file or message that was encrypted with the random password.

# Is it secure
Yes, the only one who has the private key to my public key is my self. So i'm the only one that could decrypt the password. Even if you try to bruteforce the password you have to have some serious hardware and a lot of time. The password we randomly creates was 2048bit long and is with the current technologies unbreakable.
