% Save data in structrure
clear all;
connect = 'tiago';      % ['turtle','tiago'] 


if strcmp(connect,'tiago') 
    % Connect  TIAGo robot
    setenv('ROS_MASTER_URI','http://192.168.3.129:11311')
    setenv('ROS_IP','192.168.254.1')
    rosinit
elseif strcmp(connect,'turtle')
    %Tutllebot
    ipaddress = '192.168.3.133';
    rosinit(ipaddress);
end;


% Get image
imsub = 0;
if ismember('/xtion/rgb/image_raw', rostopic('list'))
    imsub = rossubscriber('/xtion/rgb/image_raw');
end;

% Get depth image
depthsub = 0;
if ismember('/xtion/depth_registered/image_raw', rostopic('list'))
    depthsub = rossubscriber('/xtion/depth_registered/image_raw');
end;

% Get cloud point
pointsub = 0;
if ismember('/xtion/depth_registered/points', rostopic('list'))
    pointsub = rossubscriber('/xtion/depth_registered/points');
end;


count = 0;
disp('Saving...');
for i=1:50
    count = count + 1

    % plot image
    if imsub ~= 0
        image = receive(imsub);
        %imageData(count) = image;
    end;

    % plot depth image
    if depthsub ~= 0
        depthImage = receive(depthsub);
        %depthImageData(count) = depthImage;  
    end;
    
    % plot cloud points
    if pointsub ~= 0
        ptcloud = receive(pointsub);
        %ptcloudData(count) = ptcloud;
    end;

    %save gazeboData image depthImage ptcloud;
    save(['gazeboData', num2str(count), '.mat'], 'image', 'depthImage', 'ptcloud');
end;

%disp('Saving...');
%save gazeboData imageData depthImageData ptcloudData;

rosshutdown
