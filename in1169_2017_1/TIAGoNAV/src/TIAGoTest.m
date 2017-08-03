%% Working with Specialized ROS Messages
%% Introduction
% Some commonly used ROS messages store data in a format that requires 
% some transformation before it can be used for further processing. MATLAB(R) can help 
% you by formatting common ROS messages for easy use. In this example, you can 
% explore how message types for laser scans, uncompressed and compressed images, 
% and point clouds are handled.
%
% Prerequisites: <docid:robotics_examples.example-ROSMessagesExample>

% Copyright 2014-2015 The MathWorks, Inc.

%% Load Sample Messages
% First, load some sample messages that will be used in this example.
% These messages are populated with data gathered from various robotics sensors.
%
% * Call |exampleHelperROSLoadMessages| to load the messages.
%%
exampleHelperROSLoadMessages


%% Laser Scan Messages
% Laser scanners are commonly used sensors in robotics. You can see the
% standard ROS format for a laser scan message by creating an empty message
% of the appropriate type. 
%
% * Use |<docid:robotics_ref.bupf5_j_2 rosmessage>| to create the message.
%%
emptyscan = rosmessage(rostype.sensor_msgs_LaserScan)

%%
% Since you created an empty message, |emptyscan| does not contain any
% meaningful data. For convenience, the |exampleHelperROSLoadMessages| function 
% loaded a laser scan message that is fully populated and is stored in the
% |scan| variable.
%
% * Inspect the |scan| variable. The primary data in the message is in the |Ranges| field. 
% The data in |Ranges| is a [640x1] array of obstacle distances that were 
% recorded at small angle increments.
%%
scan

%%
% *  You can get the measured points in Cartesian coordinates using the
% |<docid:robotics_ref.buqbmq9 readCartesian>| function:
%%
xy = readCartesian(scan)

%%
% * This returns a list of |[x,y]| coordinates that were calculated based on 
% all valid range readings.
% * You can visualize the scan message using the |<docid:robotics_ref.buqbjtl plot>| function:
%%
plot(scan,'MaximumRange',5)

%% Image Messages
% MATLAB also provides support for image messages, which always have the
% message type |sensor_msgs/Image|.
%
% * Create an empty image message using |<docid:robotics_ref.bupf5_j_2 rosmessage>| 
% to see the standard ROS format for an image message. 
%%
emptyimg = rosmessage(rostype.sensor_msgs_Image)

%%
% For convenience, the |exampleHelperROSLoadMessages| function 
% loaded an image message that is fully populated and is stored in the
% |img| variable.
%
% * Inspect the image message variable |img| in your workspace. The size of
% the image is stored in the |Width| and |Height| properties. ROS sends the 
% actual image data using a one-dimensional array in the |Data| field.
%%
img

%%
% * The |Data| field stores raw image data that cannot be used directly  
% for processing and visualization in MATLAB. You
% can use the |<docid:robotics_ref.buqbtm0 readImage>| function to retrieve the image in a format that
% is compatible with MATLAB.
%%
imageFormatted = readImage(img);

%%
% * The original image has an 'rgb8' encoding. By default, |<docid:robotics_ref.buqbtm0 readImage>|
% returns the image in a standard 480x640x3 uint8 format. You can view this
% image using the |<docid:matlab_ref.buin8q9-1 imshow>| function.
%%
imshow(imageFormatted)

%%
% MATLAB(R) supports all ROS image encoding formats and
% |<docid:robotics_ref.buqbtm0 readImage>| handles the complexity of
% converting the image data. In addition to color images, 
% MATLAB also supports monochromatic and depth images.


%% Compressed Messages
% Many ROS systems send their image data in a compressed format. MATLAB
% provides support for these compressed image messages. 
%
% * Create an empty
% compressed image message using |<docid:robotics_ref.bupf5_j_2
% rosmessage>|. Compressed images in ROS have the message type
% |sensor_msgs/CompressedImage| and have a standard structure.
%%
emptyimgcomp = rosmessage(rostype.sensor_msgs_CompressedImage)

%%
% For convenience, the |exampleHelperROSLoadMessages| function 
% loaded a compressed image message that is already populated.
%
% * Inspect the |imgcomp| variable that was captured by a camera. The
% |Format| property captures all the information that MATLAB needs to
% decompress the image data stored in |Data|.
%%
imgcomp

%%
% * Similar to the image message, you can use |<docid:robotics_ref.buqbtm0 readImage>| to
% obtain the image in standard RGB format. Even though the original
% encoding for this compressed image is |bgr8|,
% |<docid:robotics_ref.buqbtm0 readImage>| will do the conversion. 
%%
compressedFormatted = readImage(imgcomp);

%%
% * You can visualize the image using the |<docid:matlab_ref.buin8q9-1 imshow>| function.
%%
imshow(compressedFormatted)

%%
% Most image formats are supported for the compressed image message type.
% The '16UC1' and '32FC1' encodings are not supported
% for compressed depth images. Monochromatic and color image encodings are
% supported.


%% Point Clouds
% Point clouds can be captured by a variety of sensors used in robotics,
% including LIDARs, Kinect(R) and stereo cameras. The most common message
% type in ROS for transmitting point clouds is |sensor_msgs/PointCloud2|
% and MATLAB provides some specialized functions for you to work with this
% data.
%
% * You can see the standard ROS format for a point cloud message by creating 
% an empty message of the appropriate type.
%%
emptyptcloud = rosmessage(rostype.sensor_msgs_PointCloud2)

%%
% * View the populated point cloud message that is stored in the |ptcloud|
% variable in your workspace:
%%
ptcloud

%%
% * The point cloud information is encoded in the |Data| field of the
% message. You can extract the |[x,y,z]| coordinates as an N-by-3 matrix by calling
% the |<docid:robotics_ref.buqbra8 readXYZ>| function.
xyz = readXYZ(ptcloud)

%%
% * |NaN| in the point cloud data indicates that some of the |[x,y,z]| values are not
% valid. In this case, this is an artifact of the Kinect(R) sensor and you can
% safely remove all |NaN| values.
xyzvalid = xyz(~isnan(xyz(:,1)),:)

%%
% * Some point cloud sensors also assign RGB color values to each point in
% a point cloud. If these color values exist, you can retrieve them with
% a call to |<docid:robotics_ref.buqbpn2 readRGB>|.
%%
rgb = readRGB(ptcloud)

%%
% * You can visualize the point cloud with the help of the |<docid:robotics_ref.buqbrwu scatter3>|
% function. |<docid:robotics_ref.buqbrwu scatter3>| will automatically extract the |[x,y,z]|
% coordinates and the RGB color values (if they exist) and show them in a
% 3D scatter plot. The |<docid:robotics_ref.buqbrwu scatter3>| function
% ignores all |NaN| |[x,y,z]| coordinates, even if RGB values exist for that point.
%%
scatter3(ptcloud)

%%
displayEndOfDemoMessage(mfilename)
