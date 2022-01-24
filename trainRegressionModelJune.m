function [trainedModel, validationRMSE] = trainRegressionModelJune(trainingData)

inputTable = trainingData;
predictorNames = {'Distance', 'TimeOfDay', 'DayOfWeek'};
predictors = inputTable(:, predictorNames);
response = inputTable.AveSpeed;
isCategoricalPredictor = [false, false, true];

% regressionTree
regressionTree = fitrtree(...
    predictors, ...
    response, ...
    'MinLeafSize', 4, ...
    'Surrogate', 'off');

predictorExtractionFcn = @(t) t(:, predictorNames);
treePredictFcn = @(x) predict(regressionTree, x);
trainedModel.predictFcn = @(x) treePredictFcn(predictorExtractionFcn(x));

trainedModel.RequiredVariables = {'DayOfWeek', 'Distance', 'TimeOfDay'};
trainedModel.RegressionTree = regressionTree;
trainedModel.About = 'This struct is a trained model exported from Regression Learner R2020a.';
trainedModel.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

inputTable = trainingData;
predictorNames = {'Distance', 'TimeOfDay', 'DayOfWeek'};
predictors = inputTable(:, predictorNames);
response = inputTable.AveSpeed;
isCategoricalPredictor = [false, false, true];

partitionedModel = crossval(trainedModel.RegressionTree, 'KFold', 5);

validationPredictions = kfoldPredict(partitionedModel);

% Compute validation RMSE
validationRMSE = sqrt(kfoldLoss(partitionedModel, 'LossFun', 'mse'));
