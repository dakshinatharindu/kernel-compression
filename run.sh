
compress_app() {
    echo "Compressing the application"
    
    sed -i "1s/$/,$(ls -l build/zephyr/zephyr.elf | cut -d " " -f5)/" run.log

    case $compress_algo in
        "lzw")
            echo "Compressing using LZW"
            start=$(date +%s.%N)
            compress -f build/zephyr/zephyr.elf
            end=$(date +%s.%N)
            mv build/zephyr/zephyr.elf.Z build/zephyr/zephyr.comp
            ;;
        "lzma2")
            echo "Compressing using LZMA2"
            start=$(date +%s.%N)
            xz build/zephyr/zephyr.elf
            end=$(date +%s.%N)
            mv build/zephyr/zephyr.elf.xz build/zephyr/zephyr.comp
            ;;
        *)
            echo "Invalid compression algorithm"
            ;;
    esac

    duration=$(echo "$end - $start" | bc)
    sed -i "2s/$/,$duration/" run.log

    sed -i "3s/$/,$(ls -l build/zephyr/zephyr.comp | cut -d " " -f5)/" run.log
}

decompress_app() {
    echo "Decompressing the application"

    case $compress_algo in
        "lzw")
            echo "Decompressing using LZW"
            mv build/zephyr/zephyr.comp build/zephyr/zephyr.elf.Z
            start=$(date +%s.%N)
            compress -d build/zephyr/zephyr.elf.Z
            end=$(date +%s.%N)
            ;;
        "lzma2")
            echo "Decompressing using LZMA2"
            mv build/zephyr/zephyr.comp build/zephyr/zephyr.elf.xz
            start=$(date +%s.%N)
            unxz build/zephyr/zephyr.elf.xz
            end=$(date +%s.%N)
            ;;
        *)
            echo "Invalid compression algorithm"
            ;;
    esac
    duration=$(echo "$end - $start" | bc)
    sed -i "8s/$/,$duration/" run.log
    
}

encrypt_app() {
    echo "Encrypting the application"
    
    case $enc_algo in
        "aes_128_cbc")
            echo "Encrypting using AES 128"
            openssl rand -out iv.bin 16
            start=$(date +%s.%N)
            openssl enc -aes-128-cbc -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "aes_256_cbc")
            echo "Encrypting using AES 256"
            openssl rand -out iv.bin 16
            start=$(date +%s.%N)
            openssl enc -aes-256-cbc -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "aes_128_ctr")
            echo "Encrypting using AES 128 CTR"
            openssl rand -out iv.bin 16
            start=$(date +%s.%N)
            openssl enc -aes-128-ctr -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "aes_256_ctr")
            echo "Encrypting using AES 256 CTR"
            openssl rand -out iv.bin 16
            start=$(date +%s.%N)
            openssl enc -aes-256-ctr -in build/zephyr/zephyr.comp -out output/app.enc -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "chacha20")
            echo "Encrypting using ChaCha20"
            start=$(date +%s.%N)
            ./chacha20 build/zephyr/zephyr.comp output/app.enc
            end=$(date +%s.%N)
            ;;
        *)
            echo "Invalid encryption algorithm"
            ;;
    esac
    duration=$(echo "$end - $start" | bc)
    sed -i "4s/$/,$duration/" run.log
}

decrypt_app() {
    echo "Decrypting the application"

    case $enc_algo in
        "aes_128_cbc")
            echo "Decrypting using AES 128"
            start=$(date +%s.%N)
            openssl enc -aes-128-cbc -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "aes_256_cbc")
            echo "Decrypting using AES 256"
            start=$(date +%s.%N)
            openssl enc -aes-256-cbc -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "aes_128_ctr")
            echo "Decrypting using AES 128 CTR"
            start=$(date +%s.%N)
            openssl enc -aes-128-ctr -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes128.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "aes_256_ctr")
            echo "Decrypting using AES 256 CTR"
            start=$(date +%s.%N)
            openssl enc -aes-256-ctr -d -in output/app.enc -out build/zephyr/zephyr.dec -kfile utils/aes256.bin -iv $(xxd -p -c 32 iv.bin)
            end=$(date +%s.%N)
            ;;
        "chacha20")
            echo "Decrypting using ChaCha20"
            start=$(date +%s.%N)
            ./chacha20 output/app.enc build/zephyr/zephyr.dec
            end=$(date +%s.%N)
            ;;
        *)
            echo "Invalid encryption algorithm"
            ;;
    esac
    duration=$(echo "$end - $start" | bc)
    sed -i "7s/$/,$duration/" run.log
    # rm iv.bin
}

