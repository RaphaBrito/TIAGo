% config
clear all;

connect = 'robot';      % ['turtle','tiago','robot'] 
source = 'simulator';        % ['file', 'simulator']
sourceDir = 'videos\home4.mp4';  % ['videos\home3.mp4', 'videos\lab.mp4', 'videos\amb1low.mp4', 'videos\amb2low.mp4', 'videos\amb1high.mp4', 'videos\amb1high.mp4']
NETWORK_PATH = 'matconvnet-1.0-beta24\models'; 
NET_NAME = 'pascal-fcn8s-dag.mat'; % ['pascal-fcn8s-dag.mat', 'pascal-fcn16s-dag.mat', 'pascal-fcn32s-dag.mat', 'pascal-fcn8s-tvg-dag.mat']
DATA_DIR = fullfile('data', 'images');
RESULT_DIR = fullfile('data', 'unaries');
FLAG_RGB = 'true';
FLAG_RGB_D = 'false';
FLAG_POINT_CLOUD = 'false';


imsub = 0;
depthsub = 0;
pointsub = 0;
if strcmp(source,'simulator')
    if strcmp(connect,'tiago') 
        % Connect  TIAGo robot
        disp('Connecting with TIAGo vitual...');
        setenv('ROS_MASTER_URI','http://192.168.3.129:11311')
        setenv('ROS_IP','192.168.254.1')
        rosinit        
    elseif strcmp(connect,'robot')
        %Tutllebot
        disp('Connecting with TIAGo...');
        ipaddress = '10.68.0.1';%'10.68.0.1';        
        rosinit(ipaddress);    
    elseif strcmp(connect,'turtle')
        %Tutllebot
        disp('Connecting with Tutllebot...');
        ipaddress = '192.168.3.133';
        rosinit(ipaddress);
    end;

    % Get image
    disp('Subscribering with Camera RGB...');
    imsub = 0;
    if ismember('/xtion/rgb/image_raw', rostopic('list'))
        imsub = rossubscriber('/xtion/rgb/image_raw');
    end;

    % Get depth image
    disp('Subscribering with Camera Depth...');
    depthsub = 0;
    if ismember('/xtion/depth_registered/image_raw', rostopic('list'))
        depthsub = rossubscriber('/xtion/depth_registered/image_raw');
    end;

    % Get cloud point
    disp('Subscribering with Cloud Point...');
    pointsub = 0;
    if ismember('/xtion/depth_registered/points', rostopic('list'))
        pointsub = rossubscriber('/xtion/depth_registered/points');
    end;
end;

disp('Initializing Neural Networks...');
[net,normalize_fn] = initializeCNN(NETWORK_PATH, NET_NAME);

% File
if strcmp(source,'file')
    video = VideoReader(sourceDir);
    count = 0;
    for i=0:42 % zero time
        tic
        video.CurrentTime = i;
        image = readFrame(video);
        %image = imread(['results\tiago', int2str(i), '.png']);
        image = imresize(image, [240 320]);
        
        scores = executeCNN(image,net,normalize_fn);
        imshowCNN(image, net, scores,count);
        count = count + 1;
        toc
    end;
end;

frame = 1;
% Robot
while 1
    %load ([sourceDir, num2str(i), '.mat']);
    
    % plot image
    
    if strcmp(FLAG_RGB,'true')
        if imsub ~= 0
            image = receive(imsub);
            image = readImage(image);
            %imshow(image);
            %imwrite(image,['results/tiago',int2str(frame),'.png']);
            image = imresize(image, [240 320]);
            
            frame = frame + 1;
            scores = executeCNN(image,net,normalize_fn);
            imshowCNN(image, net, scores,frame);
        end;
    end;

    % plot depth image
    if strcmp(FLAG_RGB_D,'true')
        if depthsub ~= 0
            depthImage = receive(depthsub);
            figure
            imshow(readImage(depthImage));
        end;
    end;


    % plot cloud points
    if strcmp(FLAG_RGB_D,'true')

        if pointsub ~= 0
            ptcloud = receive(pointsub);
            xyz = readXYZ(ptcloud);
            xyzvalid = xyz(~isnan(xyz(:,1)),:);
            xyzselected = xyz(xyz(:,3)< 2,:);
            %rgb = readRGB(ptcloud);
            scatter3(ptcloud);

            %scatter(xyzselected(:,1),xyzselected(:,2))
            pcobj = pointCloud(readXYZ(ptcloud),'Color',uint8(255*readRGB(ptcloud)));


            % parser cordinates
            minX = min(xyz(:,1));
            maxX = max(xyz(:,1));
            minY = min(xyz(:,2));
            maxY = max(xyz(:,2));
            minZ = min(xyz(:,3));
            maxZ = max(xyz(:,3));

            sizeX = - minX + maxX;
            sizeY = - minY + maxY;
            sizeZ = minZ + maxZ;

            pcshow(pcobj)
            roi = [0,inf;0,inf;0,2.5];
            indices = findPointsInROI(pcobj, roi);
            obj = select(pcobj,indices);

            pcshow(pcobj.Location,'r');
            hold on;
            pcshow(obj.Location,'g');
            hold off;

        end;
    end;
    
%     imwrite(readImage(image),['image',int2str(i),'.png']);
%     Segmentation(readImage(image),['imageContour',int2str(i),'.png']);
%     close(gcf);
%     scatter3(ptcloud);
%     f = getframe(gca);
%     im = frame2im(f);
%     imwrite(im,['ptcloud',int2str(i),'.png']);
    
end;



% Segmentation
seg = readImage(depthImage);
seg(isnan(readImage(depthImage))) = 255; % white
clearImage = seg;
imshow(seg);
seg = edge(seg,'canny');
[H,theta,rho] = hough(seg);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(seg,theta,rho,P,'FillGap',5,'MinLength',7);

% Plot Lines
figure, imshow(readImage(image)), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',5,'Color','red');
   
   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',5,'Color','red');



rosshutdown