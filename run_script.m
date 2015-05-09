classes = {'trilobite','nautilus','scorpion','sea_horse','stegosaurus'};
if(~exist('descriptors','var'))
  descriptors=calculate_features(classes);
else
    fprintf('Skipping Descriptor Calculation\n');
end;
fprintf('Generating Training Data\n');
[classArray,binArray] = gen_train_data(descriptors,20,1000);