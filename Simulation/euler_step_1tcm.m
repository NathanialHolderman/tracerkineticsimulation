function euler_step=euler_step_1tcm(initial_value,k1,k2,t1,t2,input_value)
    %performs euler approximation for next step using 1TCM equation
    %y' = k1*Cp - k2y
    %Cp is plasma compartment and y is tissue compartment
    %Euler approx is y(t2) ~= y(t1) + (t2-t1)*y'(t1)
    y_derivative = k1*input_value - k2*initial_value;
    euler_step = initial_value + (t2-t1)*y_derivative;
    