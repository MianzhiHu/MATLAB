function data = importTaxiFare(filename, dataLines)  %  importTaxiFare

if nargin < 2
    dataLines = [2, Inf];
    
end

opts = delimitedTextImportOptions("NumVariables", 19);

opts.DataLines = dataLines;
opts.Delimiter = ",";
opts.VariableNames = ["Vendor", "PickupTime", "DropoffTime", "Passengers", "Distance", "PickupLon", "PickupLat", "RateCode", "HeldFlag", "DropoffLon", "DropoffLat", "Paytype", "Fare", "ExtraCharge", "Tax", "Tip", "Tolls", "ImpSurcharge", "TotalCharge"];
opts.VariableTypes = ["categorical", "datetime", "datetime", "double", "double", "double", "double", "categorical", "categorical", "double", "double", "categorical", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["Vendor", "RateCode", "HeldFlag", "Paytype"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "PickupTime", "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts = setvaropts(opts, "DropoffTime", "InputFormat", "yyyy-MM-dd HH:mm:ss");


% Import data
data = readtable(filename, opts);


end