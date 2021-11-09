function noise_im = addnoise(image,type,gauss_var_fraction)
    %adds either gaussian or poisson noise to an image
    %for gaussian noise gauss_var_fraction is the amount by which it
    %multiplies each voxel of the image in order to get the variance for
    %the distribution for that image
    if ~any(strcmp(type,{'gaussian','poisson'}))
        error('type needs to be poisson or gaussian')
    end
    if strcmp(type,'gaussian')
        sigma_im = image*gauss_var_fraction;
        noise_im = normrnd(image,sigma_im);
    end
    if strcmp(type,'poisson')
        noise_im = poissrnd(image);
    end