function fhandle = subscriptIterator(sz)
% subscriptIterator creates a subscript iterator for a particular size matrix
%
% fhandle = ind2sub_generator(sizeVector)
%
% when the iterator terminates, the subsripts are all set to false
%
%--------------------------------------------------------------------------
% INPUTS:
% sizeVector  = vector containing array size
%
% OUTPUTS:
% fhandle     = function handle
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
% x = magic(3,3);
% subs = cell(1,3);
% mysub = ind2sub_generator(size(x));
% for i=indices
%   [subs{:}] = mysub(i);
%   ...
% end
%
%--------------------------------------------------------------------------
% TODO:
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

nd = numel(sz);
subs = repmat({1}, 1, nd);
subs{1} = 0;
i=0;
    function varargout = iterator
        % Check whether subs is all zero, denoting end of iteration
        if subs{1} == 0 && i ~= 0
            varargout = subs;
            return
        end
        subs{1} = subs{1} + 1;
        i=1;
        try
            while subs{i} > sz(i)
                subs{i} = 1;
                i = i+1;
                % catch subscripting past cell length to signify end
                subs{i};
                subs{i} = subs{i}+1;
            end
        catch
            [subs{:}] = deal(0);
        end
        varargout = subs;
    end

fhandle = @iterator;
end