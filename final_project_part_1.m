%% Final project part 1
% Prepared by John Bernabei and Brittany Scheid

% One of the oldest paradigms of BCI research is motor planning: predicting
% the movement of a limb using recordings from an ensemble of cells involved
% in motor control (usually in primary motor cortex, often called M1).

% This final project involves predicting finger flexion using intracranial EEG (ECoG) in three human
% subjects. The data and problem framing come from the 4th BCI Competition. For the details of the
% problem, experimental protocol, data, and evaluation, please see the original 4th BCI Competition
% documentation (included as separate document). The remainder of the current document discusses
% other aspects of the project relevant to BE521.


%% Start the necessary ieeg.org sessions (0 points)

username = 'nchitali';
passPath = '~/Desktop/BE521/nch_ieeglogin.bin';


% Load training ecog from each of three patients
s1_train_ecog = IEEGSession('I521_Sub1_Training_ecog', username, passPath);
s2_train_ecog = IEEGSession('I521_Sub2_Training_ecog', username, passPath);
s3_train_ecog = IEEGSession('I521_Sub3_Training_ecog', username, passPath);

% Load training dataglove finger flexion values for each of three patients
s1_train_dg = IEEGSession('I521_Sub1_Training_dg', username, passPath);
s2_train_dg = IEEGSession('I521_Sub2_Training_dg', username, passPath);
s3_train_dg = IEEGSession('I521_Sub3_Training_dg', username, passPath);

leaderboard = IEEGSession("I521_Sub1_Leaderboard_ecog", username, passPath);

sample_rate_ecog = s1_train_ecog.data(1).sampleRate;
sample_rate_dg = s1_train_dg.data(1).sampleRate;

IEEG_data_ecog = [s1_train_ecog s2_train_ecog s3_train_ecog];
IEEG_data_dg = [s1_train_dg s2_train_dg s3_train_dg];

vars = {'username', 'passPath', 'vars', 's1_train_ecog', 's2_train_ecog'};
vars1 = {'s3_train_ecog', 's1_train_dg', 's2_train_dg', 's3_train_dg', 'vars1'};
clear(vars{:});
clear(vars1{:});

%% Extract dataglove and ECoG data 
% Dataglove should be (samples x 5) array 
% ECoG should be (samples x channels) array
load('final_proj_part1_data.mat');

s1_ecog_data = train_ecog{1,1};
s2_ecog_data = train_ecog{2,1};
s3_ecog_data = train_ecog{3,1};

s1_dg_data = train_dg{1,1};
s2_dg_data = train_dg{1,2};
s3_dg_data = train_dg{1,3};

samples_s1 = length(s1_ecog_data(:,1));
samples_s2 = length(s2_ecog_data(:,1));
samples_s3 = length(s3_ecog_data(:,1));

train_split = 1;

% Split data into a train and test set (use at least 50% for training)
s1_ecog_data_train = s1_ecog_data(1:samples_s1*train_split, :);
s2_ecog_data_train = s2_ecog_data(1:samples_s2*train_split, :);
s3_ecog_data_train = s3_ecog_data(1:samples_s3*train_split, :);

s1_ecog_data_test = s1_ecog_data(samples_s1*train_split+1:end, :);
s2_ecog_data_test = s2_ecog_data(samples_s2*train_split+1:end, :);
s3_ecog_data_test = s3_ecog_data(samples_s3*train_split+1:end, :);

s1_dg_data_train = s1_dg_data(1:samples_s1*train_split, :);
s2_dg_data_train = s2_dg_data(1:samples_s2*train_split, :);
s3_dg_data_train = s3_dg_data(1:samples_s3*train_split, :);

s1_dg_data_test = s1_dg_data(samples_s1*train_split+1:end, :);
s2_dg_data_test = s2_dg_data(samples_s2*train_split+1:end, :);
s3_dg_data_test = s3_dg_data(samples_s3*train_split+1:end, :);

train_ecog_data = {s1_ecog_data_train, s2_ecog_data_train, s3_ecog_data_train};
train_dg_data = {s1_dg_data_train, s2_dg_data_train, s3_dg_data_train};
test_ecog_data = {s1_ecog_data_test, s2_ecog_data_test, s3_ecog_data_test};
test_dg_data = {s1_dg_data_test, s2_dg_data_test, s3_dg_data_test};

f_matrix = train_model(train_ecog_data, train_dg_data);
save('f_matrix.mat', 'f_matrix');

%%
predictions = make_predictions(test_ecog_data);
correlations = zeros(3,1,5);

