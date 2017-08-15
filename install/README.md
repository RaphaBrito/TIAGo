# TIAGo
TIAGo robot instalation tutorial

## Pré requisitos
  1. Ubuntu 14.04 LTS
```sh
$ wget http://releases.ubuntu.com/14.04/ubuntu-14.04.5-desktop-amd64.iso
```
## ROS Indigo
### Instalação de dependências específicas do sistema:
```sh
$    sudo add-apt-repository --yes ppa:xqms/opencv-nonfree
$    sudo apt-get update
$    sudo apt-get install libopencv-nonfree-dev
```
###  Configuração de pacotes do ROS:
```sh
$   sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
```
Chave de acesso:
```sh
$   sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
```
Caso a chave acima não funcione ( gpg: keyserver timed out error ) utilizar a seguinte:
```sh
$   sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
```
 ### Instalação de pacotes do ROS: 
 ```sh
$   sudo apt-get update
$   sudo apt-get install git python-rosinstall ros-indigo-desktop-full python-catkin-tools ros-indigo-joint-state-controller ros-indigo-twist-mux ros-indigo-ompl ros-indigo-controller-manager ros-indigo-moveit-core ros-indigo-moveit-ros-perception ros-indigo-moveit-ros-move-group ros-indigo-moveit-kinematics ros-indigo-moveit-ros-planning-interface ros-indigo-moveit-simple-controller-manager ros-indigo-moveit-planners-ompl ros-indigo-joy ros-indigo-joy-teleop ros-indigo-teleop-tools ros-indigo-control-toolbox ros-indigo-sound-play ros-indigo-navigation ros-indigo-eband-local-planner ros-indigo-depthimage-to-laserscan  ros-indigo-openslam-gmapping ros-indigo-gmapping ros-indigo-moveit-commander ros-indigo-geometry-experimental ros-indigo-hokuyo-node ros-indigo-sick-tim ros-indigo-humanoid-nav-msgs ros-indigo-moveit-ros-visualization

```
### Colocar no bashrc:
```sh
$   echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
$   source ~/.bashrc
```
## Criação do Ambiente para o Tiago
### Crie e configure a WorkSpace:
```sh
$   mkdir ~/tiago_public_ws
```
Copie o arquivo tiago_public.rosinstall para /opt/ros/indigo e também para a workspace:
ps: Arquivo no repositório: https://github.com/RaphaBrito/TIAGo/blob/master/install/tiago_public.rosinstall

```sh
$   sudo cp -i tiago_public.rosinstall /opt/ros/indigo
$   sudo cp -i tiago_public.rosinstall ~/tiago_public_ws
``` 
OBS: Lembre-se de está na pasta do arquivo que você precisa copiar.
```sh
$   cd ~/tiago_public_ws
$   sudo rosinstall src /opt/ros/indigo tiago_public.rosinstall
$   echo "source ~/tiago_public_ws/src/setup.bash" >> ~/.bashrc
$   source ~/.bashrc
```
Set up rosdep:
```sh
$   sudo rosdep init
$   sudo rosdep update
```
Dependências:
```sh
$   sudo rosdep install --from-paths src --ignore-src --rosdistro indigo --skip-keys="opencv2 opencv2-nonfree pal_laser_filters speed_limit sensor_to_cloud"
```

ps: Se ocorrer algum erro em [pmb2_2dnav_gazebo], subistitua o packege.xml:
```sh
$   cd ~/tiago_public_ws/src/pmb2_simulation/pmb2_simulation/
$   rm package.xml
$   wget "https://raw.githubusercontent.com/RaphaBrito/TIAGo/master/install/package.xml"
```

Building the workspace:
```sh
$   cd ~/tiago_public_ws
$   source /opt/ros/indigo/setup.bash
$   catkin build
```
## Testando a Instalação da simulação
```sh
$   source ./devel/setup.bash
```
  ### A simulação do Tiago pública possui duas versões:
1. Steel
```sh
$   roslaunch tiago_gazebo tiago_gazebo.launch public_sim:=true robot:=steel
```
2. Titanium
```sh
$   roslaunch tiago_gazebo tiago_gazebo.launch public_sim:=true robot:=titanium
```
OBS: Se você tiver algum problema com permissões será nescessário liberar a pasta ~/.ros para o seu usuário.
> nautilus
> ~/.ros
> #Altere a permissão via interface ou via terminal.
