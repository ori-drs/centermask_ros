# Centermask ROS

## Before building the docker image

1) Install nvidia container runtime
```
sudo apt-get install nvidia-docker2 nvidia-container-runtime
```

2) For the --runtime=nvidia flag to work with docker you will need to add to docker runtimes (https://stackoverflow.com/questions/59008295/add-nvidia-runtime-to-docker-runtimes)

3) Initialise the submodules:
```
git submodule update --init --recursive
```

## Building
docker build -t centermask_ros .

## Running
Replacing {PATH} with the location of your cloned centermask_ros repo, run the container:

```
docker run \
--runtime=nvidia  \
-it -p 8888:8888 -e DISPLAY=$DISPLAY --net=host   \
-v {PATH}/centermask_ros/notebooks:/root/notebooks \
-v {PATH}/centermask_ros/Detectron2_ros:/root/ws/src/Detectron2_ros \
centermask_ros
```

Activate the virtual environment and build the catkin workspace:

```
workon centermask2 && cd ~/ws && catkin build
```

Launch the centermask node you wish to use and map to the correct topics for your application

``` 
roslaunch detectron2_ros centermask2_depth_ros_compressed.launch rgb_input:=/image_rect_color/compressed depth_input:=/depth_registered/image_rect_raw/compressed config:=/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth detection_threshold:=0.8 visualization:=true
```

Note:
May need to export TF_FORCE_GPU_ALLOW_GROWTH=true in the bashrc
