clear all; clc; close all;
%% General Information
x = 1;
y = 2;
z = 3;
std_factor = 3;

subject = "22"; %trial number: Map_0xx 
onset_path = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0' + subject + '\OnSet\StartReact_data_Map_0' + subject + '.xlsx';
excel_path = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0'+subject+'\Kinematik';
%% Movement Selection 
[~, sheetNames] = xlsfinfo(onset_path); 
for index = 1:numel(sheetNames)
    source_sheet = sheetNames{index};
    onset = readtable(onset_path,'Sheet', source_sheet);
    onset{:,1} = round(onset{:,1},0);
    onset{:,3} = round(onset{:,3},0);
    
    if strcmp(source_sheet, 'EllbowExt')
        source_sheet = 'ElbowExt';
    elseif strcmp(source_sheet, 'EllbowFlex')
        source_sheet = 'ElbowFlex';
    end
    if any(strcmp(source_sheet, sheetNames(1:7)))
       extr = 'LE';
    else
       extr = 'UE';
    end
    mat_path = "W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0" + subject + "\Kinematik\Map_0" + subject + "_" + extr + "_" + source_sheet;
    load(mat_path);
   
%Hip Extension
    if      strcmp(source_sheet,'HipExt')
            centerpoint = markers.Ht(:,y:z);
            endpoint = markers.Kl(:,y:z);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 1;
            tanvar2 = 2;
% Hip Flexion
    elseif  strcmp(source_sheet,'HipFlex')
            centerpoint = markers.Ht(:,y:z);
            endpoint = markers.Kl(:,y:z);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 1;
            tanvar2 = 2;
% Knee Extension
    elseif  strcmp(source_sheet,'KneeExt')
            centerpoint = markers.Km(:,[x,z]);
            endpoint = markers.Am(:,[x,z]);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 2;
            tanvar2 = 1;
% Knee Flexion
    elseif  strcmp(source_sheet,'KneeFlex')
            centerpoint = markers.Kl(:,[x,z]);
            endpoint = markers.Al(:,[x,z]);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 2;
            tanvar2 = 1;
% Ankle Extension
    elseif  strcmp(source_sheet,'AnkleExt')
            centerpoint = markers.Am(:,y:z);
            endpoint = markers.Ta(:,y:z);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 1;
            tanvar2 = 2;
% Ankle Felxion
    elseif  strcmp(source_sheet,'AnkleFlex')
            centerpoint = markers.Am(:,y:z);
            endpoint = markers.Ta(:,y:z);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 1;
            tanvar2 = 2;
% Toe Extension
    elseif  strcmp(source_sheet,'ToeExt')
            centerpoint = markers.Ta(:,y:z);
            endpoint = markers.Tt(:,y:z);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 1;
            tanvar2 = 2;
% Shoulder Extension
    elseif  strcmp(source_sheet,'ShoulderExt')
            centerpoint = markers.Sa(:,[x,z]);
            endpoint = markers.Ee(:,[x,z]);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 2;
            tanvar2 = 1;
% Shoulder Flexion
    elseif  strcmp(source_sheet,'ShoulderFlex')
            centerpoint = markers.Sa(:,[x,z]);
            endpoint = markers.Ee(:,[x,z]);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 2;
            tanvar2 = 1;
% Elbow Extension
    elseif  strcmp(source_sheet,'ElbowExt')
            centerpoint = markers.Ee(:,x:y);
            endpoint = markers.Wm(:,x:y);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 1;
            tanvar2 = 2;
% % Elbow Flexion
    elseif  strcmp(source_sheet,'ElbowFlex')
            centerpoint = markers.Ee(:,x:y);
            endpoint = markers.Wm(:,x:y);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 1;
            tanvar2 = 2;
       
% Wrist Extension
    elseif  strcmp(source_sheet,'WristExt')
            centerpoint = markers.Wr(:,x:y);
            endpoint = markers.Am(:,x:y);
            factor_phi = 1;
            factor_omega = 1;
            tanvar1 = 1;
            tanvar2 = 2;
% Wrist Flexion
    elseif  strcmp(source_sheet,'WristFlex')
            centerpoint = markers.Wr(:,x:y);
            endpoint = markers.Am(:,x:y);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 1;
            tanvar2 = 2;
