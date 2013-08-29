function TextExploreCompendium(varargin)
if ~isempty(varargin)
    Compendium=varargin{1};
else
    Compendium=whos{1};
end

for i=1:numel(Compendium.data)
    disp([num2str(i) ' - ' Compendium.data(i).Name ' - ' num2str(size(Compendium.data(i).Value))])
end