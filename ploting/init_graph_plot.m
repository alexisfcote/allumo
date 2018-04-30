function init_graph_plot(allumoData)
humanModel = allumoData.humanModel;

for i=1:3
    allumoData.pelvisplot{i} = plot(humanModel.pelvisAcc(:,i));
    hold on
end

for i=1:3
    allumoData.cuisseplot{i} = plot(humanModel.cuissegaucheAcc(:,i));
    hold on
end