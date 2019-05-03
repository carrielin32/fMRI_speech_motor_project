function fMRI_firstlevel_Preprocessing_language

% example of first-level implementation for SPM12 
% original scripts: https://github.com/blri/CREx_fMRI
% author of current version: Feng Lin (f.lin@students.uu.nl) 
% date: Mar 5, 2019 

close all; clear all; clc; 

% initialize SPM 
spm('defaults','fmri');
spm_jobman('initcfg');

%%======define parameters in a general structure 'w'=====
w.dataDir  = '/Users/carrielin/Documents/MATLAB/speech_motor_project/1_Data/';  %raw data
w.subjects = {'2','3', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','19','20'}; % without low accuracy ones (parent= dataDir)

w.structDir = 't1'; % structural directory (parent=subject)
w.sessions = {'run1','run2','run3','run4'}; %session directory (parent=subject)

%% parameters from EPI files 
w.nSlices = 36;  %number of slices 
w.TR = 2;  %repetition time (s)
w.thickness = 3; % slice thickness (mm)

%%========================================================
% loop on subjects 
    for iS=1:numel(w.subjects) 
        fprintf('=========================/n');
        fprintf([w.subjects{iS} 'First level.../n']);
 
    
    w.subName = w.subjects{iS};
    w.subPath = fullfile(w.dataDir, w.subjects{iS});
    w.structPath = fullfile(w.subPath, w.structDir);
    w.firstDir = fullfile(w.subPath, 'stats');

    cd(w.subPath);
    
    %%======== do first level =================

DoFirstLevel(w);

%%========================================================
    end 
end



function DoFirstLevel(w)

    clear matlabbatch;
    matlabbatch{1}.spm.stats.fmri_spec.dir = {w.firstDir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 36;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 36;
    
   

    %session 1 -- syllable 
    %matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(spm_select('ExtFPList',  fullfile(w.subPath, 'picnam', '^swua','.*\.nii$', Inf)));
    EPI_1 = spm_select('ExtFPList',  fullfile(w.subPath,'run1'), ['^swua' '.*' '.*\.nii$'], Inf);
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(EPI_1);
   
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'syllable1';
   % matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = [6
   %                                                             54
   %                                                             136
   %                                                             209
   %                                                             275];
   % 这里插入multiple condition file for each subject for each session  
   % matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = [27 
   %                                                                38 
   %                                                                39 
   %                                                                44 
   %                                                                16];
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    rpF1=spm_select('FPList', fullfile(w.subPath, 'run1'),['^rp' '.*\.txt$']);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = cellstr(rpF1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = Inf;

    %session 2 -- tone
    %matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(spm_select('ExtFPList',  fullfile(w.subPath, 'verbgen', '^swua','.*\.nii$', Inf)));
    EPI_2 = spm_select('ExtFPList',  fullfile(w.subPath,'run2'), ['^swua' '.*' '.*\.nii$'], Inf);
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(EPI_2);
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).name = 'tone2';
   % matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).onset = [23 
   %                                                             74 
   %                                                             123 
   %                                                             170 
   %                                                             230];
   % matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).duration = [36 
   %                                                                18 
   %                                                                29 
   %                                                                23 
   %                                                                42];
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(1).orth = 1;
    
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    rpF2=spm_select('FPList', fullfile(w.subPath, 'run2'),['^rp' '.*\.txt$']);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = cellstr(rpF2);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = Inf;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
    
    
    explicitMask = spm_select('FPList', w.structPath, '^explicitMask_wc1wc2wc3_0.3.nii$');
    matlabbatch{1}.spm.stats.fmri_spec.mask = {explicitMask};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr(fullfile(w.firstDir, 'SPM.mat')); 
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    matlabbatch{3}.spm.stats.review.spmmat = cellstr(fullfile(w.firstDir, 'SPM.mat')); 
    matlabbatch{3}.spm.stats.review.display.matrix = 1;
    matlabbatch{3}.spm.stats.review.print = 'ps';

    %matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    %matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
    %matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % 2 conditions 
      % C1: picname 
      % C2: verbgen
    %nconds = 2;
    %conds = eye(nconds);
    %picname = conds(1,:);
    %verbgen = conds(2,:);
    
    matlabbatch{3}.spm.stats.con.spmmat = cellstr(fullfile(w.firstDir,'SPM.mat'));   
    
    %% Contrasts T (betas)    
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'syllable';
    % matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
    % 此处待改
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'tone';
    % matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 0 0 0 1];
    % 此处待改
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    %% Contrasts T (comparisons)   
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'picname > verbgen';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 0 0 0 0 0 0 -1]; % Division par 2 pas indispensable...
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'verbgen > picname';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-1 0 0 0 0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_6_FirstLevel.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    
    
    
end



    
