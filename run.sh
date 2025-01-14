
compress_app() {
    echo "Compressing the application"
    ls -l build/zephyr/zephyr.elf | cut -d " " -f5 > run.log

    case $compress_algo in
        "lzw")
            echo "Compressing using LZW"
            compress -f build/zephyr/zephyr.elf
            mv build/zephyr/zephyr.elf.Z build/zephyr/zephyr.comp
            ;;
        "lzma2")
            echo "Compressing using LZMA2"
            xz build/zephyr/zephyr.elf
            mv build/zephyr/zephyr.elf.xz build/zephyr/zephyr.comp
            ;;
        *)
            echo "Invalid compression algorithm"
            ;;
    esac

    ls -l build/zephyr/zephyr.comp | cut -d " " -f5 >> run.log
}

decompress_app() {
    echo "Decompressing the application"
    start=$(date +%s.%N)

    case $compress_algo in
        "lzw")
            echo "Decompressing using LZW"
            mv build/zephyr/zephyr.comp build/zephyr/zephyr.elf.Z
            compress -d build/zephyr/zephyr.elf.Z
            ;;
        "lzma2")
            echo "Decompressing using LZMA2"
            mv build/zephyr/zephyr.comp build/zephyr/zephyr.elf.xz
            unxz build/zephyr/zephyr.elf.xz
            ;;
        *)
            echo "Invalid compression algorithm"
            ;;
    esac

    end=$(date +%s.%N)
    duration=$(echo "$end - $start" | bc)
    echo $duration >> run.log
}

encrypt_app() {
    echo "Encrypting the application" $enc_algo
    openssl enc $enc_algo -p -pass pass:dakshina -in build/zephyr/zephyr.comp -out output/app.enc
}

sign_app() {
    echo "Signing the application"
    case $auth_algo in
        "rsa_3k")
            echo "Signing using RSA 3k"
            openssl dgst -sha256 -sign utils/private_key_3k.pem  -out output/app.sig output/app.enc
            ;;
        "rsa_4k")
            echo "Signing using RSA 4k"
            openssl dgst -sha256 -sign utils/private_key_4k.pem -out output/app.sig output/app.enc
            ;;
        "ecdsa_192")
            echo "Signing using ECDSA"
            openssl dgst -sha256 -sign utils/private_key_ecdsa_192.pem  -out output/app.sig output/app.enc
            ;;
        "ecdsa_384")
            echo "Signing using ECDSA"
            openssl dgst -sha256 -sign utils/private_key_ecdsa_384.pem  -out output/app.sig output/app.enc
            ;;
        *)
            echo "Invalid authentication algorithm"
            ;;
    esac
    # openssl dgst -sha256 -sign utils/private.pem -passin pass:dakshina -out output/app.sig output/app.enc
    openssl base64 -in output/app.sig -out output/app.sig.b64
}

kernel=$2
app=$3
enc_algo=$4
compress_algo=$5
auth_algo=$6

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
        # decompress_app
    elif [ "$1" = "r" ]; then
        echo "Running the application"
        cd zephyr
        west build -t run  -d ../build/
        cd ..
    else
        echo "Invalid argument"
    fi
fi