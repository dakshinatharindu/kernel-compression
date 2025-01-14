
compress_app() {
    echo "Compressing the application"
    echo -n "orig_size," > run.log && ls -l build/zephyr/zephyr.elf | cut -d " " -f5 >> run.log

    case $compress_algo in
        "lzw")
            echo "Compressing using LZW"
            echo -n "comp_time," >> run.log && { time compress -f build/zephyr/zephyr.elf; } 2>> run.log
            mv build/zephyr/zephyr.elf.Z build/zephyr/zephyr.comp
            ;;
        "lzma2")
            echo "Compressing using LZMA2"
            echo -n "comp_time," >> run.log && { time xz build/zephyr/zephyr.elf; } 2>> run.log
            mv build/zephyr/zephyr.elf.xz build/zephyr/zephyr.comp
            ;;
        *)
            echo "Invalid compression algorithm"
            ;;
    esac

    echo -n "comp_size," >> run.log && ls -l build/zephyr/zephyr.comp | cut -d " " -f5 >> run.log
}

decompress_app() {
    echo "Decompressing the application"
    

    case $compress_algo in
        "lzw")
            echo "Decompressing using LZW"
            mv build/zephyr/zephyr.dec build/zephyr/zephyr.elf.Z
            echo -n "decompress_time," >> run.log && { time compress -d build/zephyr/zephyr.elf.Z; } 2>> run.log
            ;;
        "lzma2")
            echo "Decompressing using LZMA2"
            mv build/zephyr/zephyr.dec build/zephyr/zephyr.elf.xz
            echo -n "decompress_time," >> run.log && { time unxz build/zephyr/zephyr.elf.xz; } 2>> run.log
            ;;
        *)
            echo "Invalid compression algorithm"
            ;;
    esac

    
}

encrypt_app() {
    echo "Encrypting the application"
    echo -n "encrypt_time," >> run.log
    case $enc_algo in
        "aes_128_cbc")
            echo "Encrypting using AES 128"
            openssl rand -out iv.bin 16
            { time (openssl enc -aes-128-cbc -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        "aes_256_cbc")
            echo "Encrypting using AES 256"
            openssl rand -out iv.bin 16
            { time (openssl enc -aes-256-cbc -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        "aes_128_ctr")
            echo "Encrypting using AES 128 CTR"
            openssl rand -out iv.bin 16
            { time (openssl enc -aes-128-ctr -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        "aes_256_ctr")
            echo "Encrypting using AES 256 CTR"
            openssl rand -out iv.bin 16
            { time (openssl enc -aes-256-ctr -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        *)
            echo "Invalid encryption algorithm"
            ;;
    esac
}

decrypt_app() {
    echo "Decrypting the application"
    echo -n "decrypt_time," >> run.log
    case $enc_algo in
        "aes_128_cbc")
            echo "Decrypting using AES 128"
            { time (openssl enc -aes-128-cbc -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        "aes_256_cbc")
            echo "Decrypting using AES 256"
            { time (openssl enc -aes-256-cbc -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        "aes_128_ctr")
            echo "Decrypting using AES 128 CTR"
            { time (openssl enc -aes-128-ctr -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        "aes_256_ctr")
            echo "Decrypting using AES 256 CTR"
            { time (openssl enc -aes-256-ctr -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin) 2>/dev/null); } 2>> run.log
            ;;
        *)
            echo "Invalid encryption algorithm"
            ;;
    esac

}

sign_app() {
    echo "Signing the application"
    case $auth_algo in
        "rsa_3k")
            echo "Signing using RSA 3k"
            echo -n "sign_time," >> run.log && { time openssl dgst -sha256 -sign utils/private_key_3k.pem  -out output/app.sig output/app.enc; } 2>> run.log
            ;;
        "rsa_4k")
            echo "Signing using RSA 4k"
            echo -n "sign_time," >> run.log && { time openssl dgst -sha256 -sign utils/private_key_4k.pem -out output/app.sig output/app.enc; } 2>> run.log
            ;;
        "ecdsa_192")
            echo "Signing using ECDSA"
            echo -n "sign_time," >> run.log && { time openssl dgst -sha256 -sign utils/private_key_ecdsa_192.pem  -out output/app.sig output/app.enc; } 2>> run.log
            ;;
        "ecdsa_384")
            echo "Signing using ECDSA"
            echo -n "sign_time," >> run.log && { time openssl dgst -sha256 -sign utils/private_key_ecdsa_384.pem  -out output/app.sig output/app.enc; } 2>> run.log
            ;;
        *)
            echo "Invalid authentication algorithm"
            ;;
    esac
    # openssl dgst -sha256 -sign utils/private.pem -passin pass:dakshina -out output/app.sig output/app.enc
    # openssl base64 -in output/app.sig -out output/app.sig.b64
}

verify_app() {
    echo "Verifying the application"

    case $auth_algo in
        "rsa_3k")
            echo -n "verify_time," >> run.log && { time openssl dgst -sha256 -verify utils/public_key_3k.pem -signature output/app.sig output/app.enc; } 2>> run.log
            ;;
        "rsa_4k")
            echo -n "verify_time," >> run.log && { time openssl dgst -sha256 -verify utils/public_key_4k.pem -signature output/app.sig output/app.enc; } 2>> run.log
            ;;
        "ecdsa_192")
            echo -n "verify_time," >> run.log && { time openssl dgst -sha256 -verify utils/public_key_ecdsa_192.pem -signature output/app.sig output/app.enc; } 2>> run.log
            ;;
        "ecdsa_384")
            echo -n "verify_time," >> run.log && { time openssl dgst -sha256 -verify utils/public_key_ecdsa_384.pem -signature output/app.sig output/app.enc; } 2>> run.log
            ;;
        *)
            echo "Invalid authentication algorithm"
            ;;
    esac
}

kernel=$2
app=$3
enc_algo=$4
compress_algo=$5
auth_algo=$6

TIMEFORMAT='%3R'

if [ -z "$1" ]; then
    echo "No argument supplied"
else
    if [ "$1" = "b" ]; then
        echo "Building the application"
        cd zephyr
        west build --pristine -b $kernel ../applications/$app -d ../build/
        cd ..
        
        compress_app
        encrypt_app
        sign_app

        verify_app
        decrypt_app
        decompress_app
    elif [ "$1" = "r" ]; then
        echo "Running the application"
        cd zephyr
        west build -t run  -d ../build/
        cd ..
    else
        echo "Invalid argument"
    fi
fi