function img = read_gray(filename)
    img = imread(filename);
    if(size(img,3)>1)
        img=rgb2gray(img);
    end
end

