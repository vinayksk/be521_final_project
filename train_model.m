function [f_matrix] = train_model(train_ecog, train_dg)

% INPUTS: train_ecog, train_dg - 3 x 1 cell array containing ECoG for each subject, where train_ecog{i} 
% to the ECoG for subject i. Each cell element contains a N x M testing ECoG,
% where N is the number of samples and M is the number of EEG channels.

% OUTPUTS: R_matrix - 3 x 1 cell array with R matrix for each subject.

% Run time: The script has to run less than 1 hour. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    winLen = 0.1;
    winOverlap = 0.05;
    sample_rate_dg = 1000;
    sample_rate_ecog = 1000;
    f_matrix = cell(3,1);
    for s = 1:3
        windowed = getWindowedFeats(train_ecog{s}, sample_rate_ecog, winLen, winOverlap);

        N = 3;
        R = create_R_matrix(windowed, N);

        vars = {'testR_features', 'N_wind', 'vars'};
        clear(vars{:})

        Y = zeros(height(R), 5);
        winLenS = sample_rate_dg * winLen;
        winOverlapS = sample_rate_dg * winOverlap;
        dg_data_train = train_dg{s};
        for i = 1:height(R)
            Y(i, :) = dg_data_train((i-1) * winOverlapS + winLenS, :);
        end

        RtR = R.' * R;
        RtY = R.' * Y;

        f_matrix{s} = mldivide(RtR,RtY);

    end


end
