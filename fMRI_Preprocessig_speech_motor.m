function fMRI_Preprocessig_speech_motor

% example of preprocessing implementation for SPM12 
% original scripts: https://github.com/blri/CREx_fMRI
% author of current version: Feng Lin (lincarrie32@gmail.com) 
% date: Jan 22, 2019 

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
        fprintf([w.subjects{iS} 'Preprocessing.../n']);
 
    
    w.subName = w.subjects{iS};
    w.subPath = fullfile(w.dataDir, w.subjects{iS});
    w.structPath = fullfile(w.subPath, w.structDir);

    cd(w.subPath);

%%======== do preprocessing step by step =================
DoSliceTiming(w);
DoRealignment(w);
DoCoregister(w);
DoSegment(w);
DoNormalise(w);
DoSmooth(w);
%%========================================================
    end 
end

function DoSliceTiming(w)
    
    clear matlabbatch; 

    % loop for sessions 
    matlabbatch{1}.spm.temporal.st.scans = {};
    for j=1:numel(w.sessions)
        %% Get EPI raw files           
        f = spm_select('ExtFPList',  fullfile(w.subPath, w.sessions{j}), '^.*\.nii$', Inf);
        matlabbatch{1}.spm.temporal.st.scans{j} = cellstr(f); 
        %%
    end
    
    matlabbatch{1}.spm.temporal.st.nslices = w.nSlices;
    matlabbatch{1}.spm.temporal.st.tr = w.TR;
    matlabbatch{1}.spm.temporal.st.ta = 1.94444444444444; 
    matlabbatch{1}.spm.temporal.st.so = [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35]; 
    matlabbatch{1}.spm.temporal.st.refslice = 36;      
    matlabbatch{1}.spm.temporal.st.prefix = 'a'; 
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_1_SliceTiming.mat'),'matlabbatch');     
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    %%
      
end


function DoRealignment(w)
    clear matlabbatch 
    
    % loop for sessions 
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {};
    for j=1:numel(w.sessions)
        %% Get files after slice timing           
        f = spm_select('ExtFPList',  fullfile(w.subPath, w.sessions{j}), ['^a' '.*' '.*\.nii$'], Inf);
        matlabbatch{1}.spm.spatial.realign.estwrite.data{j} = cellstr(f); 
        %%
    end
    
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 6;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_2_Realignment.mat'),'matlabbatch');

    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);       
end   


function DoCoregister(w)

    %get T1 structural file 
    a = spm_select('FPList', w.structPath, '^.*\.nii$'); 
    
    %get mean realigned EPI
    mean_realign = spm_select('FPList', fullfile(w.subPath, w.sessions{1}), ['^mean' '.*\.nii$']);
    
    clear matlabbatch
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(mean_realign);
    matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(a);
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

    save(fullfile(w.subPath, 'SPM12_matlabbatch_3_Coregister.mat'),'matlabbatch');  
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
end


function DoSegment(w)

    % select the T1 anatomical image
    coregAnat = cellstr(spm_select('FPList', w.structPath, '^.*\.nii$'));
    
    
    % get template of each cerebral tissue 
    tmpGM         = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,1'};
    tmpWM         = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,2'};
    tmpCSF        = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,3'};
    tmpBone       = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,4'};      
    tmpSoftTissue = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,5'};              
    tmpAirBck     = {'/Users/carrielin/Documents/MATLAB/spm12/tpm/TPM.nii,6'};  
    
    clear matlabbatch;
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = coregAnat;
    matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001; % Bias regularisation light
    matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;  % 60 mm cutoff
    matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];     
    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = tmpGM;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];  
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = tmpWM;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];       
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = tmpCSF;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];   
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = tmpBone;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = tmpSoftTissue;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];  %native
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];        
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = tmpAirBck;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];     
    matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];   %  Forward

    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_4_Segment.mat'),'matlabbatch');     
end


function DoNormalise(w)

    % do normalization on coregisterd t1, func, and c1c2c3
    
    % get field deformation image 
    forwardDeformation = spm_select('FPList', w.structPath, ['^y_' '.*\.nii$']);
    
    % get coregistered structural image 
    coregAnat = cellstr(spm_select('FPList', w.structPath, '^.*\.nii$'));
    
    % get sliced EPI images of all runs 
    EPI = {}; 
    % loop on sessions
    for j=1:numel(w.sessions)
        % get EPI realigned files 
        f = spm_select('ExtFPList', fullfile(w.subPath, w.sessions{j}),['^a' '.*\.nii$'],Inf);
        EPI = vertcat(EPI, cellstr(f));
    end 
    
    % get c1 c2 and c3 
    c1 = spm_select('FPList', w.structPath, ['^c1' '.*\.nii$']);
    c2 = spm_select('FPList', w.structPath, ['^c2' '.*\.nii$']);
    c3 = spm_select('FPList', w.structPath, ['^c3' '.*\.nii$']);
    c1c2c3 = vertcat(c1,c2,c3);
    
    clear matlabbatch;
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = {forwardDeformation};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {coregAnat};
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                               90 90 108];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    matlabbatch{2}.spm.spatial.normalise.write.subj.def(1) = {forwardDeformation};
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample = cellstr(EPI);    
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                               90 90 108];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [w.thickness w.thickness w.thickness];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    matlabbatch{3}.spm.spatial.normalise.write.subj.def(1) = {forwardDeformation};
    matlabbatch{3}.spm.spatial.normalise.write.subj.resample = cellstr(c1c2c3) ;   
    matlabbatch{3}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                               90 90 108];
    matlabbatch{3}.spm.spatial.normalise.write.woptions.vox = [w.thickness w.thickness w.thickness];
    matlabbatch{3}.spm.spatial.normalise.write.woptions.interp = 4;  
    matlabbatch{3}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_5_Normalize.mat'),'matlabbatch');   
    
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);  

end


function DoSmooth(w)

    clear matlabbatch; 
    EPI = [];
    % get normalized EPI files of all sessions 
    for j=1:numel(w.sessions)
        
        % get EPI normalized files 
        f = spm_select('ExtFPList', fullfile(w.subPath, w.sessions{j}),['^wa' '.*\.nii$'],Inf);
        EPI = vertcat(EPI, cellstr(f));
    end 
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(EPI);
    matlabbatch{1}.spm.spatial.smooth.fwhm = [(w.thickness*2) (w.thickness*2) (w.thickness*2)];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';

    
    save(fullfile(w.subPath, 'SPM12_matlabbatch_6_Smooth.mat'),'matlabbatch'); 
        
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);     
end

    
        
        