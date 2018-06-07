function init_graph_plot(allumoData)
humanModel = allumoData.humanModel;
hold off
for i=1:3
    allumoData.pelvisplot{i} = plot(humanModel.timestamp, humanModel.pelvisAcc(:,i));
    hold on
end

for i=1:3
    allumoData.cuisseplot{i} = plot(humanModel.timestamp, humanModel.cuissegaucheAcc(:,i));
    hold on
end
index=1;
allumoData.lineplot = line([humanModel.timestamp(index) humanModel.timestamp(index)], [0 1]);

update_graph_plot(allumoData, index)