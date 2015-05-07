classes = {'trilobite','nautilus','scorpion','sea_horse','stegosaurus'};
idx =1;
descriptors = sift_descriptor.empty;
for i = 1:length(classes)
    classname = char(classes(i));
    p = fullfile('data','caltech101',classname);
    listing = dir(p);
    files = fullfile(p,{listing([listing.isdir]==0).name});
    fprintf('Begining Class: %s\n',classname);
    for j = 1:length(files)
        filename = char(files(j));
        file = single(read_gray(filename));
        fprintf('\tComputing Image: %s   %dx%d\n',char(files(j)),size(file,1),size(file,2));
        [f,d] = vl_sift(file);
        descriptors(idx) = sift_descriptor(filename,classname,f,d);
        idx=idx+1;
    end
end;

descriptors=descriptors';
