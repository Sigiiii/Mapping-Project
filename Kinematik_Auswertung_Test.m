clear all; clc; close all;
%% General Information
x = 1;
y = 2;
z = 3;

subject = "22"; %trial number: Map_0xx 
mov = "EllbowFlex"; %specify the movement
extr = "UE"; %upper or lower extremities
source_sheet = mov;

onset_path = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0'+subject+'\OnSet\StartReact_data_Map_0'+subject+'.xlsx';
excel_path = 'W:\Forschung-SCMA\99_Share\Lukas\Data\Map_022';
mat_path = "W:\Forschung-SCMA\99_Share\Lukas\Data\Map_0"+subject+"\Kinematik\Map_0"+subject+"_"+source_sheet;
onset = readtable(onset_path,'Sheet',source_sheet); 
load(mat_path);
onset.Var1= round(onset.Var1,0);
onset.Var4= round(onset.Var4,0);
onset.Var3= round(onset.Var3,0);
%% Load in the respective movement parameters
centerpoint = markers.Ee(:,x:y);
endpoint = markers.Wm(:,x:y);
factor_phi = -1;
factor_omega = -1;
tanvar1 = 1;
tanvar2 = 2;

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
for i = 1:size(onset)-1 
        summary(i,1) = 0;
        summary(i,2) = 0;
        summary(i,3) = 0;
        for j = onset.Var1(i):onset.Var1(i+1)
            if summary(i,2) < omega(j)
               summary(i,2) = omega(j);
               summary(i,3) = j;
            end
            if summary(i,1) < phi(j)
               summary(i,1) = phi(j);
            end
        end
end
summary(30,1) = 0;
for j = onset.Var1(30):length(omega) 
    if summary(30,2) < omega(j)
       summary(30,2) = omega(j);
       summary(30,3) = j;
    end

     if summary(30,1) < phi(j)
        summary(30,1) = phi(j);
     end
end
%% Onset nach Omega
abs(omega);
for i = 1:height(onset)
        for j = 1:30  % 20 frames or 100ms
            avg_preonset(j) = omega(onset.Var1(i)+j-21);
        end
        threshold(1,i) = mean(avg_preonset);
        threshold(2,i) = std(avg_preonset);
end
    for i = 1:height(onset)
        for j = 1:100
            if omega(onset.Var1(i)+j) > threshold(1,i) + 2*threshold(2,i)
               u = 0;
               for k = 1:5
                   if omega(onset.Var1(i)+j+k) > threshold(1,i) + 2*threshold(2,i)
                       u = u+1;
                   end
               end
               if u == 5 
               summary(i,5) = onset.Var1(i)+j;
               summary(i,4) = j*5-16; %falls der Onset genau gleich gesetzt wurde kann durch runden der kinematische Onset 1 Frame vor dem EMG Onset kommen
               break
               end
            end
        end
    end

%% Onset nach Phi
abs(phi);
for i = 1:height(onset)
        for j = 1:30  % 20 frames or 100ms
            avg_preonset(j) = phi(onset.Var1(i)+j-21);
        end
        threshold(1,i) = mean(avg_preonset);
        threshold(2,i) = std(avg_preonset);
end
    for i = 1:height(onset)
        for j = 1:100
            if phi(onset.Var1(i)+j) > threshold(1,i) + 2*threshold(2,i)
               u = 0;
               for k = 1:5
                   if phi(onset.Var1(i)+j+k) > threshold(1,i) + 2*threshold(2,i)
                       u = u+1;
                   end
               end
               if u == 5 
               summary(i,7) = onset.Var1(i)+j;
               summary(i,6) = j*5; %falls der Onset genau gleich gesetzt wurde kann durch runden der kinematische Onset 1 Frame vor dem EMG Onset kommen
               break
               end
            end
        end
    end
%%
for i = 1:height(onset)
        for j = 1:1200
            poscurve(i,j) = phi(round(onset.Var1(i),0)+j-200);
            velcurve(i,j) = omega(round(onset.Var1(i),0)+j-200);
        end
    end

    laspos = [];
    maspos = [];
    lasvel = [];
    masvel = [];
    for i = 1:height(onset)
        if onset.Var2{i} == "LAS"
           laspos = [laspos;poscurve(i,:)];
           lasvel = [lasvel;velcurve(i,:)];
        else
           maspos = [maspos;poscurve(i,:)];
           masvel = [masvel;velcurve(i,:)];
        end
    end
    meanpos = [mean(laspos);mean(maspos)];
    stdpos = [std(laspos);std(maspos)];
    meanvel = [mean(lasvel);mean(masvel)];
    stdvel = [std(lasvel);std(masvel)];
%% 
format short;
summary = array2table(summary,'VariableNames',{'Max Angle [°]','Max Velocity [°/s]','Max Velocity [f]','Kinematic RT (omega) [ms]','Kinematic Onset (omega) [f]','Kinematic RT (phi) [ms]','Kinematic Onset (phi) [f]'});
summary = horzcat(summary,array2table(onset.Var4,'VariableNames', {'EMG RT [ms]'}));
summary = horzcat(summary,array2table(onset.Var3,'VariableNames', {'EMG Onset [f]'}));
summary = horzcat(summary,array2table(onset.Var1,'VariableNames', {'Audio Onset [f]'}));
summary = horzcat(summary,array2table(onset.Var2,'VariableNames', {'Type'}));
%%
t = 1:1200;
f3 = figure('Name','Mean Position Curve');
plot(t,meanpos);
legend('LAS','MAS');
xlabel('frames');
ylabel('degrees');
title('Mean Position Curve');
f2 = figure('Name','Velocity');
plot(phi);
hold on;
scatter(onset.Var1,phi(onset.Var1),100,'r','filled');
hold on;
scatter(summary{:,5},phi(summary{:,5}),100,'y','filled');
hold on;
scatter(onset.Var3,phi(onset.Var3),100,'g','filled');
hold on;
xlabel('frames');
ylabel('velocity [ °/s ]');
title('Velocity');
legend('Angular Velocity','Auditory Stimulus','Kinematic Onset','EMG Onset');








