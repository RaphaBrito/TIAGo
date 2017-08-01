#ifndef GESTUAL_LISTENER_H
#define GESTUAL_LISTENER_H

#include "SkeletonPoints.h"
#include "SkeletonListener.h"
#include "Tiago.h"


class GestualListener : public SkeletonListener {

	public:
		GestualListener();
		virtual ~GestualListener();
		virtual std::vector<cv::Rect> * onEvent(SkeletonPoints * sp, int afa, Point3D *closest);
		
	private:
		// Pal-robotics Tiago
		Tiago * tiago;
};


#endif
