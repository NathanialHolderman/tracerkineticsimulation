function seq_test()
    %img_fn = 'C:\Matlab\Yale\PETcode\Tests\test_img.img';
    zero_img = zeros(493,583,473);
    zero_nii = make_nii(zero_img);
    save_nii(zero_nii,'C:\Matlab\Yale\PETcode\Tests\zero_img');
    img_fn = 'C:\Matlab\Yale\PETcode\Tests\zero_img';
    templ_fn = 'C:\Matlab\Yale\PETcode\icbm_files\rmni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
    k_tbl = 'C:\Matlab\Yale\PETcode\Tests\k_values.csv';
    templ_tbl = 'C:\Matlab\Yale\PETcode\icbm_files\CerebrA_LabelDetails.csv';
    input_function = 'C:\Matlab\Yale\PETcode\Tests\input.csv';
    input = readtable(input_function);
    in = size(input);
    %iters = in(1);
    iters = 10;
    k1_diff1 = 0.1;
    k1_diff2 = -0.1;
    k2_diff1 = 0.1;
    k2_diff2 = -0.1;
    
    %euler_img_matrix_series(img_fn,k_tbl,templ_tbl,templ_fn,input_function,iters);
    img_series_diffcorticol(img_fn,k_tbl,templ_tbl,templ_fn,input_function,iters,k1_diff1,k2_diff1,k1_diff2,k2_diff2);