% winLen = 0.1;
% winOverlap = 0.05;
% sample_rate_dg = 1000;
% winLenS = sample_rate_dg * winLen;
% winOverlapS = sample_rate_dg * winOverlap;

% Y_actual = zeros(3,height(predictions{1}), 5);
% for s = 1:3
%     height(predictions{s})
%     for i = 1:height(predictions{s})
%         Y_actual(s, i, :) = test_dg_data{s}((i-1) * winOverlapS + winLenS, :);
%     end
% end

pltno = 1;
figure();
subplot(2,2,1);
plot(predictions{pltno}(:,1));
hold on
plot(test_dg_data{pltno}(:,1));
hold off
subplot(2,2,2);
plot(predictions{pltno}(:,2));
hold on
plot(test_dg_data{pltno}(:,2));
hold off
subplot(2,2,3);
plot(predictions{pltno}(:,3));
hold on
plot(test_dg_data{pltno}(:,3));
hold off
subplot(2,2,4);
plot(predictions{pltno}(:,5));
hold on
plot(test_dg_data{pltno}(:,5));
hold off

for s = 1:3
    for i = 1:5
        correlations(s,1,i) = corr(predictions{s}(:,i), test_dg_data{s}(:,i));
    end
end

means = mean(correlations);
mean(means(:,:,[1,2,3,5]))

vars = {'samples_s1', 'samples_s3', 'samples_s2', 'vars'};
vars2 = {'train_dg', 'train_ecog', 'train_split', 'vars1'};
clear(vars{:});
clear(vars2{:});
clearvars s1*
clearvars s2*
clearvars s3*

%%
load('leaderboard_data.mat');
leaderboard_ecog{1}(:,61) = [];
leaderboard_ecog{2}(:,21) = [];
leaderboard_ecog{2}(:,38) = [];

predicted_dg = make_predictions(leaderboard_ecog);
save('predict_dg.mat', 'predicted_dg');

%% Get Features
% run getWindowedFeats_release function
winLen = 0.1;
winOverlap = 0.05;
windowed = getWindowedFeats(s1_ecog_data_train, sample_rate_ecog, winLen, winOverlap);

%% Create R matrix
% run create_R_matrix
N = 3;
R = create_R_matrix(windowed, N);

load("testRfunction.mat");
R_test = create_R_matrix(testR_features, N);

R_test_mean = mean(mean(R_test))

vars = {'testR_features', 'N_wind', 'vars'};
clear(vars{:})

%% Train classifiers (8 points)


% Classifier 1: Get angle predictions using optimal linear decoding. That is, 
% calculate the linear filter (i.e. the weights matrix) as defined by 
% Equation 1 for all 5 finger angles.

Y = zeros(height(R), 5);
winLenS = sample_rate_dg * winLen;
winOverlapS = sample_rate_dg * winOverlap;
for i = 1:height(R)
    Y(i, :) = s1_dg_data_train((i-1) * winOverlapS + winLenS, :);
end

RtR = R.' * R;
RtY = R.' * Y;

f = mldivide(RtR,RtY);

windowed_test = getWindowedFeats(s1_ecog_data_test, sample_rate_ecog, winLen, winOverlap);
R_test = create_R_matrix(windowed_test, N);

Y_hat = R_test * f;
Y_actual = zeros(height(Y_hat), 5);

for i = 1:height(Y_hat)
    Y_actual(i, :) = s1_dg_data_test((i-1) * winOverlapS + winLenS, :);
end

vars = {'i', 'winLenS', 'winOverlapS', 'vars'};
clear(vars{:})
% Try at least 1 other type of machine learning algorithm, you may choose
% to loop through the fingers and train a separate classifier for angles 
% corresponding to each finger

Y_hat_svm= zeros(height(windowed_test),5);
for i = 1:5
    Mdl = fitrsvm(R,Y(:,i));
    Y_hat_svm(:,i) = predict(Mdl, R_test); 
end

% Try a form of either feature or prediction post-processing to try and
% improve underlying data or predictions.



%% Correlate data to get test accuracy and make figures (2 point)

% Calculate accuracy by correlating predicted and actual angles for each
% finger separately. Hint: You will want to use zohinterp to ensure both 
% vectors are the same length.
correlations = zeros(1,5);
correlations_svm = zeros(1,5);

for i = 1:5
    correlations(1,i) = corr(Y_hat(N:end,i), Y_actual(N:end,i));
    correlations_svm(1,i) = corr(Y_hat_svm(1:end,i), Y_actual(1:end,i));
end
correlations
correlations_svm
