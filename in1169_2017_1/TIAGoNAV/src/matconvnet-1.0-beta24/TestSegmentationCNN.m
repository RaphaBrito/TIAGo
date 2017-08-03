%% Info

% Author: Aravindh Mahendran
% Email: aravindh.mahendran[Please remove ]@new{these}.(if you are human)ox.ac.uk

% In this example code I extract unaries from a network trained for
% semantic segmentation.
% It does useful things such as 
% 1. Loading a dag model from a mat file.
% 2. Creating a normalization function that is used to preprocess images at test time
% 3. Evaluate the network on images, one by one 
% 4. Extract the scores from a variable in the DAG.

%% Things to do before you run this script

% 0. Update the path for the matlab setup script below.
% 1. Download the fcn-8s model from the matconvnet website (http://www.vlfeat.org/matconvnet/pretrained/) and update the path in the NETWORK_PATH variable below.
% 2. Put your images in a folder and set the path in DATA_DIR variable
% 3. Create a folder where you would like to store the segmentation unaries and edit the path in RESULT_DIR


%% First setup matconvnet paths using the setup script
run matlab/vl_setupnn.m

%% Load the data and the network

DATA_DIR = fullfile('data', 'images');
RESULT_DIR = fullfile('data', 'unaries');
NETWORK_PATH = 'models';

files = dir(fullfile(DATA_DIR, '*.jpg'));
filenames = {files(:).name}; % All the images are now in a cell array

%% Load the network and setup normalization functions for input images

net = load(fullfile(NETWORK_PATH, 'pascal-fcn8s-dag.mat'));
net = dagnn.DagNN.loadobj(net);
%net.move('gpu'); % Move the network to GPU #GPU 

normalize_fn = @(x) bsxfun(@minus, single(x), net.meta.normalization.averageImage);

%% Run through the images and save the semantic class scores

ts = tic;
for i=1:numel(filenames)
    if(toc(ts) > 1)
        fprintf(1, 'image %d/%d\n', i, numel(filenames));
        ts = tic;
    end
    % Read the image and normalize it
    img = imread(fullfile(DATA_DIR, filenames{i}));
    img_normalized = normalize_fn(img);
    
    % Use the net to evaluate the image and extract the variable value for 
    % score
    net.eval({'data', img_normalized}); 
    %net.eval({'data', gpuArray(img_normalized)});  %#GPU
    scores = gather(net.vars(net.getVarIndex('upscore')).value);
    % The variable name is not always upscore. You'll need to look at the
    % network using net.print and figure out which variable you want.
    
    % Form the output filename and save it in a mat file
    [~, imgname, ~] = fileparts(filenames{i});
    outfilepathname = fullfile(RESULT_DIR, [imgname, '.mat']);
    save(outfilepathname, 'scores');
    
end

%% Visualize the result
% Copied from https://github.com/vlfeat/matconvnet-fcn/blob/master/fcnTest.m#L220 
% First create the colour map for it
N=21;
cmap = zeros(N,3);
for i=1:N
  id = i-1; r=0;g=0;b=0;
  for j=0:7
    r = bitor(r, bitshift(bitget(id,1),7 - j));
    g = bitor(g, bitshift(bitget(id,2),7 - j));
    b = bitor(b, bitshift(bitget(id,3),7 - j));
    id = bitshift(id,-3);
  end
  cmap(i,1)=r; cmap(i,2)=g; cmap(i,3)=b;
end
cmap = cmap / 255;

% Display the image and it's segmentation side by side
for i=1:numel(filenames)
    img = imread(fullfile(DATA_DIR, filenames{i}));
    [~, imgname, ~] = fileparts(filenames{i});
    outfilepathname = fullfile(RESULT_DIR, [imgname, '.mat']);
    load(outfilepathname, 'scores');
    
    [~, predicted_labels] = max(scores, [], 3);
    figure(234);
    subplot(1,2,1);
    imshow(img);

    subplot(1,2,2);
    image(uint8(predicted_labels-1)) ;
    axis image ;
    title('predicted') ;
    colormap(cmap) ;
    drawnow;
    pause(1);
end