function img_sim=fill_values(Bqcc_tbl,templ_tbl,templ_img,bkgd,output_fn,mask_img)
    % This function fills the values of a simulated 3D frame given activity concentrations 
    %   for a list of ICBM regions
    %
    % INPUTS:
    %   Bqcc_tbl      = n_roi X 2+ table. REQUIRED. 
    %                   This is the output table that is used to fill
    %                   template values to create a simulated image. Its an
    %                   intermediate step that can be saved as a .csv to
    %                   easily manipulate values for future simulations. 
    %                   See 'extract_roi_avg.m' for more details. 
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
    %
    %   templ_tbl    = an n_roi X 2+ table of the template values used.
    %                   REQUIRED.
    %
    %                   'LabelName' (REQUIRED) Indicates the name of the
    %                       ROI indicated by the template image
    %                       (*NOTE - blank value indicates the entire mask
    %                       denoted by the mask column)
    %                   'RHValues' (REQUIRED) indicates location of ROI using icbm codes                     
    %                   'LHValues' (REQUIRED) indicates location of ROI
    %                   using icbm codes
    %
    %   temp1_img      = 3D array of integers with values corresponding to ROIs
    %                       in the icbm_codes list. 
    %                       Ideally this is masked with whatever (GM, BB Atlas, Etc) 
    %                       prior to passing into this function
    %
    %   mask_img       = a 4D array of images corresponding to the masks to
    %                       be applied to image generation. 
    %                       Corresponds to the 'MaskCode' column in
    %                       Bqcc_tbl.    
    %   
    %   bkgd           = an integer indicating the value of simulated 
    %                       background activity.   
    %
    %   output_fn      = a string indicating the location for the output
    %                       filename.
    %
    % OUTPUTS:
    %   img3d_out      = 3D array of activity concentrations that should simulate 
    %                       1 frame for a given radiotracer
    %
    % ATH Committed 2021.07.26
    % ATH Added comments for clarity 2021.09.13
    
    %Check to see if input is table or filename
    if ~istable(Bqcc_tbl) 
        try 
            Bqcc_fn=string(Bqcc_tbl);
        catch ME %#ok<NASGU>
            disp('WARNING: The variable Bqcc_tbl either needs to be Table object or filename.')
            disp('This variable was neither in this call. Quitting.')
            return
        end %try string(Bqcc_tbl)
        Bqcc_tbl=readtable(Bqcc_fn);
    end
   
    %If Bkgd variable is not set then set it equal to zero
    if ~exist('bkgd','var')
        bkgd=0;
    end %if ~exist('bkgd','var')
    
    %smoothing element to open/close image
    r_se=1;
    se=strel('sphere',r_se);

    %Below are formatting checks for the Bqcc_tbl if optional columns are
    %not included
    Columns=Bqcc_tbl.Properties.VariableNames;
    %If no frame column add a single column where Frame=1
    if sum(strcmp('Frame',Columns),'all')==0 
        Bqcc_tbl.Frame=ones(length(Bqcc_tbl.LabelName),1);  
    end %if sum(strcmp('Frame',Columns),'all')==0 
    %If no maskcode column add a single column where Frame=1
    if sum(strcmp('MaskCode',Columns),'all')==0 
        Bqcc_tbl.MaskCode=ones(length(Bqcc_tbl.LabelName),1);  
        mask_img=ones(size(templ_img));
    end %if sum(strcmp('Frame',Columns),'all')==0 
    
    %Initialize simulated image as 4D array with 'frames' frames
    frames=unique(Bqcc_tbl.Frame);
    img_sim=bkgd*ones([size(templ_img),length(frames)]);
    
    %Loop where the magic happens
    for f=1:length(frames)                          %Loop through each frame
        img3d_temp=zeros(size(templ_img));          %Temporary 3d Array
        f_idx=Bqcc_tbl.Frame==frames(f);            %Index the frame #
        %Determine how many masks we need to create/fill
        masks=unique(Bqcc_tbl(f_idx,:).MaskCode); 
        for m=1:length(masks)                       %Loop through each mask
            m_idx=Bqcc_tbl.MaskCode==masks(m);      %Index the mask #
            %Determine how many ROIs we need to create/fill
            rois=unique(Bqcc_tbl(f_idx&m_idx,:).LabelName);
            for r=1:length(rois)                    %Loop through each ROI
                %If no ROIs are specified, just fill the entire mask below
                if isempty(rois{1})
                    img3d_temp(mask_img(:,:,:,m)==1)=Bqcc_tbl(f_idx&m_idx,:).RHValues;
                else %if isempty(rois{1})               
                    code_row=strcmp(rois{r},templ_tbl.LabelName);
                    if sum(code_row)==0
                        disp(['Failed to find ROI ',rois(r), ' in ICBM template.'])
                    else %if/else sum(code_row)==0
                        %Use an open/close operation with se to create
                        %binary image of masked ROI 
                        temp_bin_img=imclose(templ_img==templ_tbl(code_row,:).RHLabel,se);
                        %temp_bin_img=imclose(templ_tbl(code_row,:).RHLabel,se);
                        %Fill temporary image with the Table-specified
                        %value for and the mask ROI
                        img3d_temp(temp_bin_img.*mask_img(:,:,:,m)==1)=Bqcc_tbl(f_idx&m_idx,:).RHValues(r); %RHLabel
                        
                        %Repeat for the LH Definition
                        temp_bin_img=imclose(templ_tbl(code_row,:).LHLabel,se);
                    
                        %Below - Fills LH Values - accounts for whether or not
                        %this is filled 
                        lh_exist=strcmp('LHValues',Bqcc_tbl.Properties.VariableNames);
                        if sum(lh_exist)==1
                            img3d_temp(temp_bin_img.*mask_img(:,:,:,m)==1)=Bqcc_tbl(f_idx&m_idx,:).LHValues(r); %LHLabel
                        else %if sum(lh_exist)==1
                            img3d_temp(temp_bin_img.*mask_img(:,:,:,m)==1)=Bqcc_tbl(f_idx&m_idx,:).RHValues(r); %LHLabel
                        end %if sum(lh_exist)==1                   
                    end %if/else sum(code_row)==0    
                end %if/else isempty(rois{1})
            end %for r rois
        end %for m masks
        img_sim(:,:,:,f)=img3d_temp;
    end %for f frames

    if exist('output_fn','var')
        img_nii = make_nii(img_sim)
        save_nii(img_nii,output_fn);
    end
end %function make_frame