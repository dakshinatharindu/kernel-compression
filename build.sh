if [ -z "$1" ]; then
    echo "No argument supplied"
else
    if [ "$1" = "b" ]; then
        echo "Building the application"
        cd zephyr
        west build --pristine -b $2 $3 -d ../build1/
        cd ..
    elif [ "$1" = "r" ]; then
        echo "Running the application"
        cd zephyr
        west build -t run  -d ../build/
        cd ..
    else
        echo "Invalid argument"
    fi
fi