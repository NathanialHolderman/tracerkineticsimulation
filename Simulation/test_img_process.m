function test=test_img_process()

    %take real image then extract roi averages then return image where each
    %roi is filled with the extracted average values
    
    %mask_img = prep_masks(1,1,[0,3;4,6]);
    
    %arguments for extract_roi_values
    
    %image file to extract
    img_fn = 'C:\Matlab\Yale\PETcode\resliced_nonlinear_1T_v6_pet_DV_1T_v6_90_in_MNI2.img';
    %img_fn = 'C:\Matlab\Yale\PETcode\icbm_files\rmni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
    %for templ_codes need to extract relevant columns from a csv
    %see sim_big_brain.m for this process
    icbm_csv = 'C:\Matlab\Yale\PETcode\icbm_files\CerebrA_LabelDetails.csv';
    icbm_opts=detectImportOptions(icbm_csv);
    %columns 2-4 are Label Name, RH, and LH
    icbm_opts.SelectedVariableNames=(2:4);
    icbm_codes=readtable(icbm_csv,icbm_opts);
    %for templ_img need to extract .nii file into a 3D array
    %icbm_templ_fn = 'C:\Matlab\Yale\PETcode\icbm_files\rmni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
    icbm_templ_fn = 'C:\Matlab\Yale\PETcode\icbm_files\mni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
    
    %icbm_templ_fn = 'C:\Matlab\Yale\PETcode\icbm_files\aalmni_2mm_V5.img';
    %icbm_templ_fn = 'C:\Matlab\Yale\PETcode\BigBrainFiles\icbm_resl_400um.nii';
    icbm_nii=load_nii(icbm_templ_fn);
    icbm_img = icbm_nii.img;
    keyboard
    %mask_templ_img = mask_img(:,:,:,1).*icbm_img;
    %for now choose uselateral=1, mask codes 1-7, and not to do coreg
    uselateral = 1;
    maskcode = 1;
    docoreg = 0;
    %filename for writing out roi averages
    writecsv = 'test';
    %keyboard
    
    %roi_avg_tbl = extract_roi_avg(img_fn,icbm_codes,mask_templ_img,uselateral,docoreg,writecsv);
    roi_avg_tbl = extract_roi_avg(img_fn,icbm_codes,icbm_img,uselateral,docoreg,writecsv);
    %keyboard
    %Now run fill_values.m
    %arguments for fill_values
    %roi_avg_tbl is the Bqcc_tbl
    %icbm_codes can be used again for templ_tbl and icbm_img again for
    %templ_img
    background = 0;
    output='test_img';
    %generate mask_img
    
    test = fill_values(roi_avg_tbl,icbm_codes,icbm_img,background);
    
    
    
    
    
    