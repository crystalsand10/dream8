function varargout = GuiLoadDataFileWWW(varargin)


% GuiLoadDataFileWWW downloads a file from a list of them
%
% varargout = GuiLoadDataFileWWW(varargin)
%  
%--------------------------------------------------------------------------
% INPUTS:
%
% varargin = a string containing a url where a list of files are listed.
%
%
% OUTPUTS:
%
% varargout = the name of the file created
%
%--------------------------------------------------------------------------
% EXAMPLE:
%
%  FilenName = GuiLoadDataFileWWW(https://pipeline.med.harvard.edu/...
%               wiki/index.php/list_raw_data')
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


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiLoadDataFileWWW_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiLoadDataFileWWW_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && isempty(strmatch('http', varargin{1}))
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function GuiLoadDataFileWWW_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for GuiLoadDataFileWWW
handles.output = hObject;
handles.Files=GetFileContent(varargin{1});
set(handles.ListOfFiles,'string',handles.Files);
%handles.YouHaveChosen=false;
handles.LocalFileName='';
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GuiLoadDataFileWWW_OutputFcn(hObject, eventdata, handles) 
uiwait;

try
    handles = guihandles;
    handles = guidata(hObject);
    varargout{1} = handles.LocalFileName;
    delete(hObject);
catch
    varargout{1} = [];
end

function ListOfFiles_Callback(hObject, eventdata, handles)
%handles.YouHaveChosen=true;
guidata(hObject, handles);

function ListOfFiles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FetchFile_Callback(hObject, eventdata, handles)
%if handles.YouHaveChosen
    handles.ChosenFileNumber=get(handles.ListOfFiles,'Value');
    handles.ChosenFileName=handles.Files{handles.ChosenFileNumber};
    guidata(hObject, handles);
    %WikiMain='http://web.mit.edu/juliosae/www/';
    WikiMain='https://pipeline.med.harvard.edu/sandbox/index.php/Special:SBW_API?method=get_file&filename=';
    Message='Select the name of the local file to save the data in';
    Que=questdlg(Message,'','OK','Cancel','OK');
    if strcmp(Que,'Cancel')
                    return
    end
    [name path]=uiputfile(handles.ChosenFileName,Message);
    if isnumeric(name) && name == 0
        % no file selected
        return
    end
    handles.LocalFileName=[path name];
    %FileContent=urlread([WikiMain handles.ChosenFileName]);
    %PrintFile(FileContent,handles.ChosenFileName);
    urlwrite([WikiMain handles.ChosenFileName],handles.LocalFileName);
%else
%    warndlg('Select the file you want to fetch')
%    return
%end
guidata(hObject, handles);
uiresume;

%%  

function ListFiles=GetFileContent(UrlName)
Content=urlread(UrlName);
s=textscan(Content,'%s');
ListFiles=s{1};


%k=1;
%cha=1;
%while cha<(numel(Content))
%    ListFiles{k}='';
%     if cha==(numel(Content))
%        return
%    end  
%    while ~strcmp(Content(cha),',')%filesname end in ,   
%       ListFiles{k} = [ListFiles{k} Content(cha)];
%       cha=cha+1;
%    end 
%    cha=cha+2;
%    k=k+1;
%end
%   if (prod(size(ListFiles{k})) == 0)
%        break;
%   end     
%   k=k+1;
   %with char we convert java.lang.String to char
%end


%Replaced by URLREAD
%url = java.net.URL(UrlName);
%is = openStream(url);   %Open a connection to the URL.
%isr = java.io.InputStreamReader(is);%Set up a buffered stream reader
%br = java.io.BufferedReader(isr);   %Set up a buffered stream reader
%k=1;
%while 1   
%   ListFiles{k} = char(readLine(br)); 
%   if (prod(size(ListFiles{k})) == 0)
%        break;
%   end     
%   k=k+1;
   %with char we convert java.lang.String to char
%end

% Java-based function nor required- Replaced by URLWRITE
%function PrintFile(FileContent,FileName)
%fid = fopen(FileName, 'w');
%for i=1:numel(FileContent)
%    fprintf(fid, FileContent{i});
%end
%fclose(fid)










