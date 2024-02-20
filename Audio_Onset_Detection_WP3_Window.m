%% File to detect onsets in EMG signal for Mapping Project with Only area of interest showing 
% Description: This script select a c3d file, detect the acoustic 
% stimulus, the muscular onsets following it and then reports it into an 
% excel file.
% /!\ Change the section: "Parameters & data from file" according to your
% recording nomenclature. 
% /!\ Change the section: "Global paramters" at the beginning of your 
% analysis if you wish to consider different range times 

clear all; clc; close all;
addpath(genpath('I:\Campus\SCMA\02_Resources\05_Matlab Scripts\01_btk')); % add here your path to btk
excel_pathname = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_029\OnSet'; %where you want to save your excel file --> create a subject specific folder
c3d_pathname = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_029\Lower_Extremities'; %where your c3d files are

%% Choosing file to analysis & loading it:
cd(c3d_pathname); 
[filename_c3d pathname]=uigetfile('*.c3d');
cd(pathname);
c3dfile = btkReadAcquisition(filename_c3d); %acquire handle for reading c3d
[emg, emgInfo] = btkGetAnalogs(c3dfile); %obtain EMG data
emgvalue = btkGetAnalogsValues(c3dfile); %obtain emg values in a tab
sf = emgInfo.frequency/1000; %factor of frequency used in analysis, 1 ms = 2 frames 
btkCloseAcquisition(c3dfile);
 
%% Parameters & data from file:
% /!\ Values to change according to how data was recorded
% this information is found under: emgInfo.label
voltage = abs(emgvalue(:,1:10)); %rectifing emg signals
analog_channel = 10;
oo_scm_channel = 1:2;
other_muscles_channel = [3:9];
 
%% Global parameters
% Audio stimulus parameters:
WARNING = [1,1.5];
MAS_value = 2;
LAS_value = 3;
ana_delay = 16.5*sf; % delay from audio ouput and vicon
% times considered for EMG onsets detection:
timeMax_muscle = 2000*sf; % differentiated between the biomarker muscles (i.e., OO & SCM) and the other muscles. Numerical values can be modified depending on the EMG frame you want to include (unit = ms)
timeMin_muscle = 50*sf;
timeMax_biomarker = 100*sf;              
timeMin_biomarker = 20*sf;
time_above = 5*sf;
time_above_biomarker = 2*sf;
% time considered before stimuli for baseline:
baseline = 100*sf; % temporal window used to do an average of the EMG activity before the stimulus 
% mutliple of standard deviation used for calculation:
multi = 2; % differentiated between biomarkers and the other muscles, as the signal from the former is weaker.
multi_biomarker = 1;
 
%% Accoustic stimulus detection
stimulus = {}; %used to detect muscles onsets
last_stimulus = 0;
j = 1;
for i = (1:size(voltage(:,analog_channel)))
    % LAS:
    if (voltage(i,analog_channel) > LAS_value && i > (last_stimulus+1000*sf))
        stimulus{j,1} = i+ana_delay; %timing of stimulus (delay already added)
        stimulus{j,2} = 'LAS'; %type of stimulus
        last_stimulus = i;
        j= j+1;
    end
    % MAS:
    if(voltage(i,analog_channel) > MAS_value && voltage(i,analog_channel) < LAS_value && i > (last_stimulus+1000*sf))
        stimulus{j,1} = i+ana_delay; %timing of stimulus (delay already added)
        stimulus{j,2} = 'MAS'; %type of stimulus
        last_stimulus = i;
        j= j+1;
    end 
end
stimulus_VICON = stimulus; %used to report results in excel (necessary for visual inspection)
for stim = 1:size(stimulus)  
    stimulus_VICON{stim,1} = ((stimulus{stim,1}-ana_delay)-1)/(5*sf)+1; %calculation to have VICON frames (necessary for visual check)
end


%% Muscles onsets detection
%muscles of interest: 
for i = other_muscles_channel 
     onsets(i).time = {}; %containing the muscles onsets
     onsets_EMG_samp_rate(i).time = {}; %same but in 200Hz
     for y = 1:size(stimulus) 
         %onset treshold calculation:
         tresholdUP = mean(voltage(stimulus{y,1}-baseline:stimulus{y,1}-1,i))+multi*std(voltage(stimulus{y,1}-baseline:stimulus{y,1}-1,i));   
         for x = timeMin_muscle:timeMax_muscle %checking for each pts between tim min & max after stimulus
            if voltage(round(stimulus{y,1}+x),i) > tresholdUP
                above_treshold = 0;  
                for w = 0:(time_above) %checking the signal for the next 5ms:
                    if voltage(round(stimulus{y,1}+x+w),i) > tresholdUP
                        above_treshold = above_treshold +1; %counting the simultaneous nbrs of pts above treshold
                    end
                end
                clear w;
                if above_treshold == time_above; %checking the signal is above the treshold for 5ms (if TRUE: adding the onset & stopping the loop)
                    onsets(i).time{y,1} = ((stimulus{y,1}+x-1)/(5*sf))+1; %calculation to have VICON frame
                    onsets(i).time{y,2} = x/sf; %calculation of reaction time
                    onsets_EMG_samp_rate(i).time{y,1} = stimulus{y,1}+x;
                    onsets_EMG_samp_rate(i).time{y,2} = x/sf;
                break
                end
            end
         end
         if x == timeMax_muscle %if no onset found after the time max:
             onsets(i).time{y,1} = NaN;
             onsets(i).time{y,2} = NaN;
             onsets_EMG_samp_rate(i).time{y,1} = NaN;
             onsets_EMG_samp_rate(i).time{y,2} = NaN;
         end
         clear x
     end
     clear y
 end
