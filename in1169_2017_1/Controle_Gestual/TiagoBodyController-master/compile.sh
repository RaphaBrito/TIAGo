# compile staticaly the project BodySkeletonTracker. Then compile the TiagoBodyController.
export SLIB_NAME=BodySkeletonTracker
cd ../BodySkeletonTracker/ ; make ; cd -;
export SLIB_NAME=
make
