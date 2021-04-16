function [R]=create_R_matrix(features, N_wind)
    %
    % get_features_release.m
    %
    % Instructions: Write a function to calculate R matrix.             
    %
    % Input:    features:   (samples x (channels*features))
    %           N_wind:     Number of windows to use
    %
    % Output:   R:          (samples x (N_wind*channels*features))
    % 
    
    M = size(features, 1);
    W = size(features, 2);
    % each row has N * channels * num_features + a column of ones
    % there are M rows
    % total size is M x (N*channels*num_features)
    R_Dims = [M W*N_wind+1];
    mod_features = [features(1:N_wind-1, :); features];
    R = zeros(M, W*N_wind);
    
    for i = 1:M
        for j = 1:N_wind
            R(i, (((j-1)*W)+1):(j*W)) = mod_features(i+(j-1),:);
        end
    end
    
    O = ones(M,1);
    
    R = [O R];

end