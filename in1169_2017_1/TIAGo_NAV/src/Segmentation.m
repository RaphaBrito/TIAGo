function [imageSeg, seg] = Test(RGB,name)

%imshow(RGB);
imageSeg = RGB;
I = rgb2gray(RGB);
%bw = imbinarize(I);
[counts,x] = imhist(I,16);
stem(x,counts)
T = otsuthresh(counts);
bw = imbinarize(I,T);
imshow(bw)

% remove all object containing fewer than 30 pixels
bw = bwareaopen(bw,30);

% fill a gap in the pen's cap
se = strel('disk',2);
bw = imclose(bw,se);

% fill any holes, so that regionprops can be used to estimate
% the area enclosed by each of the boundaries
bw = imfill(bw,'holes');

imshow(bw)

[B,L] = bwboundaries(bw,'noholes');

% Display the label matrix and draw each boundary
seg = imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

imshow(imageSeg)
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2,'Color','red')
end

%save image
f = getframe(gca);
im = frame2im(f);
imwrite(im,name);