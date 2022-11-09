%%
% code to run imaging processing on all videos and make matrix
% to use:
%   download all mp4 videos to a folder
%   make sure Chirs_Imagining_3 and imaging are in this folder
%   download other data sheet as csv from drive 
%   run 'ML' in command line
% 
% skip this section if you already have feature matrix saved!

clear;

%get directory with videos (edit this)
myDir = 'C:\Users\acbon\OneDrive\Documents\3411 Systems\project\mp4videos'; 
myFiles = dir(fullfile(myDir,'*.mp4')); %gets all mp4 files in dir
samples = length(myFiles);
%make final data matrix
raw_features=zeros(samples, 156);
for i = 1:samples
    baseFileName = myFiles(i).name;
    fullFileName = fullfile(baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    %chris_im takes vid name as input, returns features from imaging.m 
    raw_features(i,:)=Chris_Imaging_3(fullFileName);
end
raw_features
writematrix(raw_features, 'raw_features.csv');
% stop here to just get raw data, feature matrix made and saved
% saving isnt needed but it saves so much time later

%%

%start data formatting, open saved csv from earlier
clear;
close all;  
raw_features = readtable('raw_features.csv');
raw_features=table2array(raw_features);
samples = length(raw_features(:,1));

%add in other features, subjects should be in order
others = readtable('Project_Data.csv');   %open excel sheet
heights = others.Height_in_;
weights = others.Weight;
age = others.Age;
gender = others.F_;

Y=others.Injury_binary_(1:samples,1); %classifier

final_data = zeros(samples+3, 160);
final_data(1:20,1:156)=raw_features;    %col 1:156 = frame data
final_data(1:20,157)=heights(1:samples, 1); %col 157 = height
final_data(1:20, 158)=weights(1:samples, 1);    %col 158 = weight
final_data(1:20, 159)=age(1:samples, 1);    %col 159 = age
final_data(1:20, 160)=gender(1:samples, 1); %col 160=gender
%duplicate some injury rows for better results:
final_data(21, :)=final_data(1, :);     
final_data(22, :)=final_data(7, :);
final_data(23, :)=final_data(8, :);

%extend injury vector for duplicated rows
Y(21:23)=[1;1;1];

%%

% label features
vars=string.empty;
k=0;
for i=1:13
    for j=1:4
        vars(i+k)=strcat(['frame' num2str(i) ' sensor' num2str(j) ' var']);
        k=k+1;
        vars(i+k)=strcat(['frame' num2str(i) ' sensor' num2str(j) ' mean']);
        k=k+1;
        vars(i+k)=strcat(['frame' num2str(i) ' sensor' num2str(j) ' median']);
        k=k+1;
    end
end
%not sure why there is some NaN labels, but lets remove them
vars = rmmissing(vars);
vars(157)='height';
vars(158)='weight';
vars(159)='age';
vars(160)='gender';

%%

%rank features 
[idx,scores] = fscchi2(final_data, Y);    %chi square rank
x=1:160;
figure;
b1= bar(x(1), scores(idx(1)));  %seperate bar for feature 1

hold on 
b2= bar(x(2), scores(idx(2)));  %feature 2

hold on 
b3= bar(x(3),scores(idx(3)));   %feature 3

hold on
bar(x(1,4:160), scores(idx(4:160))) %rest of features
hold off

%nice. cool graph
legend([b1 b2 b3],vars(idx(1)),vars(idx(2)), vars(idx(3)))
xticks(0:10:160);
xlabel('Features');
ylabel('Chi Square Score (Feature Importance)');
title('Feature Ranking')

%lets drop the 60 least important features, avoid overfitting
clean_data = final_data;
clean_vars = vars;
clean_data(:, idx(101:160))=[];
clean_vars(:, idx(101:160))=[];

%%

%Model 1: k-fold cross validation method

rng('default');
c = cvpartition(23,'KFold',6);  %change k? 6 seems ok, 10 might underfit
%parameters to optimize:
opts = struct('CVPartition',c,'AcquisitionFunctionName','expected-improvement-plus');
Mdl1 = fitcsvm(clean_data,Y,'KernelFunction','rbf','OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts)

%%

%Model 2: trained on partitioned cv data

hpartition = cvpartition(23,'Holdout',0.3); % Nonstratified partition
%get training indices, and training data
idxTrain = training(hpartition);
tblTrain = clean_data(idxTrain,:);
YTrain = Y(idxTrain);
%get testing indices, and testing data
idxTest = test(hpartition);
tblTest = clean_data(idxTest,:);
YTest = Y(idxTest);
%optimize model parameters:
opts = struct('AcquisitionFunctionName','expected-improvement-plus');
Mdl2 = fitcsvm(tblTrain,YTrain,'KernelFunction','rbf','OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts);

%%

% how did she do?
disp('Model 1');
trainError = resubLoss(Mdl1)     %show overall error
trainAccuracy = 1-trainError    %show overall accuracy
cvMdl1 = crossval(Mdl1); % Performs stratified 10-fold cross-validation
cvtrainError = kfoldLoss(cvMdl1)     %show cv error
cvtrainAccuracy = 1-cvtrainError    %show cv accuracy
newError = loss(Mdl1,tblTest,YTest);
newAccuracy = 1-newError  

disp(' ');
disp( 'Model 2');
trainError = resubLoss(Mdl2)     %show overall error
trainAccuracy = 1-trainError    %show overall accuracy
cvMdl2 = crossval(Mdl2); % Performs stratified 10-fold cross-validation
cvtrainError = kfoldLoss(cvMdl2)     %show cv error
cvtrainAccuracy = 1-cvtrainError    %show cv accuracy
newError = loss(Mdl2,tblTest,YTest);
newAccuracy = 1-newError            %accuracy on test data

%make predictions on test data, show confusion matrix
Ypred1 = predict(Mdl1, tblTest);
Ypred2 = predict(Mdl2, tblTest);
figure;
confusionchart(YTest,Ypred1);
title('k-fold cv (model 1)');
figure;
confusionchart(YTest, Ypred2);
title('partitioned cv (model 2)');

