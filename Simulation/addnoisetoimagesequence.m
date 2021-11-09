function addnoisetoimagesequence(im_name,type,gauss_var_fraction,num)
    %adds noise to a whole sequence of images
    %images should be named im_name_i where i is the number of the images
    %starting at 1 and ending at num
    if ~any(strcmp(type,{'gaussian','poisson'}))
        error('type should be poisson or gaussian')
    end
    for i = 1:num
        filename = sprintf(join([im_name,'_%d']),i);
        filename_nii = load_nii(filename);
        image = filename_nii.img;
        noise_im = addnoise(image,type,gauss_var_fraction);
        newfilename = sprintf(join([im_name,'_',type,'noise','_%d']),i);
        img_nii = make_nii(noise_im);
        save_nii(img_nii,newfilename);
    end
    