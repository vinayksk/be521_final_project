function [all_feats, time]=getWindowedFeats(raw_data, fs, window_length, window_overlap)
    %
    % getWindowedFeats_release.m
    %
    % Instructions: Write a function which processes data through the steps
    %               of filtering, feature calculation, creation of R matrix
    %               and returns features.
    %
    %               Points will be awarded for completing each step
    %               appropriately (note that if one of the functions you call
    %               within this script returns a bad output you won't be double
    %               penalized)
    %
    %               Note that you will need to run the filter_data and
    %               get_features functions within this script. We also 
    %               recommend applying the create_R_matrix function here
    %               too.
    %
    % Inputs:   raw_data:       The raw data for all patients
    %           fs:             The raw sampling frequency
    %           window_length:  The length of window
    %           window_overlap: The overlap in window
    %
    % Output:   all_feats:      All calculated features
    %
%% Your code here (3 points)

% First, filter the raw data
num_Feats = 8;

filtered = filter_data(raw_data);

num_samples = size(raw_data, 1);
num_channels = size(raw_data, 2);
windowLen = window_length * fs;
windowOverlap = window_overlap * fs;

windowDisp = windowLen - windowOverlap;

numWin = floor((num_samples - windowLen)/windowDisp)+1;
all_feats = zeros(numWin, num_Feats * num_channels);
time = zeros(numWin, 1);

for i = 1:numWin
    start = (i-1)*windowDisp + 1;
    stop = (i-1) * windowDisp + windowLen;
    time(i,1) = stop;
    feats = get_features(filtered(start:stop,:), fs);
    all_feats(i, :) = feats;
end

% Then, loop through sliding windows

    % Within loop calculate feature for each segment (call get_features)

% Finally, return feature matrix

end