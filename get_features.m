function [features, power] = get_features(clean_data,fs)
    %
    % get_features_release.m
    %
    % Instructions: Write a function to calculate features.
    %               Please create 4 OR MORE different features for each channel.
    %               Some of these features can be of the same type (for example, 
    %               power in different frequency bands, etc) but you should
    %               have at least 2 different types of features as well
    %               (Such as frequency dependent, signal morphology, etc.)
    %               Feel free to use features you have seen before in this
    %               class, features that have been used in the literature
    %               for similar problems, or design your own!
    %
    % Input:    clean_data: (samples x channels)
    %           fs:         sampling frequency
    %
    % Output:   features:   (1 x (channels*features))
    % 
%% Your code here (8 points)

spectral_8_12 = bandpower(clean_data,fs,[8 12]);
spectral_18_24 = bandpower(clean_data,fs,[18 24]);
spectral_75_115 = bandpower(clean_data,fs,[75 115]);
spectral_125_159 = bandpower(clean_data,fs,[125 159]);
spectral_159_175 = bandpower(clean_data,fs,[159 175]);

LL = @(data) sum(abs(diff(data)));
Area = @(x) sum(abs(x));
Energy = @(x) sum(x .* x);

ll = LL(clean_data);
A = Area(clean_data);
E = Energy(clean_data);
LMP = mean(clean_data);

features = [ll E LMP spectral_8_12 spectral_18_24 spectral_75_115 spectral_125_159 spectral_159_175];


end

