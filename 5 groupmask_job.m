%-----------------------------------------------------------------------
% Job saved on 28-Mar-2019 16:22:43 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%%

close all; clear all; clc; 

% initialize SPM 
spm('defaults','fmri');
spm_jobman('initcfg');


matlabbatch{1}.spm.util.imcalc.input = {
                                        '/home/feng/Downloads/basicfMRI/1_Data/09/t1/wsub09_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/10/t1/wsub10_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/11/t1/wsub11_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/12/t1/wsub12_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/13/t1/wsub13_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/14/t1/wsub14_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/15/t1/wsub15_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/16/t1/wsub16_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/17/t1/wsub17_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/18/t1/wsub18_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/61/t1/wsub61_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/62/t1/wsub62_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/64/t1/wsub64_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/65/t1/wsub65_t1-0001.nii,1'
                                        '/home/feng/Downloads/basicfMRI/1_Data/66/t1/wsub66_t1-0001.nii,1'
                                        };
%%
matlabbatch{1}.spm.util.imcalc.output = 'ExplicitMask';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14+i15)/15';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

spm_jobman('initcfg');
spm_jobman('run',matlabbatch);  
