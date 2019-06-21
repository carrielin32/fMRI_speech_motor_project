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
w.dataDir  = '/home/feng/Downloads/niidata/';  %raw data
w.subjects = {'03','04,'05','06','07','08','09','10', '11', '12', '13', '14', '15', '16', '17', '18', '19','20'}; % without low accuracy ones (parent= dataDir)

w.structDir = 't1'; % structural directory (parent=subject)
w.firstDir = 'stats';
w.secondDir = 'second_level';

DoCreateGroupMask(w);
DoSecondLevel(w);

end

function DoCreateGroupMask(w)

    %==================================================================
    %  Create binary mask for the subject group
    %==================================================================    
    outputDir = fullfile(w.dataDir, w.secondDir, 'ExplicitMask');

    if ~exist(outputDir,  'dir')
      mkdir (outputDir);        
    end

    %%
    fileMask = {};
    express=[]; 
    N = numel(w.subjects);
    for iS=1:N
   
        w.subName = w.subjects{iS};
        w.subPath = fullfile(w.dataDir, w.subjects{iS});
        w.structPath = fullfile(w.subPath, w.structDir);
        fileMask {iS}   = spm_select('FPList',  fullfile(w.structPath), 'explicitMask_wc1wc2wc3_03.nii');
    
        % For Expression, add 'i1+iN' for avering the subject-specific masks  
        if (iS== N)
            express = [express 'i' num2str(iS)];
        else
            express = [express 'i' num2str(iS) '+'];
        end    
    end
    express=['((' express ')/' num2str(N) ')>.50'] ; % use  a threshold of 50%
    %%

    % Batch SPM
    clear matlabbatch;
    matlabbatch{1}.spm.util.imcalc.input =  fileMask';
    matlabbatch{1}.spm.util.imcalc.output = 'ExplicitMask.nii';
    matlabbatch{1}.spm.util.imcalc.outdir = {outputDir};
    matlabbatch{1}.spm.util.imcalc.expression = express;
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
end


%待改 0618
function DoSecondLevel(w)

clear matlabbatch;
matlabbatch{1}.spm.stats.factorial_design.dir = {'/home/feng/Downloads/niidata/second_level/tone'};

    for i=1:numel(w.subjects)
        %%
        matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i).scans = {fullfile(w.FirstDir,w.subjects{i},'con_0001.nii,1')
                                                                                  fullfile(w.FirstDir,w.subjects{i},'con_0002.nii,1')
                                                                                  fullfile(w.FirstDir,w.subjects{i},'con_0003.nii,1')
                                                                                  fullfile(w.FirstDir,w.subjects{i},'con_0004.nii,1')};
        matlabbatch{1}.spm.stats.factorial_design.des.anovaw.fsubject(i).conds = [1 2 3 4];
    end

    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.anovaw.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0; % Implicit Mask = 1
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/home/feng/Downloads/niidata/second_level/ExplicitMask/ExplicitMask.nii,1'};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    %==============================================================
    %  Model Estimation
    %==============================================================   

    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    %==============================================================
    %  Contrast manager
    %==============================================================   

    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

    % Contrasts T
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'syllable_only';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'tone_only';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'syllable > tone';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'tone > syllable';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    %matlabbatch{3}.spm.stats.con.consess{5}.fcon.name = 'F-all_conditions';
    %matlabbatch{3}.spm.stats.con.consess{5}.fcon.weights =  eye(w.ncond)*(w.ncond-1)/w.ncond + (ones(w.ncond)-eye(w.ncond))*-1/w.ncond;
    %matlabbatch{3}.spm.stats.con.consess{5}.fcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.delete = 1;

    %==============================================================
    %  Save & Run Batch
    %==============================================================   

    save(fullfile(w.dataDir, w.secondDir, 'SPM12_matlabbatch_1_2ndlevelanalysis.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch); 

end





