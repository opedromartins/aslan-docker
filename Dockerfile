# Use the official ROS Melodic image as the base image
FROM osrf/ros:melodic-desktop-full

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    nano \
    curl \
    gnome-terminal \
    dbus-x11 \
    canberra-gtk-module \
    python3-catkin-tools \
    ros-melodic-socketcan-interface \
    ros-melodic-can-msgs \
    ros-melodic-teleop-twist-keyboard \
    can-utils \
    iproute2 && \
    rm -rf /var/lib/apt/lists/*

# Clone the Aslan repository
RUN git clone --recurse-submodules https://github.com/project-aslan/Aslan.git /root/Aslan

# Install all dependencies with rosdep
WORKDIR /root/Aslan
RUN apt-get update && \
    rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO && \
    rm -rf /var/lib/apt/lists/*

# Build the Aslan package
RUN bash -c 'source /opt/ros/melodic/setup.bash && \
    catkin init && \
    catkin build'

# Source the ROS environment and the Catkin workspace in the entrypoint
RUN echo "source /opt/ros/melodic/setup.bash" >> /root/.bashrc && \
    echo "source /root/Aslan/devel/setup.bash" >> /root/.bashrc

# Change run file
RUN rm /root/Aslan/run
COPY /files/run /root/Aslan/run

# Set the working directory to the root folder
WORKDIR /root