

if [ -z "$1" ]; then
    echo "No argument supplied"
else
    if [ $1 == "b" ]; then
        echo "Building the application"
        cd zephyr
        west build --pristine -b qemu_cortex_m3 ../applications/hello_world/
        cd ..
    elif [ $1 == "r" ]; then
        echo "Running the application"
        cd zephyr
        west build -t run
        cd ..
    else
        echo "Invalid argument"
    fi
fi