#ifndef TIAGO_H
#define TIAGO_H

//head_1_joint
//head_2_joint
//torso_lift_joint  1 e -1
//gripper_right_finger_joint (stell)
//gripper_left_finger_joint  (stell)

//arm_1_joint Primeira::Ombro::frente/tras ::ang:: -90:: -45:: 0,0::  45:: 67,5
//                                         ::ang::   0::  45::90,0:: 135::157,5
//                                         ::val::0,02::0,78::1,56::2,34:: 2,73

//arm_2_joint Segunda::Ombro::Cima/baixo ::ang::  -90::  -45::0,0::  45::62,53
//                                       ::val::-1,55::-0,78::0,0::0,78::1.07

//arm_3_joint Terceira::Ombro::Gira Braco::ang::-201,2:: -180::  -90::0,0::  90
//                                       ::val:: -3,51::-3,14::-1,56::0,0::1,56

//arm_4_joint Quarta  ::Cototvelo::ang::-21,3::0,0::  45::  90:: 135
//                               ::val::-0,37::0,0::0,78::1,56::2,34

//arm_5_joint mao/punho
//arm_6_joint mao/punho
//arm_7_joint mao/punho

//hand_index_joint (titanium) // indicador
//hand_mrl_joint   (titanium) // tres dedos
//hand_thumb_joint (titanium) // polegar

// Para testar graficamente
// rosrun rqt_joint_trajectory_controller rqt_joint_trajectory_controller

#define ELBOW_90  1.57
#define ELBOW_MAX 2.1
#define SHOULDER_45  0.785
#define ORIGIN 0

#include "SkeletonPoints.h"
#include "TiagoJointController.h"
#include "TiagoBaseController.h"
#include "Point3D.h"
#include <vector>

#define QUEUE_SIZE 3

class Tiago {
	public:
		Tiago();
		virtual ~Tiago();
		static void * moveArm(void * t);
		bool isMoving();
		float getAngElbow();
		float getAngShoulder();
		float getAngShoulderFront();
		void setMoving(bool m);
		void setAngElbow(float ang);
		void setAngShoulder(float ang);
		void setAngShoulderFront(float ang);
		void changeHand(bool open);

		std::vector<cv::Rect> *detectTiagoCommands(SkeletonPoints* sp, int afa, Point3D *closest);
		int  getMedianaVector(int vector[]);
		int  getModeVector(int vector[]);
		
		// Directions Constants from the base movements
		static const int NONE  = 0;
		static const int RIGHT = 1;
		static const int LEFT  = 2;
		static const int FORWARD = 1;
		static const int BACKWARD= 2;
		static const int UP    = 1;
		static const int DOWN  = 2;
	private:
		void moveBase(int walkDirection, int walkAngle);
		void initialPosition();

		TiagoJointController * jointController;
		TiagoBaseController * baseController;
		
		bool started;	
		bool moving;
		float angShoulder, angElbow;
		float angShoulderFront;
		
		int tronco, lastTronco;
		int walkDirection, lastWalkDirection;
		int walkAngle, lastWalkAngle;
		int walkAngleQ[QUEUE_SIZE]; // vector to smoth the directions
		unsigned char walkAngleH; // head
};



#endif
