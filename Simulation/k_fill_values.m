function k_fill_values=k_fill_values(k_tbl,templ_tbl,templ_img,output_fn)
    %need to debug fill_values so this is a simple version for making k
    %images
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
    image = zeros(size(templ_img));
    for i = 1:length(k_tbl.LabelName)
        im_addR = templ_img == templ_tbl.RHLabel(i);
        im_addL = templ_img == templ_tbl.LHLabel(i);
        im_addR = im_addR*k_tbl.RHValues(i);
        im_addL = im_addL*k_tbl.RHValues(i);
        image = image + im_addR;
        image = image + im_addL;
    end
    if exist(output_fn)
        image_nii = make_nii(image);
        save_nii(image_nii, output_fn);
    end
    k_fill_values=image;