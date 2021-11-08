function iterated_imgs=iterate_euler_matrix_2TCM(c1_img,c2_img,k1_img,k2_img,k3_img,k4_img,input_value,t1,t2)
    %requires free and bound compartments so probably only useful for
    %starting at time zero
    %Uses euler step with 2 tissue compartment model
    %c1' = k1*cp - (k2+k3)*c1 + k4*c2
    %c2' = k3*c1 - k4*c2
    k_23_img = k2_img + k3_img;
    c1_derivative = k1_img*input_value - k_23_img.*c1_img + k4_img.*c2_img;
    c2_derivative = k3_img.*c1_img - k4_img.*c2_img;
    c1_img_new = c1_img + (t2-t1)*c1_derivative;
    c2_img_new = c2_img + (t2-t1)*c2_derivative;
    new_img = c1_img_new + c2_img_new;
    iterated_imgs(:,:,:,1) = c1_img_new;
    iterated_imgs(:,:,:,2) = c2_img_new;
    iterated_imgs(:,:,:,3) = new_img;