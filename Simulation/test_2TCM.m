templ_fn = 'C:\Matlab\Yale\PETcode\icbm_files\rmni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
k_tbl = 'C:\Matlab\Yale\PETcode\Tests\k_values.csv';
templ_tbl = 'C:\Matlab\Yale\PETcode\icbm_files\CerebrA_LabelDetails.csv';
input_function = 'C:\Matlab\Yale\PETcode\Tests\input.csv';
iters = 15;
img_series_2TCM(k_tbl,templ_tbl,templ_fn,input_function,iters);