#include <Tiago.h>
#include <stdio.h>
#include <stdlib.h>

#include <Skeleton.h>
#include <DrawAux.h>

#define ROSRUN 1

Tiago::Tiago() {
	moving = false;
	//t = NULL;
	
	bzero(walkAngleQ, sizeof(int)*QUEUE_SIZE);
	walkAngleH = 0;
	
	walkDirection = NONE;
	walkAngle     = NONE;
	lastWalkDirection = -1;
	lastWalkAngle = -1;
	
	tronco=NONE;
	lastTronco=-1;
	
	started = false;
	
        if (ROSRUN) {
		// Init the joint controller, false means that it has a hand and not a gripper.
		jointController = new TiagoJointController(false);
		baseController  = new TiagoBaseController();
		
		initialPosition();
        }
        else {
	        jointController = NULL;
	        baseController = NULL;
        }
}


Tiago::~Tiago() {
	if (jointController)
		delete jointController;
	if (baseController)
		delete baseController;
}

void Tiago::initialPosition() {
	int r;

	// Send all joints controllers to their intial zero position.
	jointController->setGoal("torso_lift", 0.33); // sobe o torso
	jointController->execute();
	sleep(2);
	jointController->setGoal("arm_2_joint", -1.34); // gira o braco para baixo
	jointController->setGoal("arm_3_joint", -0.2); // gira o braco para fora
	jointController->setGoal("arm_4_joint", 1.96); // antebraco em 90
	jointController->setGoal("arm_5_joint", -1.56); //
	jointController	->setGoal("arm_6_joint", 1.33); //
	jointController->execute();
}

float Tiago::getAngElbow() {
	return angElbow;
}

float Tiago::getAngShoulder() {
	return angShoulder;
}

float Tiago::getAngShoulderFront() {
	return angShoulderFront;
}

void Tiago::setMoving(bool m) {
	moving = m;
}

bool Tiago::isMoving() {
	return moving;
}

void Tiago::setAngElbow(float ang) {
	angElbow = ang;
}

void Tiago::setAngShoulder(float ang) {
	angShoulder = ang;
}

void Tiago::setAngShoulderFront(float ang) {
	angShoulderFront = ang;
}




