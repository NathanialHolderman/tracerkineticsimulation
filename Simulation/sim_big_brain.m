function sim_big_brain(roi_Bqcc_list,bkgd_val,gm_mask,wm_val,cl_break)

    %%% FIRST MODULE - GENERATE TABLE OF ROI VALUES %%%
    %fn_tacs_in - File use to generate table of TACs to fill in 
    %Can either be 

    mask_img = prep_masks(1,1,[0,3;4,6]);
      
    %Below is list of files that are read in for these analyses. 
    %Would need to be edited for whatever local version a person is running
    %ICBM Atlas Resliced to Big Brain VoxelSize
    %icbm_fn='C:\Users\ansel\Desktop\BigBrain\icbm_temp.nii';
    icbm_fn='C:\Matlab\Yale\PETcode\icbm_files\mni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
    %ICBM CSV File
    %icbm_csv='C:\Users\ansel\Desktop\BigBrain\icbm_files\CerebrA_LabelDetails.csv';
    icbm_csv = 'C:\Matlab\Yale\PETcode\icbm_files\CerebrA_LabelDetails.csv';

    %Read in the icbm atlas
    icbm_nii=load_nii(icbm_fn);
    icbm_opts=detectImportOptions(icbm_csv);
    %ICBM List: Column 1 Mindboggle ID (??)
    %ICBM List: Column 2 ICBM Label Name
    %ICBM List: Column 3 ICBM RH Label No
    %ICBM List: Column 4 LCBM LH Label No
    %ICBM ListL Column 5 Dice Kappa (??)
    icbm_opts.SelectedVariableNames=(2:4); %Hard coded specifically for the icbm_csv document
    icbm_codes=readtable(icbm_csv,icbm_opts);
    
    %Section to be edited - allow for img_fn_in to be a list of file names
    %Add time dimension to this
    icbm_img=icbm_nii.img;
    img_fn_list={'C:\Users\ansel\Desktop\BigBrain\rsdm8_vc_mc_sum_40_60.img'};
    %roi_Bqcc_list=extract_roi_avg(img_fn_list,icbm_codes,icbm_img,1,1,0);
   

    %pp_IF=get_if();
    %kin_param_in=[ 0.4,0.1,0.03,0.01;...
    %               0.4,0.1,0.05,0.01];
    %frame_times=[   0.5, 0.75;...
    %                5.0, 6.0;...
    %                60.0,65.0];
    %roi_Bqcc_list=simulate_tacs(pp_IF,kin_param_in,frame_times);
    %img3d_out=fill_values(roi_Bqcc_list,icbm_codes,icbm_nii.img,0);
    foo=detectImportOptions('test_mask.csv');
    bar=readtable('test_mask.csv',foo);

    img3d_out=fill_values(bar,icbm_codes,icbm_nii.img,mask_img,0);
    foo=icbm_nii;
    foo.img=img3d_out;
    save_nii(foo,'test_sim_out.nii');
     
    keyboard;
end %function MAIN sim_big_brain

