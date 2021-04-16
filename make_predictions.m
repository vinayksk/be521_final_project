function [predicted_dg] = make_predictions(test_ecog)

% INPUTS: test_ecog - 3 x 1 cell array containing ECoG for each subject, where test_ecog{i} 
% to the ECoG for subject i. Each cell element contains a N x M testing ECoG,
% where N is the number of samples and M is the number of EEG channels.

% OUTPUTS: predicted_dg - 3 x 1 cell array, where predicted_dg{i} contains the 
% data_glove prediction for subject i, which is an N x 5 matrix (for
% fingers 1:5)

% Run time: The script has to run less than 1 hour. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    winLen = 0.1;
    winOverlap = 0.05;
    sample_rate_ecog = 1000;
    N = 3;
    
    
    predicted_dg = cell(3,1);
    f_matrix_struct = load('f_matrix.mat');
    f_matrix = f_matrix_struct.f_matrix;
    for s = 1:3
        total_size = height(test_ecog{s});
        [windowed_test, time] = getWindowedFeats(test_ecog{s}, sample_rate_ecog, winLen, winOverlap);
        R_test = create_R_matrix(windowed_test, N);
        Y_hat = R_test * f_matrix{s};
        splined = zeros(total_size, 5);
        for j = 1:5
            splined(:,j) = spline([0 time.'], [0 Y_hat(:,j).'], 1:total_size);
        end
        predicted_dg{s} = splined;
    end

end

