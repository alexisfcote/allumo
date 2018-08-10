function init_graph_plot(allumoData)
humanModel = allumoData.humanModel;
steps = ceil(length(humanModel.working_index) / 4000);

hold off

timestamp = humanModel.timestamp();

col = winter(3);
for i=1:3
    allumoData.pelvisplot{i} = plot(timestamp(1:steps:end), ...
                                    humanModel.working_pelvisAcc(1:steps:end,i), ...
                                    'Color', col(i,:));
    hold on
end

col = autumn(3);
for i=1:3
    allumoData.cuisseplot{i} = plot(timestamp(1:steps:end),...
                                    humanModel.working_cuissegaucheAcc(1:steps:end,i), ...
                                    'Color', col(i,:));
    hold on
end

index=1;
allumoData.lineplot = line([timestamp(index) timestamp(index)], [0 1]);

allumoData.misscalibrationplot = plot(timestamp(1:steps:end),...
                                     ones(length(timestamp(1:steps:end)), 1)+2, ...
                                    'Color', 'red',...
                                    'LineWidth', 10);

update_graph_plot(allumoData, index)