function update_graph_plot(allumoData, index)
humanModel = allumoData.humanModel;

steps = ceil(length(humanModel.working_index) / 4000);

timestamp = humanModel.timestamp();

for i=1:3
    allumoData.pelvisplot{i}.XData = timestamp(1:steps:end);
    allumoData.pelvisplot{i}.YData = humanModel.working_pelvisAcc(1:steps:end,i);
end

for i=1:3
    allumoData.cuisseplot{i}.XData = timestamp(1:steps:end);
    allumoData.cuisseplot{i}.YData = humanModel.working_cuissegaucheAcc(1:steps:end,i);
end
xlim([timestamp(1), timestamp(end)])

axe = ancestor(allumoData.cuisseplot{1},'axes');
if ((timestamp(end) - timestamp(1)) > 3600*24)
    time_format = 'mm/dd HH';
    axe.XTickLabel = arrayfun(@(x) [datestr(seconds(x) + humanModel.start_time,time_format) 'h'],...
                                axe.XTick,...
                                'UniformOutput', false);
else
    time_format = 'HH:MM:SS';
    axe.XTickLabel = arrayfun(@(x) datestr(seconds(x) + humanModel.start_time,time_format),...
                                axe.XTick,...
                                'UniformOutput', false);
end

                            



ylim([-1.2 1.2])


allumoData.lineplot.XData = [timestamp(index) timestamp(index)];
allumoData.lineplot.YData = [-1.2 1.2];