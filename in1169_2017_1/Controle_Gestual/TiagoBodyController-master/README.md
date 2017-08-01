# TiagoBodyController  
A body controller ot the Tiago robot.  

# requirements
- 3D Camrea (DRGB). It works with Orbbec Astra and Asus Xtion, both uses openni driver.  
- Real or Virtual Tiago Pal-Robotics.  
- Ubuntu 14.04 with ros environment installed.  

# set environment:
 $ source ~/Downloads/2-Linux/OpenNI-Linux-x64-2.3/OpenNIDevEnvironment  
 $ source ~/tiago_public_ws/devel/setup.bash  
  
# compile
Download or gitclone the projects TiagoBodyController (https://github.com/derzu/TiagoBodyController) and BodySkeletonTracker (https://github.com/derzu/BodySkeletonTracker).  
 $ cd TiagoBodyController  
 $ sh compile.sh  
 
   
# compile and run just TiagoJointController
Edit TiagoJointController.cpp change mainTest() to main()  
 $ g++ TiagoJointController.cpp -o TiagoJointController -I/opt/ros/indigo/include -I../include/ -I. -Iinclude/ -L/opt/ros/indigo/lib -Wl,-rpath,/opt/ros/indigo/lib -lroscpp -lrosconsole -lrostime -lroscpp_serialization -lboost_system -lboost_thread -pthread -lactionlib  
 $ ./TiagoJointController  

# compile and run just TiagoBaseController
Edit TiagoBaseController.cpp change mainTest() to main()  
 $ g++ TiagoBaseController.cpp -o TiagoBaseController -I/opt/ros/indigo/include -I../include/ -I. -Iinclude/ -L/opt/ros/indigo/lib -Wl,-rpath,/opt/ros/indigo/lib -lroscpp -lrosconsole -lrostime -lroscpp_serialization -lboost_system -lboost_thread -pthread -lactionlib  
 $ ./TiagoBaseController  

# Connect to a Real Tiago (not deploying):
1 - Connect to it's wifi  
2 - terminal:  
 $ export ROS_IP=10.68.0.130   
 $ export ROS_MASTER_URI=http://10.68.0.1:11311  
Where 10.68.0.130 is the computer IP that will control Tiago. And 10.68.0.1 is Tiago's IP.  

# run
 $ cd TiagoBodyController/Bin/x64-Release/  
 $ ./TiagoBodyController  
