#include <GestualListener.h>

GestualListener::GestualListener() {
	tiago = new Tiago();
}

GestualListener::~GestualListener() {
	if (tiago)
		delete tiago;
}

std::vector<cv::Rect> * GestualListener::onEvent(SkeletonPoints * sp, int afa, Point3D *closest) {
	//printf("Recebi o esqueleto\n");
	
	return tiago->detectTiagoCommands(sp, afa, closest);
}
