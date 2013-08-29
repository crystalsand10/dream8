function [ThreshData] =Threshold(DataCube,Parameters)

% DataCube: 5-D data cube
% Parameters: 
%   .Threshold Significance Threshold, values below this are replaced 
%   .Replacement  : value to replace thresholded values with.

ThreshData = DataCube;
ThreshData(DataCube < Parameters.LowerThresh) = Parameters.LowReplaceVal;
ThreshData(DataCube > Parameters.UpperThresh) = Parameters.UpReplaceVal;
