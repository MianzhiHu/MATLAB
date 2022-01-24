function [trainedClassifier, validationAccuracy] = trainClassifierPweek2(trainingData)
inputTable = trainingData;
predictorNames = {'Vendor', 'Passengers', 'Distance', 'PickupLon', 'PickupLat', 'RateCode', 'HeldFlag', 'DropoffLon', 'DropoffLat', 'PayType', 'Fare', 'ExtraCharge', 'Tax', 'Tip', 'Tolls', 'ImpSurcharge', 'TotalCharge', 'Duration', 'AveSpeed', 'TimeOfDay'};
predictors = inputTable(:, predictorNames);
response = inputTable.WasTollPaid;
isCategoricalPredictor = [true, false, false, false, false, true, true, false, false, true, false, false, false, false, false, false, false, false, false, false];

includedPredictorNames = predictors.Properties.VariableNames([false false false true true true false true true false true false false false false false false false false true]);
predictors = predictors(:,includedPredictorNames);
isCategoricalPredictor = isCategoricalPredictor([false false false true true true false true true false true false false false false false false false false true]);

successClass = true;
failureClass = false;

numSuccess = sum(response);
numFailure = sum(~response);
if numSuccess > numFailure
    missingClass = successClass;
else
    missingClass = failureClass;
end
successFailureAndMissingClasses = [successClass; failureClass; missingClass];
zeroOneResponse = response;

concatenatedPredictorsAndResponse = [predictors, table(zeroOneResponse)];

GeneralizedLinearModel = fitglm(...
    concatenatedPredictorsAndResponse, ...
    'Distribution', 'binomial', ...
    'link', 'logit');

convertSuccessProbsToPredictions = @(p) successFailureAndMissingClasses( ~isnan(p).*( (p<0.5) + 1 ) + isnan(p)*3 );
returnMultipleValuesFcn = @(varargin) varargin{1:max(1,nargout)};
scoresFcn = @(p) [1-p, p];
predictionsAndScoresFcn = @(p) returnMultipleValuesFcn( convertSuccessProbsToPredictions(p), scoresFcn(p) );


predictorExtractionFcn = @(t) t(:, predictorNames);
featureSelectionFcn = @(x) x(:,includedPredictorNames);
logisticRegressionPredictFcn = @(x) predictionsAndScoresFcn( predict(GeneralizedLinearModel, x) );
trainedClassifier.predictFcn = @(x) logisticRegressionPredictFcn(featureSelectionFcn(predictorExtractionFcn(x)));

trainedClassifier.RequiredVariables = {'AveSpeed', 'Distance', 'DropoffLat', 'DropoffLon', 'Duration', 'ExtraCharge', 'Fare', 'HeldFlag', 'ImpSurcharge', 'Passengers', 'PayType', 'PickupLat', 'PickupLon', 'RateCode', 'Tax', 'TimeOfDay', 'Tip', 'Tolls', 'TotalCharge', 'Vendor'};
trainedClassifier.GeneralizedLinearModel = GeneralizedLinearModel;
trainedClassifier.SuccessClass = successClass;
trainedClassifier.FailureClass = failureClass;
trainedClassifier.MissingClass = missingClass;
trainedClassifier.ClassNames = {successClass; failureClass};
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2020a.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

inputTable = trainingData;
predictorNames = {'Vendor', 'Passengers', 'Distance', 'PickupLon', 'PickupLat', 'RateCode', 'HeldFlag', 'DropoffLon', 'DropoffLat', 'PayType', 'Fare', 'ExtraCharge', 'Tax', 'Tip', 'Tolls', 'ImpSurcharge', 'TotalCharge', 'Duration', 'AveSpeed', 'TimeOfDay'};
predictors = inputTable(:, predictorNames);
response = inputTable.WasTollPaid;
isCategoricalPredictor = [true, false, false, false, false, true, true, false, false, true, false, false, false, false, false, false, false, false, false, false];

validationPredictFcn = @(x) logisticRegressionPredictFcn(featureSelectionFcn(x));

[validationPredictions, validationScores] = validationPredictFcn(predictors);

correctPredictions = (validationPredictions == response);
validationAccuracy = sum(correctPredictions)/length(correctPredictions);
