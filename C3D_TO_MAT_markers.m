%% File to convert file from c3d to mat format
% Description: Conversion from c3d to mat is necessary for coherence
% analysis
% Choosing file to convert & loading it: to convert files format .c3d files to format .mat
% /!\ Add your own path for BTK (essential to acccess c3d files)
% /!\ Add the pathname where to save the mat files

% Plotting: only to verify that the events are correctly taken from 
% VICON to the matlab format (it is a double check it is normally always 
% correct)(e.g. written below for SCM and Biceps brachii for the events that 
% I used, just change the names in the code for yours (the # of for loops 
% depends on your number of different events for the muscle, I left all my
% examples in the last commented part)).
clear all; clc; close all

%% General information
c3d_pathname = "W:\Forschung-SCMA\99_Share\Lukas\Data\Map_022\Lower_Extremities"; %where your c3d files are
mat_files_pathname = "W:\Forschung-SCMA\99_Share\Lukas\Data\Map_022\Kinematik"; %where you want to save your mat files
addpath(genpath('I:\Campus\SCMA\02_Resources\05_Matlab Scripts\01_btk')); %add here your path to btk

%% Choosing file to convert & loading it:
cd(c3d_pathname); 
[filename_c3d pathname]=uigetfile('*.c3d');
cd (pathname)
c3dfile = btkReadAcquisition(filename_c3d); %acquire handle for reading c3d
Fs = btkGetAnalogFrequency(c3dfile);
analogs = btkGetAnalogs(c3dfile); %obtain EMG data
markers = btkGetMarkers(c3dfile); %obtain marker
events = btkGetEvents(c3dfile); %obtain the events
ratio = btkGetAnalogSampleNumberPerFrame(c3dfile);
cd(mat_files_pathname); 
filename_mat = strtok(filename_c3d, '.');
save(filename_mat,'events','analogs','ratio','Fs','markers');
btkCloseAcquisition(c3dfile);
%display # of triggers & filename used for Type 1 analysis:
disp(['Conversion to mat format of: ',filename_c3d]);

%% Ploting to double-check
% %ploting analog:
% plot(analogs.Voltage_5_QVM);
% hold on
% %ploting SCM emg & associated events 
% plot(analogs.Voltage_2_SCM_L);
% hold on
% for i = 1:length(events.Right_TA_MAS)
%         line([events.Right_TA_MAS(i)*Fs events.Right_TA_MAS(i)*Fs],[0 2], 'Color','red', 'Linestyle',':', 'LineWidth',1.8);
% end
% for i = 1:length(events.Right_SCM)
%         line([events.Right_SCM(i)*Fs events.Right_SCM(i)*Fs],[0 2], 'Color','green', 'Linestyle',':', 'LineWidth',1.8);
% end
% for i = 1:length(events.Left_MAS)
%         line([events.Left_MAS(i)*Fs events.Left_MAS(i)*Fs],[0 2], 'Color','k', 'Linestyle',':', 'LineWidth',1.8);
% end
% %ploting Biceps bracchi emg & associated events: 
% plot(analogs.Voltage_5_Biceps_brachii_left);
% hold on
% for i = 1:length(events.Left_BB)
%         line([events.Left_BB(i)*Fs events.Left_BB(i)*Fs],[0 2], 'Color','green', 'Linestyle',':', 'LineWidth',1.8);
% end
