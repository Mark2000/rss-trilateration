function saveNiceFigure(fig, dimensions, format, figureFolder, noResize)
    if (nargin < 3)
        format = 'epsc';
    end
    if (nargin < 4)
        figureFolder = 'Figures'; % Where we'll save all the figures
    end
    if (nargin < 5)
        noResize = 0;
    end
    allAxes = findall(fig, 'type', 'axes');
    allAxes = allAxes(~ismember(get(allAxes,'Tag'),{'legend','Colobar'}));
    for ii = 1:length(allAxes)
        % Axes properties
        ax = allAxes(ii);
        ax.FontSize = 8;
        ax.TickLabelInterpreter = 'latex';
        ax.Box = 'off';
        ax.Layer = 'top';

        % Axis label interpreters
        ax.XLabel.Interpreter = 'latex';
        ax.YLabel.Interpreter = 'latex';
    end
    % Legend interpreter
    allLegends = findall(fig, 'type', 'legend');
    for l = allLegends
        set(l, 'Interpreter', 'latex');
    end
    % Export dimensions
    if ~noResize
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 dimensions];
        fig.PaperPositionMode = 'manual';
    end
    [~, ~, ~] = mkdir(figureFolder);
    fileName = fig.Name(~isspace(fig.Name));
    if (strcmp(format, 'epsc'))
        % Save the figure as a color EPS file
        saveas(fig, strcat(figureFolder, filesep(), fileName), format);
    elseif (strcmp(format, 'png'))
        % Save the figure as a high-res PNG file
        print(fig, strcat(figureFolder, filesep(), fileName), '-dpng', '-r300');
    end
end