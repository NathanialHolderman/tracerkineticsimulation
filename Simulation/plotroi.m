function plotroi(basefn,num,templ_fn,templ_csv,input_function,roiname)
    %plot tac of a particular region
    %find a voxel in that region
    templ_nii = load_nii(templ_fn);
    templ_img = templ_nii.img;
    icbm_opts=detectImportOptions(templ_csv);
    icbm_opts.SelectedVariableNames=(2:4);
    templ_tbl=readtable(templ_csv,icbm_opts);
    index = find(strcmp(templ_tbl.LabelName,roiname));
    roi_image = templ_img == templ_tbl.RHLabel(index);
    [a,b] = max(roi_image(:));
    [x,y,z] = ind2sub(size(roi_image),b);
    %plot
    plottac(basefn,num,input_function,x,y,z)
    keyboard