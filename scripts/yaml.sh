if [ -d "/usr/local/cuda-10.1/bin/" ]; then
    echo "G30 build rule - install yaml-cpp with hands from source" >&2
    echo -L$HOME/libs/ -I$HOME/libs/include -lyaml-cpp
    exit
fi

if (! dpkg -l | grep "libyaml-cpp-dev" > /dev/null); then
    echo "libyaml-cpp-dev is required to parse yaml configuration. Do you want to install it? y/n: " >&2
    answer=""
    read answer
    if [ "$answer" = "y" ]; then
        yes | sudo apt-get install libyaml-cpp-dev > /dev/null
        echo $(pkg-config --cflags --libs yaml-cpp)
        exit
    fi
    echo -1
else
    echo $(pkg-config --cflags --libs yaml-cpp)
fi
