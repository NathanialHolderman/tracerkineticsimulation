function Bqcc_tbl=extract_roi_avg(img_fn_list,templ_codes,templ_img,use_lateral,do_coreg,write_csv,mask_code)
    % This function extracts the average roi value for a given input image
    % Useful for subsequent use of make_frame
    %
    % INPUTS:
    %   img_fn_list   = list of filenames for a 3D image volume(s) (Cell Array). 
    %                   Files should be in NIFTI or Analyze format.
    %   templ_codes   = all rois X 3 Table.   
    %                   Column1 is string of ROI names
    %                   Column2 is value of RH Label in icbm_img
    %                   Column3 is value of LH Label in icbm_img
    %   templ_img     = the template image (3D-Array). 
    %                       *Note - to mask these values, write input the
    %                        mask with the templ_img 
    %                        (i.e. templ_img=mask_img(:,:,:,1).*icbm_img);
    %   use_lateral   = a boolean variable. 
    %                   If set to 1, will return different values for each
    %                   hemisphere of the ROI.  
    %   mask_code     = An integer idnetifying mask coding for output
    %                       purposes
    %                       Should be one of the following: 
    %                       1=GM; 2=WM; 3..N=CL# where # is an integer
    %
    %   do_coreg      = a boolean variable. 
    %                   If set to 1, will perform quick coreg to ICBM atlas
    %                   with spm script. 
    %                   NOTE: REQUIRES SPM AND LOCAL SPM LOCATION
    %   write_csv     = a boolean variable/or string
    %                   If set to 1, will write the output table as a csv
    %                   w/ default filename.
    %                   If a string, will write to the string-defined file.
    %
    % OUTPUTS:
    %   Bqcc_tbl      = n_roi X 2+ table.
    %                   This is the output table that is used to fill
    %                   template values to create a simulated image. Its an
    %                   intermediate step that can be saved as a .csv to
    %                   easily manipulate values for future simulations. 
    %
    %                   'LabelName' (REQUIRED) Indicates the name of the
    %                       ROI indicated by the template image
    %                       (*NOTE - blank value indicates the entire mask
    %                       denoted by the mask column)
    %                   'RHValues' (REQUIRED) indicates the value (assumed
    %                       in Bq/cc) of the ROI to be filled
    %                   'LHValues' indicates the value of the LH ROI to be
    %                       filled if ROIs are lateralized
    %                   'Frame' indicates the frame number of the image
    %                   'MaskCode' indicates whether or not the masking
    %                       image should be used to generate the image. See the
    %                       'mask_code' variable above. 

    %Check input fn for char array; if not then convert
    if isstring(img_fn_list) || ischar(img_fn_list)
       img_fn_list={img_fn_list}; 
    end %if isstring(img_fn_list) || ischar(img_fn_list)
    
    %Initialize Arrays
    n_rois=height(templ_codes);
    LabelName=templ_codes.LabelName;    
    n_frames=length(img_fn_list);  
    
    for f=1:n_frames
        img_fn=img_fn_list{f};
        Frame=f*ones(n_rois,1);
            
        %If flagged to do the coregistration use SPM Batch below
        if do_coreg==1
            %SPM Defaults
            spm_path='C:\Matlab\Yale\spm12';
            addpath(spm_path);
            spm('Defaults','pet');
            spm_jobman('initcfg');

            %Run the Matlab Batch. Estimate and write temporary file 
            %%% TO DO - Be smarter about writing temporary file
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref={templ_fn_in};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source={img_fn};
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun='nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm=[5 5];
            spm_jobman('run',matlabbatch(1)); 
            [f_in_pth,f_in_nam,f_in_ext]=spm_fileparts(img_fn);
            img_fn=strjoin({f_in_pth,'\r',f_in_nam,f_in_ext},'');
        end%if do_coreg=1 

        % Read in files
        img_in_nii=load_nii(img_fn);
        

        if use_lateral==1
            RHValues=zeros(n_rois,1);
            LHValues=zeros(n_rois,1);
            for r=1:n_rois
                RHValues(r)=mean(img_in_nii.img(templ_img==templ_codes.RHLabel(r)));
                LHValues(r)=mean(img_in_nii.img(templ_img==templ_codes.LHLabel(r)));

            end %for r n_rois
            Bqcc_tbl=table(LabelName,RHValues,LHValues,Frame);
        else
            RHValues=zeros(n_rois,1);
            for r=1:n_rois
                RHValues(r,1)=mean(img_in_nii.img(templ_img==templ_codes.RHLabel(r)|templ_img==templ_codes.LHLabel(r)));
                
            end %for r n_rois
            Bqcc_tbl=table(LabelName,RHValues,Frame);
        end %if/else use_lateral==1
        if exist('mask_code','var')
            codes=mask_code*ones(n_rois,1);
            Bqcc_tbl.MaskCode=codes;
        end %if exist('mask_code','var')
    end %for f=1:n_frames
    
    %If flagged, write the table as a csv
    if exist('write_csv','var')
        if write_csv==1 
            fn_str=string(img_fn_list{1});
            output_fn=strrep(fn_str,fn_str(end-3:end),'.csv');
        else %if write_csv==1 
            output_fn=string(write_csv);
        end %else write_csv==1
        writetable(Bqcc_tbl,output_fn);
    end %if exist('write_csv','var')
end % function extract_roi_avg_Bqcc