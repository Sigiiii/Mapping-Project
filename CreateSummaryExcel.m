clear all; clc; close all;
num = "31";
%Paths
excel_pathname_source = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0'+num+'\OnSet\StartReact_data_Map_0'+num+'.xlsx';
excel_pathname_destination = 'W:\Forschung-SCMA\99_Share\Lukas\Data'; 
map_sum_path = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_summary.xlsx'; 
destinationSheet = 'Sheet1';

% Get sheet names from the source Excel file
[~, sheetNames] = xlsfinfo(excel_pathname_source);
dat_sum = readtable(map_sum_path); 
columnsToExtract = [2, 4]; 

% Other information user input
prompt = "Subject:";
subject = input(prompt, "s");

prompt = "Age(y):";
age = input(prompt, "s");

prompt = "Sex (m/f):";
sex = input(prompt, "s");

prompt = "Dominant Hand(r/l):";
dominant_H = input(prompt, "s");
 
prompt = "Dominant Foot(r/l):";
dominant_F = input(prompt, "s");

prompt = "Wie vielte Proband:";
Proband = input(prompt);

% Iterate through each sheet in the source file
for i = 1:numel(sheetNames)
    sourceSheet = sheetNames{i};
    
    % Read data from the current source sheet
    data = readtable(excel_pathname_source, 'Sheet', sourceSheet); %file complete
    dat_24 = data(:, [2, 4]); %reduced file just with RT and Tone
    
%Read out task
if strcmp(sourceSheet, 'HipFlex')
    task = "HF";  % Set task to "HF" if sourceSheet is 'Hip_flexion'
    visit = "LE";
elseif strcmp(sourceSheet, 'HipExt')
    task = "HE";  % Set task to "HE" if sourceSheet is 'Hip_extension'
    visit = "LE";
elseif strcmp(sourceSheet, 'KneeFlex')
    task = "KF";  % Set task to "KF" if sourceSheet is 'Knee_flexion'
    visit = "LE";
elseif strcmp(sourceSheet, 'KneeExt')
    task = "KE";  % Set task to "KE" if sourceSheet is 'Knee_extension'
    visit = "LE";
elseif strcmp(sourceSheet, 'AnkleFlex')
    task = "AF";  % Set task to "AF" if sourceSheet is 'Ankle_flexion'
    visit = "LE";
elseif strcmp(sourceSheet, 'AnkleExt')
    task = "AE";  % Set task to "AE" if sourceSheet is 'Ankle_extension'
    visit = "LE";
elseif strcmp(sourceSheet, 'ToeExt')
    task = "TE";  % Set task to "TE" if sourceSheet is 'Toe_extension'
    visit = "LE";
elseif strcmp(sourceSheet, 'ShoulderFlex')
    task = "SF";  % Set task to "SF" if sourceSheet is 'Shoulder_flexion'
    visit = "UE";
elseif strcmp(sourceSheet, 'ShoulderExt')
    task = "SE";  % Set task to "SE" if sourceSheet is 'Shoulder_extension'
    visit = "UE";
elseif strcmp(sourceSheet, 'EllbowFlex')
    task = "EF";  % Set task to "EF" if sourceSheet is 'Elbow_flexion'
    visit = "UE";
elseif strcmp(sourceSheet, 'EllbowExt')
    task = "EE";  % Set task to "EE" if sourceSheet is 'Elbow_extension'
    visit = "UE";
elseif strcmp(sourceSheet, 'WristFlex')
    task = "WF";  % Set task to "WF" if sourceSheet is 'Wrist_flexion'
    visit = "UE";
elseif strcmp(sourceSheet, 'WristExt')
    task = "WE";  % Set task to "WE" if sourceSheet is 'Wrist_extension'
    visit = "UE";
else
    task = "FA";  % Set task to "FA" if sourceSheet doesn't match any of the above
    visit = "UE";
end

    prompt = 'Randomization Number '+task+'?';
    randomization = input(prompt);
    
    task = cellstr(task);
    visit = cellstr(visit);
    subject = cellstr(subject);
    sex = cellstr(sex);
    dominant_H = cellstr(dominant_H);
    dominant_F = cellstr(dominant_F);
    age = cellstr(age);
    
    
    z =  height(dat_24);
    dat_24.task = repmat({task}, z, 1);
    dat_24.visit = repmat({visit}, z, 1);
    dat_24.subject = repmat({subject}, z, 1);
    dat_24.age = repmat(age, z, 1);
    dat_24.sex = repmat(sex, z, 1);
    dat_24.dominant_H = repmat(dominant_H, z, 1);
    dat_24.dominant_F = repmat(dominant_F, z, 1);
    dat_24.randomization = repmat(randomization,z,1);
   
    
    x = 1+(30*(i-1));
    y = 30*i;
    for n  = x:y
          dat_sum(n+((Proband-1)*420), :) = dat_24((30-(y-n)), :);
            
    end
end

cd(excel_pathname_destination)
filename = 'Map_summary.xlsx';
writetable(dat_sum,filename,'Sheet',1,'Range','A1')