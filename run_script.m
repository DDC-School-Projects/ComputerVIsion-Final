classes = {'trilobite','nautilus','scorpion','sea_horse','stegosaurus'};
descriptors=calculate_features(classes);
[classArray,binArray] = gen_train_data(descriptors,10);