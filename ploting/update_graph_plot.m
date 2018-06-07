function update_graph_plot(allumoData, index)
humanModel = allumoData.humanModel;
for i=1:3
    allumoData.pelvisplot{i}.XData = humanModel.timestamp;
    allumoData.pelvisplot{i}.YData = humanModel.pelvisAcc(:,i);
end

for i=1:3
    allumoData.cuisseplot{i}.XData = humanModel.timestamp;
    allumoData.cuisseplot{i}.YData = humanModel.cuissegaucheAcc(:,i);
end
xlim([humanModel.timestamp(1), humanModel.timestamp(end)])

axe = ancestor(allumoData.cuisseplot{1},'axes');
axe.XTickLabel = arrayfun(@(x) datestr(seconds(x),'HH:MM:SS PM') ,axe.XTick, 'UniformOutput', false);

min_value = min(min([humanModel.pelvisAcc ; humanModel.cuissegaucheAcc]));
max_value = max(max([humanModel.pelvisAcc ; humanModel.cuissegaucheAcc]));
ylim([min_value max_value])

allumoData.lineplot.XData = [humanModel.timestamp(index) humanModel.timestamp(index)];
allumoData.lineplot.YData = [min_value max_value];