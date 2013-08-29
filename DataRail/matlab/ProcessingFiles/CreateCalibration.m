function [fitted_params]=CreateCalibration(Parameters)
% CreateCalibration creates the calibration curves for the cytokine concentrations
%
%   [fitted_params]=CreateCalibration(Parameters)
%
%
%--------------------------------------------------------------------------
% INPUTS:
%
% Parameters
%            .MidasFile('') = pass calibration curves as a midas file
%            .MatFile('')   = pass calibration curves a mat file
%            .Matrix('')    = to pass the calibration curves in Matrix form
%
%                             data provided with the standard samples
%
%            .PlotFits(no) = plots fits of calibration curves to
%                            calibration data
%
% The calibration curves must be defined in the form:
%
%            MeasuredData = 14 X numberreadouts matrix with the data measured
%                           in the bioplex for the standard samples
%            CalibrationData = 14 X numberreadouts matrix with
%                           concentration
%
% OUTPUTS:
%
% fitted_params = structure with the fields
%              .Value= matrix will the parameters for the calibration curves
%              .Labels=array of strings with the labels of the readouts
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%   Parameters.Matfile='Cal_27x-5005744-Feb07_23x-5005844-Feb07.mat'
%   params= CreateCalibration(Parameters)
%
%--------------------------------------------------------------------------
% TODO:
%
% -
%

%--------------------------------------------------------------------------
% Copyright 2007 President and Fellow of Harvard College
%
%
%  This file is part of SBPipeline.
%
%    SBPipeline is free software; you can redistribute it and/or modify
%    it under the terms of the GNU Lesser General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%
%    SBPipeline is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    Contact: Julio Saez-Rodriguez       Arthur Goldsipe
%    SBPipeline.harvard.edu%

DefaultParameters = struct(...
    'PlotFits','no',...
    'MidasFile', '',...
    'MatFile', '',...
    'Matrix', []);

Parameters = setParameters(Parameters);

exclusiveParameters = {'MidasFile', 'MatFile', 'Matrix'};
numExclusive = 0;
for i=1:numel(exclusiveParameters)
    if ~isempty(Parameters.exclusiveParameters{i})
        numExclusive = numExclusive + 1;
    end
end

if numExclusive == 0
    error('No calibration curves provided')
elseif numExclusive > 1
    error('You have provided more than one source for calibration data.')
end

if ~isempty(Parameters.MidasFile)
    try
        iTreatment = 1;
        iSignal = 3;
        CalibrationStruct   = GuiMidasImporter(Parameters.MidasFile);
        fitted_params.Labels= CalibrationStruct.Labels(iSignal);
        MeasuredData        = CalibrationStruct.Value;
        numConc = numel( fitted_params.Labels(iTreatment).Value );
        numSignal = numel( fitted_params.Labels(iSignal).Value );
        CalibrationData     = zeros(numConc, numSignal);
        for i=1:numConc
            thisLabel = fitted_params.Labels(iTreatment).Value{i};
            thisList = splitString(thisLabel, '_');
            if numel(thisList) ~= numSignal
                error('Unexpected calibration label. Label should contain one entry per signal.');
            end
            for j=1:numSignal
                fields = regexprep(thisList{j}, '=', 'split');
                if numel(fields) ~= 2
                    error('Unexpected calibration label. Label should contain one entry per signal.');
                end
                if ~strcmp(fields{1}, CalibrationStruct.Labels(iSignal).Value{j})
                    error('Concentration fields are in a different order than signal fields.');
                end
                CalibrationData(i,j) = sscanf('%f', fields{2});
            end
        end

    catch
        error('no proper calibration data provided')
    end
elseif ~isempty(Parameters.MatFile)
    try
        load(Parameters.MatFile,'fitted_params')
    catch
        error('the mat file provided does not include calibration parameters')
    end

elseif ~isempty(Parameters.Matrix)
    fitted_params=Parameters.Matrix;
end

if strcmp(Parameters.PlotFits,'yes')
    figure;
end

fitted_params=zeros(5,50);
par_two_vec=ones(50,1);
par_two_vec(20)=1.1;
for numcyto = 1:50
    ydata=MeasuredData(:,numcyto);     % Measured data for each cytokine i.e. IL1b
    xdata=CalibrationData(:,numcyto);  % Calibrated data for each cytokine (i.e. IL1b) by using lot# and dilution factors

    %for Cal_27x-5005151-Oct06_23x-5005844-Feb07.mat
    %par_one   =  MeasuredData(size(MeasuredData,1),numcyto);                   %parameter1 (a) estimate response at 0 conc
    %par_two   =  .5   ;                                                        %parameter2 (b) slope factor
    %par_three =  CalibrationData(3,numcyto);                                   %parameter3 (c) mid range conc
    %par_four  =  MeasuredData(1,numcyto);                                      %parameter4 (d) estimate response at inf conc
    %par_five  =  1.;                                                           %parameter5 (g) asymetric factor

    %for Cal_27x-5005744-Feb07_23x-5005844-Feb07.mat
    par_one   =  MeasuredData(size(MeasuredData,1),numcyto);                   %parameter1 (a) estimate response at 0 conc
    par_two   =  par_two_vec(numcyto)   ;                                                       %parameter2 (b) slope factor
    par_three =  CalibrationData(2,numcyto);                                   %parameter3 (c) mid range conc
    par_four  =  MeasuredData(1,numcyto);                                      %parameter4 (d) estimate response at inf conc
    par_five  =  1.;                                                           %parameter5 (g) asymetric factor

    [estimates, model] = fitcurve(xdata, ydata, [par_one par_two par_three par_four par_five]);
    [sse, FittedCurve] = model(estimates);


    fitted_params.Value(:,numcyto)=estimates;

    if strcmp(Parameters.PlotFits,'yes')
        subplot(5,10,numcyto);
        semilogx(xdata, ydata, '*');
        hold on
        subplot(5,10,numcyto);
        semilogx(xdata, FittedCurve, 'r');
    end

end
end

%%-----
function [estimates, model] = fitcurve(xdata, ydata, start_point)
% xdata: calibration_data obtained from the lot#of the vial and the dillution numbers (named "conc" in luminex)
% ydata: measured data minus the blank


model=@Five_PLfun;
AA=[-1  0  0  0  0 ;
    1  0  0  0  0 ;
    0  1  0  0  0 ;
    0 -1  0  0  0 ;
    0  0  1  0  0 ;
    0  0 -1  0  0 ;
    0  0  0 -1  0 ;
    0  0  0  1  0 ];

bb=[0 1000 10  2  30000  0  0  32000 ];
estimates = fmincon(model, start_point, AA, bb);

    function [sse, FittedCurve] = Five_PLfun(paramets)
        FittedCurve = curvefunc(xdata, paramets);
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end

end

%%
function [val] = curvefunc(x, paramets)
a = paramets(1);
b = paramets(2);
c = paramets(3);
d = paramets(4);
g = paramets(5);

val = d + (a - d) ./ ((1. + (x / c).^ b )) .^ g;
end

