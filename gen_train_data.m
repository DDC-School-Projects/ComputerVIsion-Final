function [classes,binArray] = gen_train_data(descriptors,k,subsamples)
    distTypeKmeans='sqeuclidean';
    distTypeKNN   ='euclidean';
    
    rng('default');
    %% Run KMeans over all Descriptors in dataset
    fprintf('Running KMeans\n\t K: %d    Samples: %d\n',k,subsamples);
    descriptorArray = cell2mat({descriptors.d})';
    descriptorArray = descriptorArray(randperm(size(descriptorArray,1),subsamples),:);
    [~,means] = kmeans(double(descriptorArray),k,'Distance',distTypeKmeans);
    %% Histogram Quantization / Normalization
    fprintf('Performing Histogram Quantization:      ');
    numImg =  length(descriptors);
    binArray = zeros(numImg,k);
    for i = 1:numImg
        fprintf('\b\b\b\b\b\b%5d%%',uint8(i/numImg*100));
        d    = double(descriptors(i).d');
        Idxs = knnsearch(means,d,'Distance',distTypeKNN);
        binArray(i,1:k) = histc(Idxs,1:k);
    end
    normr(binArray);
    fprintf('\n');

    %% Make array of classes
    fprintf('Generating Class List\n');
    numClasses = length(unique([descriptors.class]));
    classes = repmat([descriptors.class]',1,numClasses)==repmat(1:numClasses,numImg,1);
end





