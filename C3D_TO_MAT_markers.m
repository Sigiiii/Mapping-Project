clear all; clc; close all
%% General information
subject = 'Map_022';
extr = 'Upper';
extra = '_UE';
c3d_pathname = "W:\Forschung-SCMA\99_Share\Lukas\Data\"+subject+"\Unfiltered\"+extr+"_Extremities"; %where your c3d files are
mat_files_pathname = "W:\Forschung-SCMA\99_Share\Lukas\Data\"+subject+"\Kinematik"; %where you want to save your mat files
addpath(genpath('I:\Campus\SCMA\02_Resources\05_Matlab Scripts\01_btk')); %add here your path to btk
%%
% List of filenames
filelist_LE = {'HipExt','HipFlex','KneeExt','KneeFlex','AnkleExt','AnkleFlex','ToeExt'}; % List all your filenames here
filelist_UE = {'ShoulderExt','ShoulderFlex','ElbowExt','ElbowFlex','WristExt','WristFlex','FingerAbd'};
% Loop over each filename
for fileIndex = 1:7
    % Extract filename and pathname 
    filename_c3d = [subject, extra, '_', filelist_UE{fileIndex},'.c3d']; %% !!!!!!!!!!!!!!! Hier auch anpassen (LE / UE) !!!!!!!!!!!!!!!! %%
    pathname = c3d_pathname; 
    % Change directory to the location of .c3d files
    cd(pathname);
    
    % Read the .c3d file
    c3dfile = btkReadAcquisition(filename_c3d);
    
    % Obtain necessary data
    Fs = btkGetAnalogFrequency(c3dfile);
    analogs = btkGetAnalogs(c3dfile);
    markers = btkGetMarkers(c3dfile);
    events = btkGetEvents(c3dfile);
    ratio = btkGetAnalogSampleNumberPerFrame(c3dfile);
    
    % Change directory to the location where .mat files will be saved
    cd(mat_files_pathname); 
    
    % Create .mat filename
    filename_mat = strtok(filename_c3d, '.');
    
    % Save data to .mat file
    save(filename_mat,'events','analogs','ratio','Fs','markers');
    
    % Close the .c3d file
    btkCloseAcquisition(c3dfile);
    
    % Display message
    disp(['Conversion to mat format of: ', filename_c3d]);
end

%% Choosing file to convert & loading it:
% cd(c3d_pathname); 
% [filename_c3d pathname]=uigetfile('*.c3d');
% cd (pathname)
% c3dfile = btkReadAcquisition(filename_c3d); %acquire handle for reading c3d
% Fs = btkGetAnalogFrequency(c3dfile);
% analogs = btkGetAnalogs(c3dfile); %obtain EMG data
% markers = btkGetMarkers(c3dfile); %obtain marker
% events = btkGetEvents(c3dfile); %obtain the events
% ratio = btkGetAnalogSampleNumberPerFrame(c3dfile);
% cd(mat_files_pathname); 
% filename_mat = strtok(filename_c3d, '.');
% save(filename_mat,'events','analogs','ratio','Fs','markers');
% btkCloseAcquisition(c3dfile);
% %display # of triggers & filename used for Type 1 analysis:
% disp(['Conversion to mat format of: ',filename_c3d]);
% 
% 
% 












