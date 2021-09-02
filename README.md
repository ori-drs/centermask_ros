centermask_ros

## Notes
To get CUDA working in docker you need to install a specific kit from NVIDIA. Super easy - [Installation Guide — NVIDIA Cloud Native Technologies documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

## Commands
'''
docker pull nvidia/cuda:11.0-cudnn8-runtime-ubuntu18.04-rc
'''

docker build -t maskrcnn .


docker run --runtime=nvidia -it -p 8888:8888 --net=host  maskrcnn
(Note the runtime arg command is needed for cuda stuff to work
--net=host is needed to communiate with a rost master on the host machine
)

Inside the bash terminal inside the container type:

jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root 

Note need export TF_FORCE_GPU_ALLOW_GROWTH=true in the bashrc




Centermask
Run this inside the repo to create the environment:
'''
nvidia-docker build -t maskrcnn-benchmark --build-arg CUDA=10.0 --build-arg CUDNN=7 docker/
'''

docker build -t detectron2 .



YoloAct:

catkin config -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 -DPYTHON_INCLUDE_DIR=/usr/include/python3.6 -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so
catkin build



# detectron_2_custom

Inside container
mkvirtualenv --python=python3 detectron2_ros

pip install -U torch==1.4+cu100 torchvision==0.5+cu100 -f https://download.pytorch.org/whl/torch_stable.html
pip install cython pyyaml==5.1
pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'
pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu100/index.html
pip install opencv-python
pip install rospkg

mkdir ws
cd ws
mkdir src

git clone https://github.com/DavidFernandezChaves/detectron2_ros.git
cd detectron2_ros
git pull --all
git submodule update --init

wget https://dl.fbaipublicfiles.com/detectron2/COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x/137849600/model_final_f10217.pkl

roslaunch detectron2_ros detectron2_ros.launch model:=/root/model_final_f10217.pkl input:=/camera/color/image_raw

(This gives about 7Hz)

<!-- roslaunch detectron2_ros centermask2_ros.launch model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth input:=/camera/color/image_raw config:=/root/ws/src/Detectron2_ros/centermask/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml -->

# centermask
To give access to the display, run "xhost +local:docker"

docker run --runtime=nvidia -it -p 8888:8888 -e DISPLAY=$DISPLAY --net=host  -v /home/mark/image_datasets:/root/datasets centermask
wget https://dl.dropbox.com/s/uwc0ypa1jvco2bi/centermask2-lite-V-39-eSE-FPN-ms-4x.pth
wget https://images.all-free-download.com/images/graphiclarge/young_tennis_player_186542.jpg
workon centermask2
python /root/centermask2/train_net.py --config-file "/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml" --num-gpus 1 --eval-only MODEL.WEIGHTS /root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth

# centermask_ros
docker build -t centermask_ros .

docker run \
--runtime=nvidia  \
-it -p 8888:8888 -e DISPLAY=$DISPLAY --net=host   \
-v /home/mark/image_datasets:/root/datasets \
-v /home/mark/docker_files/centermask_ros/notebooks:/root/notebooks \
-v /home/mark/docker_files/centermask_ros/Detectron2_ros:/root/ws/src/Detectron2_ros \
centermask_ros

python /root/centermask2/demo.py --config-file "/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml" --num-gpus 1 --eval-only MODEL.WEIGHTS /root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth


jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root 
roslaunch detectron2_ros centermask2_ros.launch input:=/camera/color/image_raw config:=/root/centermask2/configs/centermask/centermask_R_50_FPN_ms_3x.yaml
roslaunch detectron2_ros centermask2_ros.launch input:=/camera/color/image_raw config:=/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth

https://dl.dropbox.com/s/c6n79x83xkdowqc/centermask2-V-99-eSE-FPN-ms-3x.pth
centermask_V_99_eSE_FPN_ms_3x.yaml
roslaunch detectron2_ros centermask2_ros.launch input:=/camera/color/image_raw config:=/root/centermask2/configs/centermask/centermask_V_99_eSE_FPN_ms_3x.yaml model:=/root/centermask2-V-99-eSE-FPN-ms-3x.pth

roslaunch detectron2_ros centermask2_ros.launch input:=/camera/color/image_raw config:=/root/centermask2/configs/centermask/centermask_V_99_eSE_FPN_ms_3x.yaml model:=/root/centermask2-V-99-eSE-FPN-ms-3x.pth detection_threshold:=0.8 visualization:=false

roslaunch detectron2_ros centermask2_ros.launch input:=/camera/color/image_raw config:=/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth detection_threshold:=0.8 visualization:=false

<!-- Note that for the depth version, we need to align the depth image and rgb so that the mask corresponds -->
roslaunch detectron2_ros centermask2_depth_ros.launch rgb_input:=/camera/color/image_raw depth_input:=/camera/aligned_depth_to_color/image_raw config:=/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth detection_threshold:=0.8 visualization:=true


<!-- For the dataset -->
roslaunch detectron2_ros centermask2_depth_ros_compressed.launch rgb_input:=/camera/color/image_raw/compressed depth_input:=/camera/depth/image_rect_raw/compressed config:=/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth detection_threshold:=0.8 visualization:=true

roslaunch detectron2_ros centermask2_depth_ros_compressed.launch rgb_input:=/hsrb/head_rgbd_sensor/rgb/image_rect_color/compressed depth_input:=/hsrb/head_rgbd_sensor/depth_registered/image_rect_raw/compressed config:=/root/centermask2/configs/centermask/centermask_lite_V_39_eSE_FPN_ms_4x.yaml model:=/root/centermask2-lite-V-39-eSE-FPN-ms-4x.pth detection_threshold:=0.8 visualization:=true
