function graph_to_dot(adj, varargin)

% graph_to_dot(adj, VARARGIN)  Creates a GraphViz (AT&T) format file representing 
%                     a graph given by an adjacency matrix.
%  Optional arguments should be passed as name/value pairs [default]
%
%   'filename'  -  if omitted, writes to 'tmp.dot'
%  'arc_label'  -  arc_label{i,j} is a string attached to the i-j arc [""]
% 'node_label'  -  node_label{i} is a string attached to the node i ["i"]
%  'width'      -  width in inches [10]
%  'height'     -  height in inches [10]
%  'leftright'  -  1 means layout left-to-right, 0 means top-to-bottom [0]
%  'directed'   -  1 means use directed arcs, 0 means undirected [1]
%   'arc_color' -   color of the i-j arc %__ ADDED
%   'node_color' -   color of node i %__ ADDED
%
% For details on dotty, See http://www.research.att.com/sw/tools/graphviz
%
% by Dr. Leon Peshkin, Jan 2004      inspired by Kevin Murphy's  BNT
%    pesha @ ai.mit.edu /~pesha

% Extended by Jonathan Epperlein, Okt 2008
%   jonathan_epperlein@hms.harvard.edu
% Added some things you can specify:
% - you can label an edge "connector", if the func is used for hypergraphs
%  -- you can also specify the style
% - you can specify a color for edges
% - you can also specify a color for nodes
% - and negative edges

                   
node_label = [];   arc_label = [];   % set default args
width = 10;        height = 10;
leftright = 0;     directed = 1;     filename = 'tmp.dot';
arc_colour = [];  node_colour = []; node_style = [];  %__ ADDED
isconnector = []; %__ ADDED this identifies nodes which are only virtual nodes in hyperedges
                                % their shape is set in 'connectorstyle'
cstyle = ' width=.05 height=.05 fixedsize=true shape="circle" style="filled" label="" ';
neg = true(size(adj,2)); ranks={};
           
for i = 1:2:nargin-1              % get optional args
    switch varargin{i}
        case 'filename', filename = varargin{i+1};
        case 'node_label', node_label = varargin{i+1};
        case 'arc_label', arc_label = varargin{i+1};
        case 'width', width = varargin{i+1};
        case 'height', height = varargin{i+1};
        case 'leftright', leftright = varargin{i+1};
        case 'directed', directed = varargin{i+1};
        case 'arc_color', arc_colour = varargin{i+1};   %__ ADDED
        case 'node_color', node_colour = varargin{i+1};   %__ ADDED
        case 'node_style', node_style = varargin{i+1};
        case 'isconnector', isconnector = varargin{i+1};  %__ ADDED
        case 'connectorstyle', cstyle = varargin{i+1};  %__ ADDED
        case 'isneg', neg = varargin{i+1};
        case 'ranks', ranks = varargin{i+1};
    end
end
fid = fopen(filename, 'w');
if directed
    fprintf(fid, 'digraph G {\n');
    for i=1:numel(ranks)
        if (i==1), fprintf(fid, '{\n rank=source;\n');
        elseif (i==numel(ranks))&&(numel(ranks)>1),
            fprintf(fid, '{\n rank=sink;\n');
        else
            fprintf(fid, '{\n rank=same;\n');
        end
        rankstring = [];
        for j=1:numel(ranks{i})
            rankstring = [rankstring int2str(ranks{i}(j)) '; ']; %#ok<AGROW>
        end
        fprintf(fid, [rankstring '\n}\n']);
    end
    arctxt = '->'; 
%     if isempty(arc_label)
    if isempty(arc_label)&&isempty(arc_colour) %__ ADDED
        alc = 0; %__ ADDED
        labeltxt = '[arrowhead="%s"]';
%     else 
    elseif ~isempty(arc_label)&&isempty(arc_colour) %__ ADDED
        alc = 1; %__ ADDED
        labeltxt = '[arrowhead="%s" label="%s"]';
    elseif isempty(arc_label)&&~isempty(arc_colour) %__ ADDED
        alc = 2; %__ ADDED        
        labeltxt = '[arrowhead="%s" color="%s"]'; %__ ADDED
    else %__ ADDED
        alc = 3; %__ ADDED        
        labeltxt = '[arrowhead="%s" label="%s" color="%s"]'; %__ ADDED
    end
else
    fprintf(fid, 'graph G {\n');
    arctxt = '--'; 
    if isempty(arc_label)
        labeltxt = '[dir=none]';
    else
        labeltxt = '[label="%s",dir=none]';
    end
end
fprintf(fid, 'center = 1;\n');
fprintf(fid, 'size=\"%d,%d\";\n', width, height);
if leftright
    fprintf(fid, 'rankdir=LR;\n');
end

Nnds = length(adj);
for node = 1:Nnds               % process NODEs 
    str1 = sprintf('%d [', node);
    strend = ' ];\n';
    s = [];
    if ~isempty(node_label)
        s1 = sprintf(' label="%s"', node_label{node});
        s = [s s1]; %#ok<AGROW>
    end
    if ~isempty(node_colour)
        s2 = sprintf(' color="%s"', node_colour{node});
        s = [s s2]; %#ok<AGROW>
    end
    if ~isempty(node_style)
        s2 = sprintf(' style="%s"', node_style{node});
        s = [s s2]; %#ok<AGROW>
    end
    if ~isempty(isconnector) % at the end so it overwrites all prior styles and colors
        if isconnector{node}
            if ~isempty(arc_colour)
                n2 = find(adj(node,:)==1);
                s = [s cstyle sprintf(' color="%s" ',arc_colour{node,n2(1)})]; %#ok<AGROW>
            else
                s = [s cstyle]; %#ok<AGROW>
            end
        end
    end    
    fprintf(fid,[str1 s strend]);
%     if isempty(node_label)
%         fprintf(fid, '%d;\n', node);
%     else
%         fprintf(fid, '%d [ label = "%s" ];\n', node, node_label{node});
%     end    
end

edgeformat = strcat(['%d ',arctxt,' %d ',labeltxt,';\n']);
% edgeformat = strcat(['%d ',arctxt,' %d ',labeltxt,';\n']);
for node1 = 1:Nnds              % process ARCs
    if directed
        arcs = find(adj(node1,:));         % children(adj, node);
    else
        arcs = find(adj(node1,node1+1:Nnds)) + node1; % remove duplicate arcs
    end
    for node2 = arcs
%         if isempty(arc_label)     % thanks to Nicholas Wayne Henderson nwh@owlnet.rice.edu
%             fprintf(fid, edgeformat, node1, node2);  
%         else
%             fprintf(fid, edgeformat, node1, node2, arc_label{node1,node2});
%         end
    if ~neg(node1,node2), arrowhead = 'odot';
    elseif ~isempty(isconnector)
        if isconnector{node2}
            arrowhead = 'none'; 
        else arrowhead = 'normal';
        end
    else arrowhead = 'normal';
    end
        switch alc  %__ ADDED
            case 0, fprintf(fid, edgeformat, node1, node2, arrowhead);  %__ ADDED
            case 1, fprintf(fid, edgeformat, node1, node2, arrowhead, arc_label{node1,node2}); %__ ADDED
            case 2, fprintf(fid, edgeformat, node1, node2, arrowhead, arc_colour{node1,node2}); %__ ADDED
            case 3, fprintf(fid, edgeformat, node1, node2, arrowhead, ...
                        arc_label{node1,node2}, arc_colour{node1, node2}); %__ ADDED
        end              
    end
end
fprintf(fid, '}'); 
fclose(fid);