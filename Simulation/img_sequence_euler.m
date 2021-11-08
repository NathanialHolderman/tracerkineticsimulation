    function img_sequence_euler=img_sequence_euler(start_fn,k_tbl,templ_tbl,templ_fn,input_function,iters,output_fn)
    %Function to perform euler step a number of times to get a time series
    %of images
    %start_fn is filename of starting image
    %templ_fn is filename of template image
    %extract both for iterate_euler
    start_nii = load_nii(start_fn);
    start_img = start_nii.img;
    templ_nii = load_nii(templ_fn);
    templ_img = templ_nii.img;
    
    %for now, replace any nan in start_img and templ_img with 0
    start_img(isnan(start_img)) = 0;
    templ_img(isnan(templ_img)) = 0;
    
    %k_tbl is table of k-values by roi. Should be n_roisx3 with columns
    %LabelName, k1, k2
    %templ_tbl is table for template regions should have columns LabelName,
    %RHValues, LHValues
    %input_function should be an Xx2 table of values of your input
    %function with columns time, value
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
    %load i
    %iters is number of iterations, should not exceed number of time points
    %of input_function-1
    
    %Create 4d array to hold each image with the 4th index being iteration
    %number (notably not time)
    [xdim, ydim, zdim] = size(start_img);
    img_sequence = zeros(xdim, ydim, zdim, iters);
    %start_img is first image in img_sequence
    img_sequence(:,:,:,1) = start_img;
    
    %loop through iters performing Euler step then adding the image to
    %img_sequence
    for i=1:iters
        %get t1 and t2 for this iteration
        t1 = input_function.('time')(i);
        t2 = input_function.('time')(i+1);
        %call iterate_euler to get iterated image
        next_img = iterate_euler(start_img, k_tbl, templ_tbl, templ_img, input_function,t1,t2);
        %add next_img to img_sequence at position i+1 (because first image
        %is the starting image
        img_sequence(:,:,:,i+1) = next_img;
        %update start_img for next iteration
        start_img = next_img;
    end
    %save if output_fn exists
    if exist('output_fn')
        img_nii = make_nii(img_sequence);
        save_nii(img_nii,output_fn);
    end
    img_sequence_euler = img_sequence;
    
    