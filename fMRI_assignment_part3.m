function fMRI_secondlevel_Preprocessing_language

% example of first-level implementation for SPM12 
% original scripts: https://github.com/blri/CREx_fMRI
% author of current version: Feng Lin (f.lin@students.uu.nl) 
% date: Mar 28, 2019 

close all; clear all; clc; 

% initialize SPM 
spm('defaults','fmri');
spm_jobman('initcfg');

%%======define parameters in a general structure 'w'=====
w.dataDir  = '/home/feng/Downloads/basicfMRI/1_Data/';  %raw data
w.subjects = {'09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '61','62','64','65','66'}; % without low accuracy ones (parent= dataDir)

w.structDir = 't1'; % structural directory (parent=subject)
w.firstDir = 'stats';
w.secondDir = 'second_level';


DoSecondLevel(w);

end



function DoSecondLevel(w)


matlabbatch{1}.spm.stats.factorial_design.dir = {'/home/feng/Downloads/basicfMRI/1_Data/second_level/picname'};


matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = {
                                                          '/home/feng/Downloads/basicfMRI/1_Data/09/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/10/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/11/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/12/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/13/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/14/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/15/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/16/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/17/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/18/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/61/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/62/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/64/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/65/stats/con_0001.nii,1'
                                                          '/home/feng/Downloads/basicfMRI/1_Data/66/stats/con_0001.nii,1'
                       
                                                          };


matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/home/feng/Downloads/basicfMRI/1_Data/second_level/ExplicitMask.nii,1'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'picname';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

save(fullfile(w.dataDir, w.secondDir, 'SPM12_matlabbatch_1_2ndlevelanalysis.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch); 

end


