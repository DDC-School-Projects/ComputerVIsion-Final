function descriptors = calculate_features(classes)
    idx =1;
    descriptors = sift_descriptor.empty;
    for i = 1:length(classes)
        classname = char(classes(i));
        p = fullfile('data','caltech101',classname);
        listing = dir(p);
        files = fullfile(p,{listing([listing.isdir]==0).name});
        fprintf('Computing Features for Class: %s\n',classname);

        for j = 1:length(files)
            filename = char(files(j));
            file = single(read_gray(filename));
            [f,d] = vl_sift(file);
            descriptors(idx) = sift_descriptor(filename,classname,i,f,d);
            idx=idx+1;
        end

    end;
end
