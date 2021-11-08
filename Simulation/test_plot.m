basefn = 'image';
num = 60;
templ_fn = 'C:\Matlab\Yale\PETcode\icbm_files\rmni_icbm152_CerebrA_tal_nlin_sym_09c.nii';
templ_tbl = 'C:\Matlab\Yale\PETcode\icbm_files\CerebrA_LabelDetails.csv';
input_function = 'C:\Matlab\Yale\PETcode\Tests\input.csv';
roi = 'Putamen';
plotroi(basefn,num,templ_fn,templ_tbl,input_function,roi)