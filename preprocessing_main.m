mainDir = '/Users/carrielin/Documents/MATLAB/speech_motor_project/';
dataDir = [mainDir '1_Data/'];
cd (dataDir);

subjList =  {'2','3', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16','17','19','20'}; % without the low accuracy ones
subjList = natsortfiles(subjList);
runList = {'run1','run2','run3','run4'};


% Preprocessing

disp('------Preprocessing started------');
  for subj = subjList
      disp(strcat('Subject:   ',subj));
      clear matlabbatch;
      cd(dataDir);
      cd(char(strcat(dataDir,subj)));
        
      funFiles = {};
      %matlabbatch{1}.spm.temporal.st.scans = {};
      for i = 1: numel(runList)
          funFiles{1,i} = cellstr(spm_select('ExtFPList',fullfile(dataDir,subj,runList{i}),'^.*\.nii$',Inf));
          %matlabbatch{1}.spm.temporal.st.scans{i} = cellstr(funFiles);
          
      end;  
      %funFiles = funFiles'
      preprocessing_aug_job(subj,mainDir,funFiles);
  end; 
disp('------Preprocessing ended------');


