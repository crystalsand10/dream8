function varargout = startDataRail(interactive)
% startDataRail adds DataRail toolbox directories to the path
% By default, also ask the user whether to start GuiMain
% No questions are asked if called with the first input set to 0, false, or
% a string starting with 'no'.
% in the case of 'nodesktop' the GUI is not started

LoadGui=true;
if ~exist('interactive', 'var')
    interactive=true;
elseif ischar(interactive)
    % keep at most 2 letters
    interactive = interactive(1:min(2,numel(interactive)));
    if strcmpi('no',interactive)
        LoadGui=false;
        interactive=false;
    end
else
    try
        interactive = logical(interactive);
    catch
        error('The input argument "interactive" must be logical or "no*".');
    end
end

if versionLessThan('7.4')
    warning('Some features of DataRail require Matlab 7.4 (R2007a) or later.');
    warndlg(['Your matlab version is older than 7.4. Some features of DataRail'...
    ' require Matlab 7.4 (R2007a) or later, and DataRail may not be stable.'],...
    'Matlab version older than 7.4')
end

% List of dirs to add
toolboxLocation = fileparts(mfilename('fullpath'));
subdirs = {...
    {''},...
    {'ModelingFiles'},...
    {'ProcessingFiles'},...
    {'PlottingFiles'},...
    {'PlottingFiles', 'GraphViz'},...
    {'help'},...
    {'plsr'}, ...
    {'nway300'}, ...
    {'BNSL'},...
    {'DataClasses'} };

% special usage: return toolbox subdirs and exit
if nargout > 0
    % Add full path to toolbox
    for i=1:numel(subdirs);
        subdirs{i} = fullfile( toolboxLocation, subdirs{i}{:} );
    end
    varargout{1} = subdirs;
    return
end



thisfile = mfilename;
thisfullfile = mfilename('fullpath');
i = strfind(thisfullfile, thisfile);
thispath = thisfullfile(1:i-1);
if thispath(end) == pathsep
    thispath = thispath(1:end-1);
end
w = which('GuiMain');
pathmatch = strmatch(thispath, w);
if ~isempty(w) && (isempty(pathmatch) || pathmatch ~= 1)
    warning(['You appear to have another version of the toolbox in your path.\n'...
        'Please use the pathtool to remove the unwanted version from your path.'])
    w = [];
end
if isempty(w)
    addToPath(subdirs);
end
disp('                                              ');
disp('    -*--*--*--*--*--*--*--*--*--*--*--*--*--*-');
disp('   |                                          |');
disp('   |               Welcome to                 |');
disp('   |                                          |');
disp('   |                DataRail                  |');
disp('   |                 v 1.3                    |');
disp('   |       (a component of SBPipeline)        |');
disp('   |                                          |');
disp('   |                10/04/10                  |');
disp('   |                                          |');
disp('   |             For questions contact        |');
disp('   |                                          |');
disp('   | Julio Saez-Rodriguez   Arthur Goldsipe   |');
disp('   | SBPipeline@hms.harvard.edu               |');
disp('   |                                          |');
disp('    -*--*--*--*--*--*--*--*--*--*--*--*--*--*- ')
disp('                                              ');

if LoadGui
    GuiMain;
end
end

function addToPath(subdirs)
% Adds directories to path
disp('      Adding DataRail directories to the path');
filename = mfilename('fullpath');
thisPath = fileparts(filename);


% Go backward, so I can delete any missing directories
for i=numel(subdirs):-1:1
    subdirs{i} = fullfile(thisPath, subdirs{i}{:});
    if ~isdir(subdirs{i})
        subdirs(i) = [];
    end
end
if isempty(subdirs)
    error('Unable to locate any DataRail directories.');
end
addpath(subdirs{:});

disp(' ');
disp('      All paths succesfully loaded'        );
disp(' ');

if ispc
    Save=input('Would you like to save this toolbox to the default path? (y/n) ','s');
    if strcmp(Save,'y')
        result = savepath;
        if result==0
            disp(' ');
            disp('      The default path was successfully saved.'        );
            disp(' ');
        else
            disp(' ');
            disp('      Unable to save as the default path.'        );
            disp(' ');
        end
    end
else
    joinedPath = [thisPath sprintf( [pathsep '%s'], subdirs{:} )];
    
    disp(' ');
    disp('      To permananently add these directories to your Matlab path, add the'        );
    disp('      following to your line to your login shell''s initialization file:'         );
    disp(' ');
    disp('      bash, zsh, etc.:'         );
    disp(['        export MATLABPATH=' joinedPath ]);
    disp(' ');
    disp('      tcsh, csh, etc.:'         );
    disp(['        setenv MATLABPATH ' joinedPath ]);
    disp(' ');
end
end % function addToPath

function isTooOld = versionLessThan(minVersion)
thisVersion = version;
% Convert to array of [major minor revision release ...]
minVersionNum = sscanf(minVersion, '%d.');
thisVersionNum = sscanf(thisVersion, '%d.');

isTooOld = false;
% Test each level of the version number (major, then minor, etc.)
numTests = min(numel(minVersionNum), numel(thisVersionNum));
for i=1:numTests
    if thisVersionNum(i) < minVersionNum(i)
        isTooOld = true;
        break
    end
end
end % versionLessThan