clear i
%biomarker muscles:
for i = oo_scm_channel
     onsets(i).time = {};
     onsets_EMG_samp_rate(i).time = {};%same but in 200Hz
     for y = 1:size(stimulus) 
         %onset treshold calculation:
         tresholdUP = mean(voltage(stimulus{y,1}-baseline:stimulus{y,1}-1,i))+multi_biomarker*std(voltage(stimulus{y,1}-baseline:stimulus{y,1},i));
         for x = timeMin_biomarker:timeMax_biomarker %checking for each pts between tim min & max after stimulus
             if voltage(round(stimulus{y,1}+x),i) > tresholdUP
                    above_treshold = 0; 
                    for w = 0:(time_above_biomarker) %above for 2ms (as signal weaker for biomarker (SCM & OO))
                        if voltage(round(stimulus{y,1}+x+w),i) > tresholdUP
                            above_treshold = above_treshold +1; %counting the simultaneous nbrs of pts above treshold 
                        end
                    end
                    clear w
                    if above_treshold == time_above_biomarker %checking the signal is above the treshold for 2ms (if TRUE: adding the onset & stopping the loop)
                        onsets(i).time{y,1} = ((stimulus{y,1}+x-1)/(5*sf))+1; %calculation to have the VICON frame
                        onsets(i).time{y,2} = x/sf; %calculation of reaction time
                        onsets_EMG_samp_rate(i).time{y,1} = stimulus{y,1}+x;
                        onsets_EMG_samp_rate(i).time{y,2} = x/sf;
                    break
                    end
                end
         end
         if x == timeMax_biomarker %if no onset found after the time max:
             onsets(i).time{y,1} = NaN; 
             onsets(i).time{y,2} = NaN;
             onsets_EMG_samp_rate(i).time{y,1} = NaN;
             onsets_EMG_samp_rate(i).time{y,2} = NaN;
         end
         clear x
     end
     clear y
 end
clear i
%% Reporting results in excel file
% %STEP 1: joining the results together:
% task_data = [stimulus_VICON];
% caColHeader = {'time','type'};
% %careful next line as emgInfo.label is a struct --> no specific order (works as Voltage is nummered)
% %it can simply be listed with your labels as: emg_name = {"name1";
% %"name2";...}. 
% emg_name = fieldnames(emgInfo.label); 
% for i = (1:(length(onsets))) % -1 as the last voltage is the analog 
%    task_data(:,end+1) = onsets(i).time(:,1);
%    task_data(:,end+1) = onsets(i).time(:,2);
%    caColHeader(1,end+1) = emg_name(i,1);
%    caColHeader(1,end+1) = {"RT "+ emg_name(i,1)};
% end
% 
% % Merge the cell array from task_data and caColHeadter to a table
% Header = string(caColHeader);
% Remove = ["Voltage"]; % Remove unwanted parts of the names in the header
% Header_remove = erase(Header,Remove);
% Header_no_underline = strrep(Header_remove, '_', ' ');
% task_data_with_header = cell2table(task_data,'VariableNames', Header_no_underline); % final table
% 
% % Create an excel from the table, change filename depending on the subject
% % and unilater/bilateral trial
% cd (excel_pathname);
% task_type = input('Which task was performed?','s');
%     filename = 'StartReact_data_Map_022_matlab.xlsx';
%     writetable(task_data_with_header, filename, 'Sheet', task_type, 'Range', 'A1');
    
 %% Open plot in area of interest 
addpath('W:\Forschung-SCMA\99_Share\Lukas\Matlab');
time_window_plotting = 1500;
EMG_numbers = input('Enter the channel number for the EMG of interest: ');
emg_name = struct2cell(emgInfo.label);

[local_signal_time_frame, onsets_EMG_samp_rate_to_modify, onsets_EMG_samp_rate_corrected, onsets_VICON_samp_rate_corrected]  = plotting_emg_onsets(emgvalue, onsets_EMG_samp_rate, time_window_plotting, EMG_numbers, sf, emg_name);

%% Reporting results in excel file
%STEP 1: joining the results together:
task_data = [stimulus_VICON];
caColHeader = {'time','type'};
%it can sim%careful next line as emgInfo.label is a struct --> no specific order (works as Voltage is nummered)
%ply be listed with your labels as: emg_name = {"name1";
%"name2";...}. 
emg_name = fieldnames(emgInfo.label); 
 % -1 as the last voltage is the analog 
   task_data(:,end+1) = onsets_VICON_samp_rate_corrected(EMG_numbers).time(:,1);
   task_data(:,end+1) = onsets_VICON_samp_rate_corrected(EMG_numbers).time(:,2);
   caColHeader(1,end+1) = emg_name(EMG_numbers,1);
   caColHeader(1,end+1) = {"RT "+ emg_name(EMG_numbers,1)};


% Merge the cell array from task_data and caColHeadter to a table
Header = string(caColHeader);
Remove = ["Voltage"]; % Remove unwanted parts of the names in the header
Header_remove = erase(Header,Remove);
Header_no_underline = strrep(Header_remove, '_', ' ');
task_data_with_header = cell2table(task_data,'VariableNames', Header_no_underline); % final table

% Create an excel from the table, change filename depending on the subject
% and unilater/bilateral trial
cd (excel_pathname);
task_type = input('Which task was performed?','s');
    filename = 'StartReact_data_Map_029.xlsx';
    writetable(task_data_with_header, filename, 'Sheet', task_type, 'Range', 'A1');
