function clean_data = filter_data(raw_eeg)
    %
    % filter_data_release.m
    %
    % Instructions: Write a filter function to clean underlying data.
    %               The filter type and parameters are up to you.
    %               Points will be awarded for reasonable filter type,
    %               parameters, and correct application. Please note there 
    %               are many acceptable answers, but make sure you aren't 
    %               throwing out crucial data or adversely distorting the 
    %               underlying data!
    %
    % Input:    raw_eeg (samples x channels)
    %
    % Output:   clean_data (samples x channels)
    % 
%% Your code here (2 points)
%     size_eeg = height(raw_eeg)
%     num_channels = width(raw_eeg)
%     clean_data = zeros(size_eeg, num_channels);
%     for i = 1:num_channels
%         clean_data(:, i) = (bandpass(raw_eeg(:,i), [0.15,200], 1000));
%     end
    
    clean_data = bandpass(raw_eeg, [2,200], 1000);
    
    
end