std::vector<cv::Rect> * Tiago::detectTiagoCommands(SkeletonPoints* sp, int afa, Point3D * closest) {
	static int c=0;
	c++;
	std::vector<cv::Rect> * recs = new std::vector<cv::Rect>();
	cv::Rect r;
	
	
	// Moviemento que libera a deteccao dos gestos.
	if (!started && sp->leftShoulder.x!=0) {
		// os y tem que estar proximos e os x tem que estarem afastados.
		if (abs(sp->leftHand.y - sp->leftElbow.y)<30 && abs(sp->leftElbow.y - sp->leftShoulder.y)<30 && abs(sp->leftElbow.x - sp->leftHand.x)>30 && abs(sp->leftShoulder.x - sp->leftElbow.x)>30)
		{
			started = true;
			printf("ACEITA COMANDOS GERAL\n");
		}
		else {
			r = cv::Rect(sp->leftShoulder.x-250, sp->leftShoulder.y-30, 250, 60);
			recs->push_back(r);
		}
	}
	
	// se os gestos nao estiverem liberados retorna.
	if (!started)
		return recs;
	
	//printf("sp->head.z=%6d  left/rightHand=%6d::%6d\n", sp->head.z, sp->leftHand.z, sp->rightHand.z);

	r = cv::Rect((sp->center.x - afa*2)-200, sp->center.y + afa, 200, 200);
	recs->push_back(r);

	// mao esquerda esticada e afastada do corpo, comandos ativados.
	if (sp->leftHand.x!=0 && sp->leftHand.x < sp->center.x - afa*2 && sp->leftHand.y > sp->center.y + afa)
	{
		//printf("ACEITA COMANDOS BRACO/TORSO\n");
		// TORSO
		// media dos dois ombros atual
		int y1 = (sp->rightShoulder.y + sp->leftShoulder.y)/2; 
		// ultima media dos dois ombros armazenada
		int y2 = (sp->pointsV[SkeletonPoints::RIGHT_SHOULDER][sp->vHead[SkeletonPoints::RIGHT_SHOULDER] % BUF_SIZE].y + 
			  sp->pointsV[SkeletonPoints::LEFT_SHOULDER][sp->vHead[SkeletonPoints::LEFT_SHOULDER] % BUF_SIZE].y)/2;
		//printf("%d::Recebendo comandos (%d - %d)=%d\n", c++, y1, y2, y1 - y2);
		tronco = NONE;
		if (y1 - y2 >= 18) {
			tronco = DOWN;
		}
		if (y1 - y2 <= -18) {
			tronco = UP;
		}
		
		if (tronco!=lastTronco && tronco!=NONE) {
			printf("%d::TRONCO::%s\n", c, tronco==UP? "UP" : "DOWN");
			if (ROSRUN) {
				if (tronco==UP)
					jointController->setGoal("torso_lift_joint", 1); //systemThread("rosrun play_motion move_joint torso_lift_joint  1 0.2");
				else
					jointController->setGoal("torso_lift_joint", -1); //systemThread("rosrun play_motion move_joint torso_lift_joint -1 0.2");
				jointController->execute();
			}
			
		}
		lastTronco = tronco;



		// BRACO / ARM
		// so entra a cada 10c para nao poluir muito o terminal	
		if (c%10==0)
		{
			float angShoulder, angElbow, angShoulderFront;
			// Angulo entre ombro e cotovelo
			if (sp->rightHand.x!=0 && sp->rightElbow.x!=0) {
				angShoulder = -atan2f(sp->rightElbow.y-sp->rightShoulder.y, sp->rightElbow.x-sp->rightShoulder.x)*180./CV_PI;
				angShoulder = (((int)angShoulder)/5)*5;
				setAngShoulder(angShoulder);
				//printf("\nANG:: OMBRO  ::%.1f\n", angShoulder);
			}

			// Angulo entre antebraco e cotovelo
			if (sp->rightHand.x!=0 && sp->rightElbow.x!=0) {
				angElbow = -atan2f(sp->rightHand.y-sp->rightElbow.y, sp->rightHand.x-sp->rightElbow.x)*180./CV_PI;
				angElbow = (((int)angElbow)/5)*5;
				setAngElbow(angElbow);
				//printf("ANG::COTOVELO::%.1f\n", angElbow);
			}

			int diffz = sp->rightShoulder.z - sp->rightElbow.z;
			if (diffz > 10 && sp->rightElbow.z!=0) {
				if (diffz>1000) diffz/=10;
				angShoulderFront = -atan2f(diffz*0.6, sp->rightElbow.x - sp->rightShoulder.x)*180./CV_PI;
				setAngShoulderFront(angShoulderFront);
				//printf("ANG::angShoulderFront::%.1f::%d::%d::%d\n\n", angShoulderFront, diffz, sp->rightShoulder.z, sp->rightElbow.z);
			}
			else 
				setAngShoulderFront(0.1);
			
			if (ROSRUN)
				moveArm(this);
		}

	}

	// mao esquerda afastada do corpo, e da linha centra para baixo.
	if (sp->leftHand.x!=0 && sp->leftHand.x < (sp->center.x - afa*1.0) && sp->leftHand.y > sp->center.y - afa/2)
	// se a mao esquerda estiver mais a esquerda do que o ombro, e ambos estiverem acima da linha da cintura
	//if (sp->leftHand.x!=0 && sp->leftElbow.x!=0 && sp->leftHand.y < sp->center.y-afa && sp->leftElbow.y < sp->center.y )
	{
		int profRight = sp->rightShoulder.z;
		int profLeft  = sp->leftShoulder.z;
		int diff =  profRight - profLeft;
		walkAngle = -1;
		if (profRight>0 && profLeft>0) {
			if (diff > 125)
				walkAngle = RIGHT;
			else if (diff < -125)
				walkAngle = LEFT;
			else
				walkAngle = NONE;
			
			if (walkAngle != -1)
				walkAngleQ[walkAngleH++ % QUEUE_SIZE] = walkAngle;
			walkAngle = getModeVector(walkAngleQ);
			if (walkAngle==RIGHT || walkAngle==LEFT)
				printf("walk angle::%s\n", walkAngle == RIGHT? "RIGHT" : walkAngle==LEFT ? "LEFT" : "NONE");
		}
		if (walkAngle != -1) {
			//printf("profundidade: %4d %4d %5d %8s %8s\n", profRight, profLeft, diff, diff > 150 ? "DIREITA" : diff<-150 ? "ESQUERDA" : "NONE",  walkAngle==RIGHT ? "DIREITA" : walkAngle==LEFT ? "ESQUERDA" : "NONE");
		}
		
			
		//printf("diff1=%5d diff2=%5d\n", abs(sp->leftHand.y - sp->leftElbow.y), abs(sp->leftHand.x - sp->leftElbow.x));
		walkDirection = NONE;
		
		r = cv::Rect(sp->leftElbow.x-200, sp->leftElbow.y-40, 200-50, 80);
		recs->push_back(r);

		r = cv::Rect(sp->center.x - afa*2, sp->center.y - afa/2,  (sp->center.x - afa*1.0) - (sp->center.x - afa*2),  (sp->center.y + afa*1.3) - (sp->center.y - afa/2) );
		recs->push_back(r);
		
		// se a mao e o ombro estiverem quase na mesma linha, e os x distantes.
		if (abs(sp->leftHand.y - sp->leftElbow.y)<40  &&  abs(sp->leftHand.x - sp->leftElbow.x)>50) {
			walkDirection = BACKWARD;
			printf("BACKWARD\n");
			changeHand(true);
		}
		// se a mao estiver afastada no y, mas nao muito AND mao proximo da linha da cintura.
		else if (sp->leftHand.x > (sp->center.x - afa*2) && (sp->leftHand.y < (sp->center.y + afa*1.3)) ) {
			//printf("diff3=%5d\n", (int)Skeleton::euclideanDist(*closest, sp->leftHand));
			// se a mao tiver perto do ponto mais proximo
			if (DrawAux::euclideanDist(*closest, sp->leftHand) < 40) {
				walkDirection = FORWARD;
				printf("FORWARD\n");
				changeHand(false);
			}
		}
		//else
		//	printf("NONE\n");
		//printf("walkDirection=%2d, walkAngle=%2d\n", walkDirection, walkAngle);

		
		if(ROSRUN)
			moveBase(walkDirection, walkAngle);
	}
	
	return recs;
}



