function [classes,binArray] = gen_train_data(descriptors,k)
    %% Run KMeans over all Descriptors in dataset
    descriptorArray = cell2mat({descriptors.d})';
    [IDX,~] = kmeans(double(descriptorArray),k,'Distance','cityblock');

    %% Histogram Quantization / Normalization
    numImg =  length(descriptors);
    binArray = zeros(numImg,k);

    idxRangeHigh=0;
    for i = 1:numImg
        numDesc      = size(descriptors(i).d,2);
        idxRangeLow  = idxRangeHigh+1;
        idxRangeHigh = idxRangeLow+numDesc-1;
        Idxs         = IDX(idxRangeLow:idxRangeHigh);
        binArray(i,1:k) = histc(Idxs,1:k);
    end

    %% Make array of classes
    numClasses = length(unique([descriptors.class]));
    classes = repmat([descriptors.class]',1,numClasses)==repmat(1:numClasses,numImg,1);
end





