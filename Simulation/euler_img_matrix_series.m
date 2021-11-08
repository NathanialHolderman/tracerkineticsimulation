function euler_img_matrix_series(start_fn,k_tbl,templ_csv,templ_fn,input_function,iters)
    start_nii = load_nii(start_fn);
    start_img = start_nii.img;
    templ_nii = load_nii(templ_fn);
    templ_img = templ_nii.img;
    %test for same size image as template
    if size(start_img) ~= size(templ_img)
        error('Image and template not same dimensions.')
    end
    %fill any unfilled values with 0
    start_img(isnan(start_img)) = 0;
    templ_img(isnan(templ_img)) = 0;
    if ~istable(k_tbl) 
        try 
            k_fn=string(k_tbl);
        catch ME 
            disp('WARNING: The variable k_tbl either needs to be Table object or filename.')
            disp('This variable was neither in this call. Quitting.')
            return
        end 
        k_tbl=readtable(k_fn);
    end   
    icbm_opts=detectImportOptions(templ_csv);
    icbm_opts.SelectedVariableNames=(2:4);
    templ_tbl=readtable(templ_csv,icbm_opts); 
    %Extract k1 and k2 values from k_tbl and make Bqcc_tbl format for
    %fill_values
    k_array = table2array(k_tbl(:,2:3));
    name_array = table2array(k_tbl(:,1));
    %make new k1 and k2 tables
    k1_tbl = table(name_array,k_array(:,1),'VariableNames',{'LabelName','RHValues'});
    k2_tbl = table(name_array,k_array(:,2),'VariableNames',{'LabelName','RHValues'});
    %run fill_values to create k1 and k2 images
    k1_img = k_fill_values(k1_tbl,templ_tbl,templ_img, 'k1_img');
    k2_img = k_fill_values(k2_tbl,templ_tbl,templ_img, 'k2_img');
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
    %make 4D array to hold image sequence
    %loop through iters performing Euler step then adding the image to
    %img_sequence
    for i=1:(iters-1)
        %get t1 and t2 for this iteration
        t1 = input_function.('time')(i);
        t2 = input_function.('time')(i+1);
        %get input_value at time t1 from input function
        input_value = input_function.('value')(i);
        %call iterate_euler_matrix to get iterated image
        next_img = iterate_euler_matrix(start_img, k1_img,k2_img, input_value,t1,t2);
  
        %save new image
        filename = sprintf('image_%d',i);
        img_nii = make_nii(next_img);
        save_nii(img_nii,filename);
        %update start_img for next iteration
        start_img = next_img;
        sprintf('iteration %d done',i)
    end
    