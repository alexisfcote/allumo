function init_graph_plot(allumoData)
humanModel = allumoData.humanModel;
hold off
for i=1:3
    allumoData.pelvisplot{i} = plot(humanModel.pelvisAcc(:,i));
    hold on
end

for i=1:3
    allumoData.cuisseplot{i} = plot(humanModel.cuissegaucheAcc(:,i));
    hold on
end
xlim([1 length(humanModel.cuissegaucheAcc(:,i))])

min_value = min(min([humanModel.pelvisAcc ; humanModel.cuissegaucheAcc]));
max_value = max(max([humanModel.pelvisAcc ; humanModel.cuissegaucheAcc]));
ylim([min_value max_value])
allumoData.lineplot = line([50 50], [min_value max_value]);