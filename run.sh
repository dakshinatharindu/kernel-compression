
compress_app() {
    echo "Compressing the application"
    ls -l build/zephyr/zephyr.elf | cut -d " " -f5 > run.log
    # compress -f build/zephyr/zephyr.elf
    xz build/zephyr/zephyr.elf
    # ls -l build/zephyr/zephyr.elf.Z | cut -d " " -f5 >> run.log
    ls -l build/zephyr/zephyr.elf.xz | cut -d " " -f5 >> run.log
}

decompress_app() {
    echo "Decompressing the application"
    start=$(date +%s.%N)
    # compress -d build/zephyr/zephyr.elf.Z
    unxz build/zephyr/zephyr.elf.xz
    end=$(date +%s.%N)
    duration=$(echo "$end - $start" | bc)
    echo $duration >> run.log
}

encrypt_app() {
    echo "Encrypting the application"
    # openssl enc $4 -p -pass pass:dakshina -in build/zephyr/zephyr.elf.Z -out output/app.enc
    openssl enc $4 -p -pass pass:dakshina -in build/zephyr/zephyr.elf.xz -out output/app.enc
}

sign_app() {
    echo "Signing the application"
    openssl dgst -sha256 -sign utils/private.pem -passin pass:dakshina -out output/app.sig output/app.enc
    openssl base64 -in output/app.sig -out output/app.sig.b64
}

if [ -z "$1" ]; then
    echo "No argument supplied"
else
    if [ "$1" = "b" ]; then
        echo "Building the application"
        cd zephyr
        west build --pristine -b $2 ../applications/$3 -d ../build/
        cd ..
        
        compress_app
        encrypt_app
        sign_app
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