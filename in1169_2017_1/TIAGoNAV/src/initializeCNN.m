function [net,normalize_fn] = initializeCNN(NETWORK_PATH, NET_NAME);

run matconvnet-1.0-beta24/matlab/vl_setupnn.m

%% Load the network and setup normalization functions for input images

net = load(fullfile(NETWORK_PATH, NET_NAME));
net = dagnn.DagNN.loadobj(net);
%net.move('gpu'); % Move the network to GPU #GPU 

normalize_fn = @(x) bsxfun(@minus, single(x), net.meta.normalization.averageImage);

end