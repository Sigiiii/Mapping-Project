clear all; clc; close all;
%% General Information
x = 1;
y = 2;
z = 3;
std_factor = 3;

subject = "22"; %trial number: Map_0xx 
source_sheet = "ShoulderExt"; %specify the movement
extr = "UE"; %upper or lower extremities

onset_path = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0'+subject+'\OnSet\StartReact_data_Map_0'+subject+'.xlsx';

onset = readtable(onset_path,'Sheet', source_sheet);
onset{:,1} = round(onset{:,1},0);
onset{:,3} = round(onset{:,3},0);

if strcmp(source_sheet, 'EllbowExt')
        source_sheet = 'ElbowExt';
    elseif strcmp(source_sheet, 'EllbowFlex')
        source_sheet = 'ElbowFlex';
end

mat_path = "W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0"+subject+"\Kinematik\Map_0"+subject+"_"+extr+"_"+source_sheet;
load(mat_path);

%% Load in the respective movement parameters
centerpoint = markers.Sa(:,[x,z]);
            endpoint = markers.Ee(:,[x,z]);
            factor_phi = -1;
            factor_omega = -1;
            tanvar1 = 2;
            tanvar2 = 1;
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
% %% AUC
% for i = 1:height(onset)
%        for j = 1:1200
%            poscurve(i,j) = phi(round(onset{i,1},0)+j-200);
%            velcurve(i,j) = omega(round(onset{i,1},0)+j-200);
%        end
% end
%     laspos = [];
%     maspos = [];
%     for i = 1:height(onset)
%         if onset{i,2} == "LAS"
%            laspos = [laspos;poscurve(i,:)];
%         else
%            maspos = [maspos;poscurve(i,:)];
%         end
%     end
% meanpos = [mean(laspos);mean(maspos)];
%% 
format short;
summary = array2table(summary,'VariableNames',{'Max Angle [°]','Max Velocity [°/s]','Max Velocity [f]','Time to Peak Velocity [ms]','Kinematic RT (omega) [ms]','Kinematic Onset (omega) [f]'});
summary = horzcat(summary,array2table(onset{:,4},'VariableNames', {'EMG RT [ms]'}));
summary = horzcat(summary,array2table(onset{:,3},'VariableNames', {'EMG Onset [f]'}));
summary = horzcat(summary,array2table(onset{:,1},'VariableNames', {'Audio Onset [f]'}));
summary = horzcat(summary,array2table(onset{:,2},'VariableNames', {'Type'}));
%% 
% error = zeros(30,2)
% for i = 1:30
%     if summary{i,6} < summary{i,8}
%         error(i,1) = 1;
%         if summary{i,5} < summary{i,7}
%            error(i,2) = 1;
%         end
%     end
% end
% 
% frame_error=sum(isone(error(:,1)));
% RT_error = sum(isone(error(:,2)));
% display(frame_error);
% display(RT_error);

%% 
% std_las = std(laspos);
% std_mas = std(maspos);
% x = 1:1200;
% f1 = figure('Name','AUC');
% plot(x,meanpos);
% hold on;
% fill([x,fliplr(x)],[meanpos(1,:) + std_las, fliplr(meanpos(1,:) - std_las)],'b','FaceAlpha',0.3,'EdgeColor','none');
% fill([x,fliplr(x)],[meanpos(2,:) + std_mas, fliplr(meanpos(2,:) - std_mas)],'o','FaceAlpha',0.1,'EdgeColor','none');
% hold off;
% legend('LAS','MAS');
% xlabel('frames');
% ylabel('degrees');
% title('Mean Position Curve');
% 
% f2 = figure('Name','Angle')
% plot(phi);
% hold on;
% scatter(onset.Var1,phi(onset.Var1),100,'r','filled');
% scatter(summary{:,6},phi(summary{:,6}),100,'y','filled');
% scatter(onset.Var3,phi(onset.Var3),100,'g','filled');
% xlabel('frames');
% ylabel('velocity [ °/s ]');
% title('Velocity');
% legend('Angular Velocity','Auditory Stimulus','Kinematic Onset','EMG Onset');
% % 
f2 = figure('Name','Velocity')
plot(omega);
hold on;
scatter(onset{:,1},omega(onset{:,1}),100,'r','filled');
scatter(onset{:,3},omega(onset{:,3}),100,'g','filled');
scatter(summary{:,6},omega(summary{:,6}),100,'y','filled');
for i = 1:30;
    tstart = summary{i,9}-p;
    tend = summary{i,9};
    std = threshold(2,i);
    mean = threshold(1,i);
    upper = mean + 2*std;
    lower = mean - 2*std;
    plot([tstart, tend],[mean,mean],'r--');
    plot([tstart, tend],[upper,upper],'b--');
    plot([tstart, tend],[lower,lower],'b--');
end
xlabel('frames');
ylabel('velocity [ °/s ]');
title('Velocity');
legend('Angular Velocity','Auditory Stimulus','EMG Onset','Kinematic Onset');

% %%
% function result = isone(array)
%     result = sum(array == 1);
% end
% 




