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

%descriptors=descriptors';

%% generate histograms of descriptors
k=10; %using kmeans with k=10
hists=zeros(10,length(descriptors));
for i=1:length(descriptors)
    IDX=kmeans(double(descriptors(i).f'),10);
    h = histogram(IDX);
    hists(:,i)=(h.Values./length(IDX))'; %populate db of histograms of sift features
end

%% relate to images themselves
%this is being hardcoded because it is specific to the data we have
%classification: 5 classes x 341 images
expected = zeros(5,341);
for i=1:341
    if strcmp(descriptors(i).class,'trilobite')
        expected(1,i)=1;
    elseif strcmp(descriptors(i).class,'nautilus')
        expected(2,i)=1;
    elseif strcmp(descriptors(i).class,'scorpion')
        expected(3,i)=1;
    elseif strcmp(descriptors(i).class,'sea_horse')
        expected(4,i)=1;
    elseif strcmp(descriptors(i).class,'stegosaurus')
        expected(5,i)=1;
    else
        fprintf('Invalid!\n');
    end
end

% once all data is calculated, use neural net wizard to train on the 
% column matrix 'hists', with the expected values in col matrix 'expected'.