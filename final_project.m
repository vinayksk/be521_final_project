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

train_split = 0.7;

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

clearvars s1*
clearvars s2*
clearvars s3*
clearvars samples*
clearvars train_dg
clearvars train_ecog

%%
    
f_matrix = train_model(train_ecog_data, train_dg_data);
save('f_matrix.mat', 'f_matrix');
fprintf("Done training\n");

%%
[predictions, data] = make_predictions(test_ecog_data);
fprintf("Done predicting\n");

%%
plot_points = 0;
plot_spline = 1;
correlations = zeros(3,5);
filters = cell(3,5);
[b,a] = ellip(9,25,120,0.1,'low'); % 0.04
for s = 1:3
    for f = 1:5
        filters{s,f} = [b;a];
    end
end

filtered = cell(3,1);
for s = 1:3
    temp = predictions{s};
    for f = 1:5
        temp(:,f) = filtfilt(filters{s,f}(1,:),filters{s,f}(2,:),temp(:,f));
    end
    filtered{s} = temp;
end

if plot_points
    for pltno = 3
        figure();
        subplot(2,2,1);
        pred = data{pltno}(2, :);
        time = data{pltno}(1, :);
        plot(time, pred, '.');
        hold on
        plot(test_dg_data{pltno}(:,1));
        hold off
        legend("predicted", "Actual");
        subplot(2,2,2);
        pred = data{pltno}(3, :);
        plot(time, pred, '.');
        hold on
        plot(test_dg_data{pltno}(:,2));
        hold off
        legend("predicted", "Actual");
        subplot(2,2,3);
        pred = data{pltno}(4, :);
        plot(time, pred, ".");
        hold on
        plot(test_dg_data{pltno}(:,3));
        hold off
        legend("predicted", "Actual");
        subplot(2,2,4);
        pred = data{pltno}(6, :);
        plot(time, pred, '.');
        hold on
        plot(test_dg_data{pltno}(:,5));
        hold off
        legend("predicted", "Actual");
    end
end

if plot_spline
    for pltno = 1
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
end

for s = 1:3
    for i = 1:5
        correlations(s,i) = corr(filtered{s}(:,i), test_dg_data{s}(:,i));
    end
end

correlations
means = mean(correlations)
corr_coeff = mean(means(1,[1,2,3,5]))

vars = {'temp', 'means', 'correlations', 's', 'i', 'pltno', 'plot_points', 'plot_spline', 'vars'};
vars1 = {'train_dg', 'train_ecog', 'train_split', 'time', 'pred', 'temp', 'filtered', 'f', 'b', 'a', 'filters', 'vars1'};
clear(vars{:});
clear(vars1{:});
clearvars s1*
clearvars s2*
clearvars s3*

%%
load('leaderboard_data.mat');
[predicted_dg, data] = make_predictions(leaderboard_ecog);
filters = cell(3,5);
[b,a] = ellip(9,25,120,0.04,'low');
for s = 1:3
    for f = 1:5
        filters{s,f} = [b;a];
    end
end

for s = 1:3
    temp = predicted_dg{s};
    for f = 1:5
        temp(:,f) = filtfilt(filters{s,f}(1,:),filters{s,f}(2,:),temp(:,f));
    end
    predicted_dg{s} = temp;
end

vars = {'temp', 'f', 's', 'filters', 'b', 'a', 'data', 'vars'};
clear(vars{:});

save('predict_dg.mat', 'predicted_dg');