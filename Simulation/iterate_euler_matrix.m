function iterated_img=iterate_euler_matrix(start_img,k1_img,k2_img,input_value,t1,t2)
    %same setup as iterate_euler except doing it through matrices only for
    %efficiency

    %Make euler step matrix
    %y' = k1*Cp - k2y
    %Cp is plasma compartment and y is tissue compartment
    %Euler approx is y(t2) ~= y(t1) + (t2-t1)*y'(t1)
    y_derivative = k1_img*input_value - k2_img.*start_img;
    iterated_img = start_img + (t2-t1)*y_derivative;
    
    
    