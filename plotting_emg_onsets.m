function [local_signal_time_frame, onsets_EMG_samp_rate_to_modify,onsets_EMG_samp_rate_corrected, onsets_VICON_samp_rate_corrected] = plotting_emg_onsets(emgvalue,onsets_EMG_samp_rate,time_window_plotting,EMG_numbers,sf,emg_name)
%This function plots all the differnt EMG onsets in different plots. You
%can then choose if the peak is suitable or not. 
%Script Version: 12.06.2023 Nicole Holliger
%
%   Input:
%
%   - emgvalue:                   raw emg data
%   - onsets_EMG_samp_rate:       calculated EMG onset from EMG (2000 Hz)
%   - time_window_plotting:       desired time window for before and after
%   - EMG_numbers:                number of EMG (e.g. SCM left, SCM right)
%                                 calculated onset
%   - sf:                         Factor of frequency used in analysis, 1 ms = 2 frames
%   - emg_name:                   name of EMG
%
%   Output:
%
%   - local_signal_time_frame:              time window with emg values
%   - onsets_EMG_samp_rate_to_modify:       shows the valid and non valid onsests
%   - onsets_EMG_samp_rate_corrected:       corrected onsets EMG samp rate
%   - onsets_VICON_samp_rate_corrected:     corrected onsets VICON samp rate

position_of_onset = time_window_plotting+1;% position of each onset within the single plots
onsets_EMG_samp_rate_to_modify = onsets_EMG_samp_rate; % copy to onsets to avoid overwriting
for u = EMG_numbers
    for w = 1:size(onsets_EMG_samp_rate(u).time)
        if isnan(onsets_EMG_samp_rate(u).time{w,1}) == false % no plot if there is no detected onset
            local_signal_time_frame(:,w) = emgvalue(onsets_EMG_samp_rate(u).time{w,1}-time_window_plotting:onsets_EMG_samp_rate(u).time{w,1}+time_window_plotting,u); % local time frame for plotting, based on onset (time window of 1000 frames is added before and after onset)
        
        % Plotting single EMG onsets
            fig = figure('units','normalized','outerposition',[0 0 1 1]);
            plot(local_signal_time_frame(:,w),'b', 'DisplayName','Signal');
            hold on
            plot(position_of_onset ,local_signal_time_frame(position_of_onset,w),'x','DisplayName','Detected Point', 'MarkerSize', 5, 'LineWidth', 2);
            legend();
            title([emg_name(u),' - Signal number:  ',num2str(w)],'Interpreter', 'none');

        
                    
            dbstop in plotting_emg_onsets at 41 % debugs, the function at line 49 (used to choose correct onset)
            onsets_EMG_samp_rate_to_modify(u).time{w,1} = []; % onset - reporting empty field if the onset is not set correctly
            onsets_EMG_samp_rate_to_modify(u).time{w,2} = []; % reaction time - reporting empty field if the onset is not set correctly
                    
           
        end
            % Question about incorrect onsets
            if isempty(onsets_EMG_samp_rate_to_modify(u).time{w,1})
                correct_onsets_in_plots(u).time{w,1} = input('What is the correct onset?'); % Add the correct onset
                onsets_EMG_samp_rate_prep_corrected(u).time{w,1} = correct_onsets_in_plots(u).time{w,1}-position_of_onset; % Difference between incorrect and correct onset (delta)
            elseif isnan(onsets_EMG_samp_rate_to_modify(u).time{w,1})
                onsets_EMG_samp_rate_prep_corrected(u).time{w,1} = NaN; % NaN if EMG signal is too weak 
            end

            
            if isnan(onsets_EMG_samp_rate_prep_corrected(u).time{w,1}) % Reporting NaN if onsets are not correct
                % EMG sampling rate (2000 Hz)
                onsets_EMG_samp_rate_corrected(u).time{w,1}= NaN;
                onsets_EMG_samp_rate_corrected(u).time{w,2} = NaN;
                % VICON sampling rate (200 Hz)
                onsets_VICON_samp_rate_corrected(u).time{w,1} = NaN;
                onsets_VICON_samp_rate_corrected(u).time{w,2} = NaN;
            else
                % EMG sampling rate (2000 Hz)
                onsets_EMG_samp_rate_corrected(u).time{w,1} = onsets_EMG_samp_rate(u).time{w,1}+onsets_EMG_samp_rate_prep_corrected(u).time{w,1}; % corrected EMG onset 
                onsets_EMG_samp_rate_corrected(u).time{w,2} = onsets_EMG_samp_rate(u).time{w,2}+(onsets_EMG_samp_rate_prep_corrected(u).time{w,1}/2);% corrected reaction time in ms
                
                % VICON sampling rate (200 Hz)
                onsets_VICON_samp_rate_corrected(u).time{w,1} = ((onsets_EMG_samp_rate_corrected(u).time{w,1}-1)/(5*sf))+1; % corrected EMG onset
                onsets_VICON_samp_rate_corrected(u).time{w,2} = onsets_EMG_samp_rate_corrected(u).time{w,2};% corrected reaction time in ms
        
            end
        
            
    end
    close all
end

  


