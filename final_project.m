%% Extract dataglove and ECoG data 
% Dataglove should be (samples x 5) array 
% ECoG should be (samples x channels) array
load('raw_training_data.mat');

s1_ecog_data = train_ecog{1,1};
s2_ecog_data = train_ecog{2,1};
s3_ecog_data = train_ecog{3,1};

s1_dg_data = train_dg{1,1};
s2_dg_data = train_dg{2,1};
s3_dg_data = train_dg{3,1};

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

%%
f_matrix = train_model(train_ecog_data, train_dg_data);
save('f_matrix.mat', 'f_matrix');

%%
predictions = make_predictions(test_ecog_data);

%%
correlations = zeros(3,5);
%%(1,1), (1,2), (3,1), (3,5)
%[b,a] = ellip(9,20,210,0.04,'low');
[b,a] = ellip(9,25,120,0.1,'low');
filtered = cell(3,1);
for i = 1:3
    filtered{i} = filtfilt(b,a,predictions{i});
end
filtered{1}(:, 5) = filtered{1}(:, 5)*-1;
% for s = 1:3
%     temp_filt = predictions{s};
%     for f = 1:5
%         if s == 1 && f <= 2
%             [b,a] = ellip(9,20,210,0.04,'low');
%             temp_filt(:, f)= filtfilt(b,a,temp_filt(:, f));
%         end
%           
%         filtered{s} = temp_filt;
%     end
% end

for pltno = 2
figure();
subplot(2,2,1);
plot(filtered{pltno}(:,1));
hold on
plot(test_dg_data{pltno}(:,1));
hold off
legend("predicted", "Actual");
subplot(2,2,2);
plot(filtered{pltno}(:,2));
hold on
plot(test_dg_data{pltno}(:,2));
hold off
legend("predicted", "Actual");
subplot(2,2,3);
plot(filtered{pltno}(:,3));
hold on
plot(test_dg_data{pltno}(:,3));
hold off
legend("predicted", "Actual");
subplot(2,2,4);
plot(filtered{pltno}(:,5));
hold on
plot(test_dg_data{pltno}(:,5));
hold off
legend("predicted", "Actual");
end

for s = 1:3
    for i = 1:5
        correlations(s,i) = corr(filtered{s}(:,i), test_dg_data{s}(:,i));
    end
end

correlations
means = mean(correlations);
mean(means(1,[1,2,3,5]))

vars = {'samples_s1', 'samples_s3', 'samples_s2', 'vars'};
vars2 = {'train_dg', 'train_ecog', 'train_split', 'vars1'};
clear(vars{:});
clear(vars2{:});
clearvars s1*
clearvars s2*
clearvars s3*

%%
load('leaderboard_data.mat');
predicted_dg = make_predictions(leaderboard_ecog);

[b,a] = ellip(9,25,120,0.1,'low');
predicted_dg{1} = filtfilt(b,a,predicted_dg{1});
predicted_dg{2} = filtfilt(b,a,predicted_dg{2});
% [b,a] = ellip(9,20,210,0.04,'low');
predicted_dg{3} = filtfilt(b,a,predicted_dg{3});

save('predict_dg.mat', 'predicted_dg');
