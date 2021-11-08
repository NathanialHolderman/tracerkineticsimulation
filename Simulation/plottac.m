function plottac(basefn,num,input_function,x,y,z)
    %plot tac of a series of images at a particular voxel
    %basefn should be the base filename and the images should be bsefn_i for i from 1 to num
    %gets time from input function
    %x, y, and z should be the coordinates of the image
    if ~istable(input_function) 
        try 
            infunct_fn=string(input_function);
        catch ME 
            disp('WARNING: The variable k_tbl either needs to be Table object or filename.')
            disp('This variable was neither in this call. Quitting.')
            return
        end 
        input_function=readtable(infunct_fn);
    end
    time = input_function.('time');
    value = [];
    %tic;
    for i = 1:num
        filename = sprintf(join([basefn,'_%d']),i);
        filename_nii = load_nii(filename);
        image = filename_nii.img;
        value(i) = image(x,y,z);
    end
    %toc
    scatter(time(1:num),value)