if (! dpkg -l | grep "libyaml-cpp-dev" > /dev/null); then
    echo "libyaml-cpp-dev is required to parse yaml configuration. Do you want to install it? y/n: "
    answer=""
    read answer
    if [ "$answer" = "y" ]; then
        yes | sudo apt-get install libyaml-cpp-dev > /dev/null
    fi
fi
