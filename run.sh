
compress_app() {
    echo "Compressing the application"
    ls -lh build/zephyr/zephyr.elf | cut -d " " -f5 > run.log
    compress -f build/zephyr/zephyr.elf
    ls -lh build/zephyr/zephyr.elf.Z | cut -d " " -f5 >> run.log
}

encrypt_app() {
    echo "Encrypting the application"
    openssl enc -aes-256-cbc -p -pass pass:dakshina -in build/zephyr/zephyr.elf.Z -out output/app.enc
    ls -lh output/app.enc | cut -d " " -f5 >> run.log
}

sign_app() {
    echo "Signing the application"
    openssl dgst -sha256 -sign utils/private.pem -passin pass:dakshina -out output/app.sig output/app.enc
    openssl base64 -in output/app.sig -out output/app.sig.b64
}

if [ -z "$1" ]; then
    echo "No argument supplied"
else
    if [ $1 == "b" ]; then
        echo "Building the application"
        cd zephyr
        west build --pristine -b native_sim ../applications/mini_nn/ -d ../build/
        cd ..
        
        compress_app
        encrypt_app
        sign_app
    elif [ $1 == "r" ]; then
        echo "Running the application"
        cd zephyr
        west build -t run -d ../build/
        cd ..
    else
        echo "Invalid argument"
    fi
fi