% Finger Abduction
    elseif  strcmp(source_sheet,'FingerAbd')
            centerpoint = markers.Am(:,[x,z]);
            endpoint = markers.Fi(:,[x,z]);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 1;
            tanvar2 = 2;
    end

    %% Phi & Omega
    centerpoint_mean = mean(centerpoint); 
        for i = 1:size(endpoint)
            for j = 1:2
                endpoint(i,j) = endpoint(i,j) - centerpoint_mean(1,j);
            end
        end
    for t = 1:size(endpoint) 
            phi(t,1) = atan2(endpoint(t,tanvar1),endpoint(t,tanvar2));
    end
        m = mean(phi(1:2500));
        for t = 1:size(phi)
            phi(t) = phi(t)-m;
        end
    omega = diff(phi);
    omega = factor_omega * omega;
    omega = rad2deg(omega);
    omega = omega*200;
    phi = rad2deg(phi);
    phi = factor_phi * phi;


    %% Vmax & Phimax
    for i = 1:size(onset) 
            summary(i,1) = 0;
            summary(i,2) = 0;
            summary(i,3) = 0;
            for j = onset{i,1}:onset{i,1}+500
                if summary(i,2) < omega(j)
                   summary(i,2) = omega(j);
                   summary(i,3) = j;
                end
                if summary(i,1) < phi(j)
                   summary(i,1) = phi(j);
                end
            end
    end
    %%
    p = 400;
    q = 5;
    stop = false; 

    % Calculate threshold for each onset
    for i = 1:height(onset)
        avg_preonset = zeros(1, p); % Initialize avg_preonset for each onset
        for j = 1:p % 20 frames or 100ms
            avg_preonset(j) = omega(onset{i,1}+j-(p+1));
        end
        threshold(1,i) = mean(avg_preonset);
        threshold(2,i) = std(avg_preonset);
    end

    % Iterate through each onset
    for i = 1:height(onset)
        % Iterate through frames after each onset
        for j = 1:100
            if omega(onset{i,1}+j) > threshold(1,i) +std_factor*threshold(2,i)
                % Check the next q frames for consecutive threshold surpassing
                consecutive_surpass_count = 1; % Initialize count to 1 for the current frame
                for k = 1:q-1 % Check the next q-1 frames
                    if omega(onset{i,1}+j+k) > threshold(1,i) + std_factor*threshold(2,i)
                        consecutive_surpass_count = consecutive_surpass_count + 1; % Increment count for consecutive frames where threshold is surpassed
                    else
                        consecutive_surpass_count = 0; % Reset count if the threshold is not surpassed in consecutive frames
                        break; % Exit the loop if the threshold is not surpassed in a consecutive frame
                    end
                end
                % If the condition is met for q consecutive frames
                if consecutive_surpass_count == q
                    summary(i,6) = onset{i,1}+j;
                    summary(i,5) = j*5; % If the onset is set exactly, the kinematic onset may come 1 frame before the EMG onset due to rounding
                    stop = true; % Set the flag to stop both loops
                    break; % Exit the outer loop
                end
            end
        end
    end
    %% Time to Peak
    for i = 1:height(summary)
            summary(i,4) = (summary(i,3) - onset{i,1})*5;
    end 
    %% array2table
    summary = array2table(summary,'VariableNames',{'Max Angle [°]','Max Velocity [°/s]','Max Velocity [f]','Time to Peak Velocity [ms]','Kinematic RT (omega) [ms]','Kinematic Onset (omega) [f]'});
    summary = horzcat(summary,array2table(onset{:,4},'VariableNames', {'EMG RT [ms]'}));
    summary = horzcat(summary,array2table(onset{:,3},'VariableNames', {'EMG Onset [f]'}));
    summary = horzcat(summary,array2table(onset{:,1},'VariableNames', {'Audio Onset [f]'}));
    summary = horzcat(summary,array2table(onset{:,2},'VariableNames', {'Type'}));
    
    %% Write Excel Table
    cd (excel_path);
        filename = 'Map_0'+subject+'_Kinematic_Summary.xlsx';
        writetable(summary,filename,'Sheet',source_sheet,'Range','A1');
    %%
    clear summary; 
 end
%% Plotting

% f1 = figure('Name','Angular Displacement');
% plot(phi);
% xlabel('frames');
% ylabel('angle [ ° ]');
% title('Angular Displacement');
% 
% f2 = figure('Name','Velocity');
% plot(omega);
% xlabel('frames');
% ylabel('velocity [ °/f ]');
% title('Velocity');
% 
% t = 1:1200;
% f3 = figure('Name','Mean Position Curve');
% plot(t,meanpos);
% legend('LAS','MAS');
% xlabel('frames');
% ylabel('degrees');
% title('Mean Position Curve');
% 
% f4 = figure('Name','Mean Velocity Curve');
% plot(t,meanvel);
% legend('LAS','MAS');
% xlabel('frames');
% ylabel('degrees / frame');
% title('Mean Velocity Curve');