void * Tiago::moveArm(void * t) {
	Tiago * tiago = (Tiago*)t;

	if (tiago->isMoving()) return NULL;

	tiago->setMoving(true);

	char comando[100];
	char jointStr[20];
	int joint;
	float ang;
	int r;

	/*if (aShoulder>0) {
		if (aElbow>0)
			ang = aElbow-aShoulder; // subtrai o shoulder do ombro
		else
			ang = aElbow-aShoulder; // soma os dois angulos
	}
	else {
		if (aElbow>0)
			ang = aElbow-aShoulder; // soma os dois angulos
		else
			ang = aElbow-aShoulder; // subtrai o shoulder do ombro
	}*/

	ang = abs(tiago->getAngShoulderFront());
	ang = ang*CV_PI/180.; // conversao do angulo para radianos
	tiago->jointController->setGoal("arm_1_joint", ang);
	
	
	ang = tiago->getAngShoulder();
	//printf("ang Shoulder ::%.2f\n", ang);
	ang = ang*CV_PI/180.; // conversao do angulo para radianos
	tiago->jointController->setGoal("arm_2_joint", ang);
	

	ang = tiago->getAngElbow() - tiago->getAngShoulder();
	//printf("ang  Elbow   ::%.2f\n", ang);
	// JOINT 3 - gira todo o antebraco.
	if (ang>0) {
		//printf("girando braco para cima\n");
		tiago->jointController->setGoal("arm_3_joint", -CV_PI); // gira o braco para cima
	}
	else {
		//printf("girando braco para baixo\n");
		tiago->jointController->setGoal("arm_3_joint", 0); // gira o braco para baixo
	}
	
	ang = fabs(ang*CV_PI/180.); // conversao do angulo para radianos
	//printf("ang::%.2f\n", ang)
	tiago->jointController->setGoal("arm_4_joint", ang);
	

	
	// The 4 goals will be executed simultaneously
	tiago->jointController->execute();

	tiago->setMoving(false);
	//tiago->mutexUnlock();
}



void Tiago::moveBase(int walkDirection, int walkAngle) {
	int r;
	float ang = 0;
	float dir = 0;

	if (walkDirection==FORWARD)
		dir = TiagoBaseController::FORWARD;
	if (walkDirection==BACKWARD)
		dir = TiagoBaseController::BACKWARD;
	if (walkAngle==RIGHT)
		ang = TiagoBaseController::RIGHT;
	if (walkAngle==LEFT)
		ang = TiagoBaseController::LEFT;
	
	if (dir!=0 || ang!=0) {
		baseController->executeGoal(dir, ang);
	}
	
	lastWalkDirection = walkDirection;
	lastWalkAngle = walkAngle;
}


/**
 * Mode algorithm just for a 3 valued vector.
 **/
int Tiago::getModeVector(int vector[]) {
	int histo[3]={0,0,0}; // NONE, RIGHT, LEFT

	for (int i=0 ; i<QUEUE_SIZE ; i++)
		histo[vector[i]]++;
		
	if (histo[0]>histo[1] && histo[0]>histo[2])
		return 0;
	else if (histo[1]>histo[0] && histo[1]>histo[2])
		return 1;
	else
		return 2;
}

/**
 * Mediana
 **/
int Tiago::getMedianaVector(int vector[]) {
	int m = 1;
	int q=0;

	SkeletonPoints::quick_sort(vector, 0, QUEUE_SIZE);

	for (int i=0 ; i<QUEUE_SIZE ; i++) {
		if (vector[i]!=0) {
			q++;
		}
	}
	if (q>0)
		return vector[q/2+QUEUE_SIZE-q];

	return m;
}


void Tiago::changeHand(bool open) {
	if (open) {
		jointController->setGoal("hand_index", 0);
		jointController->setGoal("hand_mrl",   0);
		jointController->setGoal("hand_thumb", 0);
	} else {
		jointController->setGoal("hand_index", 6);
		jointController->setGoal("hand_mrl",   6);
		jointController->setGoal("hand_thumb", 6);
	}
	jointController->execute();
}
