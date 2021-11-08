function iterated_img=iterate_euler(start_img,k_tbl,templ_csv,templ_img,input_function,t1,t2)
    %This function is intended to take a brain image, k1 and k2 values, and
    %an input function and use euler's method to compute what the next
    %value of the tac should be at each voxel. 
    %start_fn is the filename of the starting image. Should be the same
    %size as templ_img
    %Need to extract k1 and k2 for each brain region, so use same method to
    %extract k_tbl as fill_values
    %k_tbl = n_roix3 table with the columns being roi name, k1, k2
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
    %templ_tbl serves the same role as other functions, should be n_roix3
    %with RHvalues and LHvalues
    icbm_opts=detectImportOptions(templ_csv);
    %columns 2-4 are Label Name, RH, and LH
    icbm_opts.SelectedVariableNames=(2:4);
    templ_tbl=readtable(templ_csv,icbm_opts);    
    %templ_img is used to identify brain regions with templ_tbl, should be
    %same dimensions as start_img
    %input_function should be a Xx2 table with the columns time, value
    %this may change, uncertain of what units to use for now
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
    %load images
    %start_nii = load_nii(start_fn);
    %start_img = start_nii.img;
    %get dimensions of start_img to determine loop size
    start_img_size = size(start_img);

    %nested for loops are surely not the correct way to do this
    for x = 1:start_img_size(1)
        for y = 1:start_img_size(2)
            for z = 1:start_img_size(3)
                %get the k1,k2 values at (x,y,z)
                %First find brain region from templ_img and templ_tbl
                roi_value = templ_img(x,y,z);
                roi_row_templ = templ_tbl(templ_tbl.RHLabel==roi_value,:);
                if isempty(roi_row_templ)
                    roi_row_templ = templ_tbl(templ_tbl.LHLabel==roi_value,:);
                else
                    %leave roi_row_templ the same
                end
                %there are places outside of the rois defined in templ_img
                %Leave them as zero for now
                if isempty(roi_row_templ)
                    new_voxel = 0;
                else
                    roi_name = string(roi_row_templ.(1));
                    %keyboard
                    row_k_tbl = k_tbl(strcmp(k_tbl.LabelName,roi_name),:);
                    k1 = row_k_tbl.k1;
                    k2 = row_k_tbl.k2;
                
                    %find value of input function
                    input_t1_row = input_function(input_function.time==t1,:);
                    input_value_t1 = input_t1_row.(2);
                
                    %update voxel value by euler step
                    current_voxel = start_img(x,y,z);
                    new_voxel = euler_step_1tcm(current_voxel,k1,k2,t1,t2,input_value_t1);
                end
                if rem(x,5) == 0 && y==1 && z==1
                    disp(x);
                end

                start_img(x,y,z) = new_voxel;
            end
        end
    end
    iterated_img = start_img;
                
                
                
    
    