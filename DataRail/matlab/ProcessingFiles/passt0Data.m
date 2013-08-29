function data = passt0Data(data)
% passt0Data copies t=0 data across conditions
%
% [data] = MidasImporter(data)
%
%--------------------------------------------------------------------------
% INPUTS:
% data = array data structure with t=0 data present only in the first level
%        of some dimensions
%
% OUTPUTS:
% data = array data structure with t=0 data copied across all conditions
%
%--------------------------------------------------------------------------
% EXAMPLE:
% data = passt0Data(data)
%
%--------------------------------------------------------------------------
% TODO:
%
% Can't be run completely automatically, b/c a GUI opens to ask about deleting values


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

%% Identify dimensions
tDim = strmatch('time', {data.Labels.Name}, 'exact');
repDim=strmatch('replicate',{data.Labels.Name});
signalDim = strmatch('signal', {data.Labels.Name});
if numel(tDim) ~= 1
    error('Unable to identify the time dimension');
end
if numel(signalDim) ~= 1
    error('Unable to identify signal dimension');
end
sz = size(data.Value);
nd = numel(sz);
%% Create idx to contain indexing of t0 data
idx = cell(1,nd);
for i=1:nd
    idx{i} = 1:sz(i);
end
t0idx = find(data.Labels(tDim).Value == 0);
assert2(numel(t0idx) == 1, 'Expecting one and only one t=0 level.');
idx{tDim} = t0idx;
sz(tDim) = 1;

% Can't copy across signals
idx{signalDim} = ':';
% Save idx in idx0, for use when copying later
idx0 = idx;

t0test = isnan(data.Value(idx{:}));
%% Handle replicates
if any(repDim)
    t0test = all(t0test, repDim);
    idx{repDim} = ':';
end

%% Remove dimensions with all missing data
iDim = 0;
while iDim < nd
    iDim = iDim + 1;
    % skip singleton dimensions
    if numel(idx{iDim}) == 1
        continue
    end
    iValue = 1;
    while iValue <= numel(idx{iDim}) && numel(idx{iDim}) > 1
        idx2 = idx;
        idx2{iDim} = idx{iDim}(iValue);
        % If all missing, delete this dimension
        if allall(t0test(idx2{:}))
            idx{iDim}(iValue) = [];
        else
            iValue = iValue + 1;
        end
    end
end
%% Verify that t0 data either spans the entire dim or exactly one level
badDims = [];
for i=1:nd
    if ~any( numel(idx{i}) == [1, sz(i)] )
        badDims(end+1) = i;
    end
end
if ~isempty(badDims)
    error('Unable to identify t0 data. There appears to be multiple t0 data in the following dimensions: %s', num2str(badDims));
end
%% Fill in t=0 data for other treatments
t0data = data.Value(idx{:});
sz0 = size(t0data);
for i=1:numel(sz)
    if sz(i) ~= sz0(i)
        n = sz(i);
        sz0(i) = n;
        rep = ones(1,numel(sz));
        rep(i) = n;
        t0data = repmat(t0data, rep);
    end
end
data.Value(idx0{:})=t0data;

%% See if data is present at any other times for the t0 condition
% If no other data is present, ask to delete
idxDel = cell(1, nd);
idxDel(:) = {':'};
idxDel{tDim} = setdiff(1:size(data.Value, tDim), t0idx);
deleteDims = [];
for i=1:nd
    if i==tDim, continue, end % skip t dim
    if idx{i} == ':', continue, end % skip t0 dims that have multiple levels
    idxDel1 = idxDel;
    idxDel1{i} = idx{i}; % look at the t0 condition for this dim
    d = data.Value(idxDel1{:});
    if all(isnan(d(:)))
        deleteDims(end+1) = i;
    end
end
if ~isempty(deleteDims)
    Removet0dim=questdlg({'The t=0 condition appears not to have data at any other times.',...
        'Would you like to delete this condition?'}, 'Remove value?', 'Yes','No', 'Yes');
    if strcmp(Removet0dim,'Yes')
        for i=deleteDims
            idxDel(:) = {':'};
            idxDel{i} = idx{i};
            data.Value(idxDel{:}) = [];
            data.Labels(i).Value(idx{i}) = [];
        end
    end
end

function test = allall(data)
test = all(data(:));