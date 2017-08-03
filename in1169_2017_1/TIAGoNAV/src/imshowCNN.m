function [image] = imshowCNN(img, net, scores,frame)

    %% Visualize the result
    % Copied from https://github.com/vlfeat/matconvnet-fcn/blob/master/fcnTest.m#L220 
    % First create the colour map for it
%     N=21;
%     cmap = zeros(N,3);
%     for i=1:N
%       id = i-1; r=0;g=0;b=0;
%       for j=0:7
%         r = bitor(r, bitshift(bitget(id,1),7 - j));
%         g = bitor(g, bitshift(bitget(id,2),7 - j));
%         b = bitor(b, bitshift(bitget(id,3),7 - j));
%         id = bitshift(id,-3);
%       end
%       cmap(i,1)=r; cmap(i,2)=g; cmap(i,3)=b;
%     end
%     cmap = cmap / 255;

    % Display the image and it's segmentation side by side
    [~, predicted_labels] = max(scores, [], 3);
%     figure(234);
%     subplot(1,2,1);
%     imshow(img);

    %try
    %    subplot(1,2,2);
    %    imgClusters = image(uint8(predicted_labels-1)) ;
    %    title('clusters') ;
    %    colormap(cmap);
    %    imshow(imgClusters);
    %end;
    
%    subplot(1,2,2);
    imgContours = uint8(predicted_labels-1);
    [counts,x] = imhist(imgContours,16);
    T = otsuthresh(counts);
    bw = imbinarize(imgContours,T);
    holes = bw;
    fator = 2;
    x = 320;
    y = 320;
    [coord] = findHole(holes,x,y, fator);       
    [bw, threshold] = edge(bw, 'sobel');
    imgContoursColor = times(imgContours,uint8(bw));
    [B,L]= bwboundaries(bw);
    imshow(img)
    hold on

    % Object geometry data
    Ilabel = bwlabel(bw);
    %geometry.centroids = regionprops(Ilabel,'centroid');
    %geometry.convexHull = regionprops(Ilabel,'ConvexHull');
    geometry.convexArea = regionprops(Ilabel,'ConvexArea');
    
    
    % draw contours
    for k = 1:length(B)
        boundary = B{k};
        if length(boundary) > 100
            plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2, 'Color', 'red')
        end;
    end;
    
    % draw way
    if strcmp(coord.lines,'one')
        line([coord.xi coord.xf], [coord.yi coord.yf],'LineWidth',5,'color', 'green')
        viscircles([coord.xi coord.yi], [3],'Color','green','LineWidth',7)
        viscircles([coord.xf coord.yf], [3],'Color','green','LineWidth',7)
    else
        line([coord.xi coord.xm], [coord.yi coord.ym],'LineWidth',5,'color', 'green')
        line([coord.xm coord.xf], [coord.ym coord.yf],'LineWidth',5,'color', 'green')
        viscircles([coord.xi coord.yi], [3],'Color','green','LineWidth',7)
        viscircles([coord.xm coord.ym], [3],'Color','green','LineWidth',7)
        viscircles([coord.xf coord.yf], [3],'Color','green','LineWidth',7)
    end;    
    pause(1);

    
%     nCentroids = length(geometry.centroids);
%     for i = 1:nCentroids
%         centroid = geometry.centroids(i);
%         x1 = centroid.Centroid(1)/640;
%         x2 = (x1 + 50)/640;
%         y1 = centroid.Centroid(2)/480;
%         y2 = (y1 + 20)/480;
%         annotation('textbox',...
%         [x1 y1 x2 y2],...
%         'String',net.meta.classes.name(i),...
%         'Color','red');        
%     end;
%     imshow(img);
    
%      f = getframe(gca);
%      im = frame2im(f);
%      imwrite(im,['results/home',int2str(frame),'.png']);
    
end