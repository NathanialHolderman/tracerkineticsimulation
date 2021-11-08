function img_series_2TCM(k_tbl,templ_csv,templ_fn,input_function,iters)
    templ_nii = load_nii(templ_fn);
    templ_img = templ_nii.img;
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
    k_array = table2array(k_tbl(:,2:5));
    name_array = table2array(k_tbl(:,1));
    k1_tbl = table(name_array,k_array(:,1),'VariableNames',{'LabelName','RHValues'});
    k2_tbl = table(name_array,k_array(:,2),'VariableNames',{'LabelName','RHValues'});
    k3_tbl = table(name_array,k_array(:,3),'VariableNames',{'LabelName','RHValues'});
    k4_tbl = table(name_array,k_array(:,4),'VariableNames',{'LabelName','RHValues'});
    k1_img = k_fill_values(k1_tbl,templ_tbl,templ_img, 'k1_img');
    k2_img = k_fill_values(k2_tbl,templ_tbl,templ_img, 'k2_img');
    k3_img = k_fill_values(k3_tbl,templ_tbl,templ_img, 'k3_img');
    k4_img = k_fill_values(k4_tbl,templ_tbl,templ_img, 'k4_img');
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
    %Do first iteration from 0
    zero_img = zeros(size(templ_img));
    input_1 = input_function.('value')(1);
    t1 = input_function.('time')(1);
    t2 = input_function.('time')(2);
    first_iteration = iterate_euler_matrix_2TCM(zero_img,zero_img,k1_img,k2_img,k3_img,k4_img,input_1,t1,t2);
    filename = '2TCM_image_1';
    img_nii = make_nii(first_iteration(:,:,:,3));
    save_nii(img_nii,filename);
    sprintf('iteration 1 done')
    c1 = first_iteration(:,:,:,1);
    c2 = first_iteration(:,:,:,2);
    for i=2:(iters-1)
        %get t1 and t2 for this iteration
        t1 = input_function.('time')(i);
        t2 = input_function.('time')(i+1);
        %get input_value at time t1 from input function
        input_value = input_function.('value')(i);
        %call iterate_euler_matrix to get iterated image
        next_imgs = iterate_euler_matrix_2TCM(c1,c2,k1_img,k2_img,k3_img,k4_img, input_value,t1,t2);
        %update c1 and c2
        c1 = next_imgs(:,:,:,1);
        c2 = next_imgs(:,:,:,2);
  
        %save new image
        filename = sprintf('2TCM_image_%d',i);
        img_nii = make_nii(next_imgs(:,:,:,3));
        save_nii(img_nii,filename);
        sprintf('iteration %d done',i)
    end