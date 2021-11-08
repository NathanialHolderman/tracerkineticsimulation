function mask_img=prep_masks(gm_mask,wm_mask,layers_arr,tcm_fn,cl_fn)
    
    %%%This function prepares a 4D array of mask images 
    %%%The output, 'mask_img', is used as input for subsequent routines
    
    %%%Input/Output:
    %GM_MASK = Binary variable indicating whether or not GM_MASK should be
    %created
    %WM_MASK = Binary variable indicating whether or not WM_MASK should be
    %created
    %LAYERS_ARR = Array indicating grouping of cortical layers for mask
    %TCM_FN = Full path to file for tissue classification maps. Used for
    %wm_mask and/or gm_mask. Default exists.
    %CL_FN = Full path to file for cortical layer probability maps. Used
    %for layers_arr. Default exists. 
    %
    %MASK_IMG = 4D Array of Binary values indicating each mask to be used 
    %
    %   ATH Committed 2021.07.26
    %
    %%%
    
    %Initialize image files with defaults
    if ~exist('tcm_fn','var')
        tcm_fn = 'C:\Matlab\Yale\PETcode\BigBrainFiles\full_cls_400um_2009b_sym.nii';
    end %if exist('tpm_fn','var')
    if ~exist('cl_fn','var')
        cl_fn = 'C:\Matlab\Yale\PETcode\BigBrainFiles\nonlin_masked_surfs_april2019_combined_20_layer_merge.nii';
    end %if exist('cl_fn','var')

    %Load in the TCM files
    tcm_nii=load_nii(tcm_fn);
    tcm_dims=size(tcm_nii.img);
    %Initialize arrays
    gm_img=ones(tcm_dims);
    wm_img=zeros(tcm_dims);
    %Make Individual 3D Masks for GM and WM. This happens no matter what
    if exist('gm_mask','var')
        if gm_mask==1
            tcm_nii=load_nii(tcm_fn);    
            gm_img(:,:,:)=(tcm_nii.img==2|tcm_nii.img==5|tcm_nii.img==6);
        end %if gm_mask==1
    end %if exist('gm_mask','var')
    if exist('wm_mask','var')
        if wm_mask==1
            tcm_nii=load_nii(tcm_fn);    
            wm_img(:,:,:)=(tcm_nii.img==3);
        end %if wm_mask==1
    end%if exist('wm_mask','var')
    
    %Make CL Masks. This only happens if layers_arr exists.
    if exist('layers_arr','var')
        %Below is the threshold to binarize the CL maps (since the default
        %image is probabilistic - i.e. value from 0-1)
        %This could be changed to a user-defined parameter of desired
        bin_thresh=0.5;
        
        %Only load CL if needed - is larger so takes longer
        disp(['Loading ',cl_fn]);
        disp('This could take some time.');
        cl_nii=load_nii(cl_fn);
        disp('Finished.');
        
        %Check to make sure CL map has samd dimensions as the GM/WM Masks
        cl_dims=size(cl_nii.img);
        if tcm_dims ~= cl_dims(1:3)
            disp(['WARNING: ',tcm_fn,' and ',cl_fn,'do not have the same dimensions. QUITTING.'])
            return
        end %if tcm_dims ~= cl_dims(1:3)  
        
        %Check to make sure that layers_arr is correctly configured. 
        layers_arr=layers_arr+1;
        tst_cl=size(layers_arr,1);
        n_cl=size(layers_arr,2);
        if numel(n_cl) > cl_dims(4) || tst_cl~=2
            disp('WARNING: layers_arr is incorrectly configured.')
            disp('It should be a 2XN Array where each row indicates the starting and stopping layer for each of N masks. QUITTING.')
            return
        end %if numel(n_cl) > cl_dims(4) || tst_cl~=2
        
        %Make binary masks for each CL
        cl_img=ones([cl_dims(1:3),n_cl]);
        for c=1:n_cl
           cl_prob=sum(cl_nii.img(:,:,:,layers_arr(1,c):layers_arr(2,c)),4);
           cl_img(:,:,:,c)=cl_prob>=bin_thresh; 
        end % for c=1:n_cl

        %Build final output images
        mask_img=cat(4,gm_img,wm_img,cl_img);
    else % if exist('layers_arr','var')
        %Build final output images
        mask_img=cat(4,gm_img,wm_img);
    end % else exist('layers_arr','var')


end

