set -e
set -u

. install/common.sh

# Works for 1 package too
install_packages () {
    array=()
    for i in "$@"
    do
        if [ -z "$(which $i)" ] ; then
            array+=($i)
        else
            print_yl "$i is already installed\n"
        fi
    done
    if [ ${#array[@]} -gt 0 ] ; then
	print_bl "Installing ${array[@]} \n"
	sudo apt-get install "${array[@]}"
    fi
}

install_ag () {
    if [ -z "$(which ag)" ] ; then
        print_bl "Installing ag\n"
        sudo apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev \
            liblzma-dev
        git clone https://github.com/ggreer/the_silver_searcher ~/the_silver_searcher
        cd ~/the_silver_searcher
        ./build.sh
        sudo make install
        cd -
        sudo rm -rf ~/the_silver_searcher
    else
        print_yl "ag is already installed\n"
    fi
}

install_gcc () {
    if [ -z "$(which gcc-4.8)" ] ; then
        print_bl "Installing GCC 4.8\n"
        sudo apt-get install gcc-4.8 g++-4.8 build-essential
        sudo update-alternatives --install /usr/bin/gcc gcc \
            /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8
    else
        print_yl "GCC 4.8 is already installed\n"
    fi

    if [ -z "$(which gcc-4.9)" ] ; then
        print_bl "Installing GCC 4.9\n"
        sudo apt-get install build-essential
        sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        sudo apt-get update
        sudo apt-get install gcc-4.9 g++-4.9 cpp-4.9
        sudo update-alternatives --install /usr/bin/gcc gcc \
            /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
    else
        print_yl "GCC 4.9 is already installed\n"
    fi
}

install_git () {
    if [ -z "$(which git)" ] ; then
        sudo apt-get install python-software-properties
        sudo add-apt-repository ppa:git-core/ppa
        sudo apt-get update
        sudo apt-get install git
    else
        print_yl "Git is already installed\n"
    fi
}

install_ros () {
    if [ ! -d /opt/ros/indigo/ ] ; then
        print_bl "Installing ROS\n"
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu \
        $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
        sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net \
                         --recv-key 0xB01FA116
        sudo apt-get update
        sudo apt-get install ros-indigo-desktop-full python-wstool \
             python-rosinstall ros-indigo-multimaster-fkie python-wstool \
             ros-indigo-vision-opencv ros-indigo-vision-visp \
             ros-indigo-openni2-camera ros-indigo-openni2-launch \

    else
        print_yl "ROS is already installed\n"
    fi
}

install_python () {
    sudo apt-get install python-pip
    sudo pip install --upgrade pip
    sudo pip install virtualenv
}

install_dependencies () {
    install_git
    install_gcc
    install_ag
    install_ros
    install_python
    install_packages \
        emacs \
        vim \
        htop \
        powertop \
        iperf \
        mosh \
        tmux \
        screen \
        valgrind \
        gdb \
        libgtest-dev \
        libgfortran-4.8-dev \
        libboost-all-dev \
        libxml2-dev
}
