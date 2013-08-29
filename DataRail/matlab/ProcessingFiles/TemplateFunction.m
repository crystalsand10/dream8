function varargout = MidasImporter(filename, dimCols, timeCols, valueCols, parameters)
% MidasImporterMain reads a CSV file based on the MIDAS standard
%
% [data, dimNames, dimValues] = MidasImporter(filename, ...
%             dimCols, timeCols, valueCols, parameters)
%  or
%
% [dataCube] = MidasImporter(...)
%
%--------------------------------------------------------------------------
% INPUTS:
% filename  = name of CSV file
% dimCols   = cell of cells containing column names or numbers for the
%             columns comprising each dimension
% timeCols  = cells containing column names or numbers for the
%             columns comprising the time dimension
% valueCols = cells containing column names or numbers for each "value" field
% parameters(default) = optional structure of parameters
%             .IgnoreMissing (true) = true to ignore missing values, rather than
%                               treat them as NaN's
%
% OUTPUTS:
% data      = hypercube of data
% dimNames  = field names (labels) for each of the dimensions
% dimValues = values for each dimension
% dataCube  = data cube structure
%
%--------------------------------------------------------------------------
% EXAMPLE:
% [data, names, values] = MidasImporter(filename, ...
%        {...% Column names or numbers for each dimension
%        {'TR:HepG2'},%dimension 1 = cells
%        {'TR:NO-CYTO','TR:EGF','TR:HER','TR:AMP','TR:TGF','TR:EGF-HER',...
%         'TR:HER-TGF','TR:AMP-EGF','TR:EPI-TGF','TR:TGF-EGF'},
%        {'TR:NO-DRUG','TR:PI3Ki'},
%         },...
%         {'DA:AKT','DA:ERK12'},...
%         {'DV:AKT','DV:ERK12'}...
%         );
%
%--------------------------------------------------------------------------
% TODO:
%
% - Check the consistency of DA: and DV: fields
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
