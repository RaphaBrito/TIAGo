function [scores] = executeCNN(image,net,normalize_fn)

    img_normalized = normalize_fn(image);
    
    % Use the net to evaluate the image and extract the variable value for 
    % score
    net.eval({'data', img_normalized}); 
    %net.eval({'data', gpuArray(img_normalized)});  %#GPU
    scores = gather(net.vars(net.getVarIndex('upscore')).value);


end