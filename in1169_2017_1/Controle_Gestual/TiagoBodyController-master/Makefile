include CommonDefs.mak

BIN_DIR = Bin

INC_DIRS = include

SRC_FILES = src/*.cpp

ifeq ("$(OSTYPE)","Darwin")
	CFLAGS += -DMACOS
	LDFLAGS += -framework -framework
else
	CFLAGS += -DUNIX -DGLX_GLXEXT_LEGACY
	USED_LIBS +=
endif

USED_LIBS += OpenNI2

#if DEPTH camera like Orbbec Astra, or Asus Xtion add this flag DEPTH. If not comment the following line
CFLAGS += -DDEPTH

EXE_NAME = TiagoBodyController

#ROS
ROS = -L/opt/ros/indigo/lib -Wl,-rpath,/opt/ros/indigo/lib,--as-needed -lroscpp -lrosconsole -lrostime -lroscpp_serialization -lboost_system -lboost_thread -lactionlib

#opencv
#CFLAGS +=  -g -std=c++11 
LDFLAGS += -L../BodySkeletonTracker/Bin/x64-Release/ -lBodySkeletonTracker $(shell pkg-config --libs --static opencv) $(ROS)

ifndef OPENNI2_INCLUDE
    $(error OPENNI2_INCLUDE is not defined. Please define it or 'source' the OpenNIDevEnvironment file from the installation)
else ifndef OPENNI2_REDIST
    $(error OPENNI2_REDIST is not defined. Please define it or 'source' the OpenNIDevEnvironment file from the installation)
endif



INC_DIRS += $(OPENNI2_INCLUDE) /home/derzu/workspace/BodySkeletonTracker/include/ -I/opt/ros/indigo/include

include CommonCppMakefile

.PHONY: copy-redist
copy-redist:
	cp -R $(OPENNI2_REDIST)/* $(OUT_DIR)

$(OUTPUT_FILE): copy-redist