sign_app() {
    echo "Signing the application"
    case $auth_algo in
        "rsa_3k")
            echo "Signing using RSA 3k"
            start=$(date +%s.%N)
            openssl dgst -sha256 -sign utils/private_key_3k.pem  -out output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "rsa_4k")
            echo "Signing using RSA 4k"
            start=$(date +%s.%N)
            openssl dgst -sha256 -sign utils/private_key_4k.pem -out output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "ecdsa_192")
            echo "Signing using ECDSA"
            start=$(date +%s.%N)
            openssl dgst -sha256 -sign utils/private_key_ecdsa_192.pem -out output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "ecdsa_384")
            echo "Signing using ECDSA"
            start=$(date +%s.%N)
            openssl dgst -sha256 -sign utils/private_key_ecdsa_384.pem -out output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "dilithium")
            echo "Signing using Dilithium"
            start=$(date +%s.%N)
            $QSO dgst -sha256 -sign utils/dilithium_private.pem -out output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "falcon")
            echo "Signing using Falcon"
            start=$(date +%s.%N)
            $QSO dgst -sha256 -sign utils/falcon_private.pem -out output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        *)
            echo "Invalid authentication algorithm"
            ;;
    esac

    duration=$(echo "$end - $start" | bc)
    sed -i "5s/$/,$duration/" run.log
    # openssl dgst -sha256 -sign utils/private.pem -passin pass:dakshina -out output/app.sig output/app.enc
    # openssl base64 -in output/app.sig -out output/app.sig.b64
}

verify_app() {
    echo "Verifying the application"

    case $auth_algo in
        "rsa_3k")
            start=$(date +%s.%N)
            openssl dgst -sha256 -verify utils/public_key_3k.pem -signature output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "rsa_4k")
            start=$(date +%s.%N)
            openssl dgst -sha256 -verify utils/public_key_4k.pem -signature output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "ecdsa_192")
            start=$(date +%s.%N)
            openssl dgst -sha256 -verify utils/public_key_ecdsa_192.pem -signature output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "ecdsa_384")
            start=$(date +%s.%N)
            openssl dgst -sha256 -verify utils/public_key_ecdsa_384.pem -signature output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "dilithium")
            start=$(date +%s.%N)
            $QSO dgst -sha256 -verify utils/dilithium_public.pem -signature output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        "falcon")
            start=$(date +%s.%N)
            $QSO dgst -sha256 -verify utils/falcon_public.pem -signature output/app.sig output/app.enc
            end=$(date +%s.%N)
            ;;
        *)
            echo "Invalid authentication algorithm"
            ;;
    esac

    duration=$(echo "$end - $start" | bc)
    sed -i "6s/$/,$duration/" run.log
}

kernel=$2
app=$3
enc_algo=$4
compress_algo=$5
auth_algo=$6

QSO=/home/dakshina/Projects/UFL/openssl/apps/openssl

if [ -z "$1" ]; then
    echo "No argument supplied"
else
    if [ "$1" = "b" ]; then
        # echo "Building the application"
        # cd zephyr
        # west build --pristine -b $kernel $app -d ../build/
        # cd ..

        if [ -f build1/zephyr/zephyr.elf ]; then
            cp -r build1 build
            
            rm run.log
            printf "orig_size\n" >> run.log
            printf "comp_time\n" >> run.log
            printf "comp_size\n" >> run.log
            printf "encrypt_time\n" >> run.log
            printf "sign_time\n" >> run.log
            printf "verify_time\n" >> run.log
            printf "decrypt_time\n" >> run.log
            printf "decompress_time\n" >> run.log


            for ((i=0; i<20; i++))
            do
                compress_app
                encrypt_app
                sign_app

                verify_app
                decrypt_app
                decompress_app
            done
            rm -rf build
        fi
    elif [ "$1" = "r" ]; then
        echo "Running the application"
        cd zephyr
        west build -t run  -d ../build/
        cd ..
    else
        echo "Invalid argument"
    fi
fi