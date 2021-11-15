FROM nvidia/cuda:11.0-runtime-ubuntu18.04

LABEL maintainer="Mark Finean"
LABEL maintainer_email="mfinean@robots.ox.ac.uk"

ARG DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata pkgs....

ENV CUDNN_VERSION 7.6.5.32

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
    && apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

# add the ROS deb repo to the apt sources list
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
          git \
		cmake \
		build-essential \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

RUN curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | apt-key add -

# install ROS packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		ros-melodic-desktop \
		ros-melodic-image-transport \
		ros-melodic-vision-msgs \
          python-rosdep \
          python-rosinstall \
          python-rosinstall-generator \
          python-wstool \
        python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# init/update rosdep
RUN apt-get update && \
    rosdep init && \
    rosdep update && \
    rm -rf /var/lib/apt/lists/*


COPY ./ros_entrypoint.sh /ros_entrypoint.sh
RUN echo 'source /opt/ros/melodic/setup.bash' >> /root/.bashrc && \ 
/bin/bash /opt/ros/melodic/setup.bash



########################################################################################

# Essentials: developer tools, build tools, OpenBLAS
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils git curl vim unzip openssh-client wget \
    build-essential cmake \
    libopenblas-dev

RUN sudo apt-get install python-pip -y && \ 
    sudo pip install virtualenv && \ 
    mkdir ~/.virtualenvs && \ 
    sudo pip install virtualenvwrapper && \ 
    echo '. /usr/local/bin/virtualenvwrapper.sh' >> ~/.bashrc 

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ADD repo-key /
RUN \
  chmod 600 /repo-key && \  
  echo "IdentityFile /repo-key" >> /etc/ssh/ssh_config && \  
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

WORKDIR "/root"

COPY ./centermask2 /root/centermask2

RUN . ~/.bashrc && \ 
    export WORKON_HOME=~/.virtualenvs && \
    /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh && mkvirtualenv --python=python3 centermask2  && \
    pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio==0.7.2 -f https://download.pytorch.org/whl/torch_stable.html && \
    pip install cython pyyaml && \
    pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' && \
    python -m pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu110/torch1.7/index.html && \
    pip install opencv-python  && \
    pip install rospkg && \
    pip install pyrealsense2 && \
    pip --no-cache-dir install jupyter  && \
    cd /root/centermask2 && \
    pip install ."

# Jupyter Notebook
# Allow access from outside the container, and skip trying to open a browser.
# NOTE: disable authentication token for convenience. DON'T DO THIS ON A PUBLIC SERVER.
RUN mkdir /root/.jupyter && \
    echo "c.NotebookApp.ip = '*'" \
         "\nc.NotebookApp.open_browser = False" \
         "\nc.NotebookApp.token = ''" \
         > /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888


ADD repo-key /
RUN \
    chmod 600 /repo-key && \  
    echo "IdentityFile /repo-key" >> /etc/ssh/ssh_config && \  
    echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config 

# So we can use locate
RUN apt-get install mlocate && updatedb

WORKDIR "/root/ws/src"

# RUN git clone https://github.com/mfinean/Detectron2_ros.git && \
#     cd Detectron2_ros  && \
#     git pull --all  && \
#     git submodule update --init    && \
#     git checkout working_centermask && \
#     git pull

# RUN git clone https://github.com/mfinean/finean_msgs.git && \
#     cd finean_msgs  && \
#     git pull

WORKDIR "/root"
# COPY ./centermask_node_testing.ipynb /root/centermask_node_testing.ipynb
# COPY ./centermask_node_testing2.ipynb /root/centermask_node_testing2.ipynb
RUN wget https://dl.dropbox.com/s/uwc0ypa1jvco2bi/centermask2-lite-V-39-eSE-FPN-ms-4x.pth && \
    wget https://images.all-free-download.com/images/graphiclarge/young_tennis_player_186542.jpg && \
    wget https://dl.dropbox.com/s/c6n79x83xkdowqc/centermask2-V-99-eSE-FPN-ms-3x.pth 
# -------------------------------------------- At this point you should be able to build and use detectron2_ros.

# We now need to transfer our local copy of centermask into the docker file so that we can build what we're working on
# This will need to by installed into the python3 environment that we've created



RUN export DISPLAY=:1 

CMD ["/bin/bash"]


