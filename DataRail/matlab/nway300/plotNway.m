function [] = plotNway(XFac,YFac,XLabels,YLabels,ModeLabels,FontSize)
if nargin < 6
    FontSize = 12;
end
% Do plots of first 2 PC's for first 3 modes
nDimX = numel(XFac);
nDimY = numel(YFac);
nPC = size(XFac{1},2);
for i=1:min(4, max(nDimX,nDimY)) % mode
    h = subplot(2,2,i);
    set(h,'FontSize',FontSize);
    if (i <= nDimX && ~isempty(XFac{i})) && (i <= nDimY && ~isempty(YFac{i}))
        plot(XFac{i}(:,1),XFac{i}(:,2),'ro',YFac{i}(:,1),YFac{i}(:,2),'bx');
        for j = 1:size(XFac{i},1)
            text(XFac{i}(j,1),XFac{i}(j,2),[' ' XLabels{i}{j}], 'Color', 'r',...
                'FontSize',FontSize);
        end
        for j = 1:size(YFac{i},1)
            text(YFac{i}(j,1),YFac{i}(j,2),[' ' YLabels{i}{j}], 'Color', 'b',...
                'FontSize',FontSize);
        end
    elseif i > nDimX || isempty(XFac{i})
        plot(YFac{i}(:,1),YFac{i}(:,2),'bx');
        for j = 1:size(YFac{i},1)
            text(YFac{i}(j,1),YFac{i}(j,2),[' ' YLabels{i}{j}], 'Color', 'b',...
                'FontSize',FontSize);
        end
    elseif i > nDimY || isempty(YFac{i})
        plot(XFac{i}(:,1),XFac{i}(:,2),'ro');
        for j = 1:size(XFac{i},1)
            text(XFac{i}(j,1),XFac{i}(j,2),[' ' XLabels{i}{j}], 'Color', 'r',...
                'FontSize',FontSize);
        end
    else
        error('Unexpected case');
    end
    xlabel('PC1');
    ylabel('PC2');
    title(ModeLabels{i})
    plotOrigin;
end

function [] = plotOrigin
XLim = get(gca,'XLim');
YLim = get(gca,'YLim');
hold on
plot(XLim, [0 0], 'k-');
plot([0 0], YLim, 'k-');
hold off