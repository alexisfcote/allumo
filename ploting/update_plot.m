function update_plot(allumoData, index)
i = index;
humanModel = allumoData.humanModel;

pelvis_mat = humanModel.pelvis_mat;
cuissegauche_mat = humanModel.cuissegauche_mat;

BodyCenter_Rot = pelvis_mat(:,:,i);
Bassin_Rot = pelvis_mat(:,:,i);
Lomb1_Rot = pelvis_mat(:,:,i);
Cou_Rot = pelvis_mat(:,:,i);
Tete_Rot = pelvis_mat(:,:,i);
EpauleDroite_Rot = pelvis_mat(:,:,i);
EpauleGauche_Rot = pelvis_mat(:,:,i);
CoudeDroite_Rot = pelvis_mat(:,:,i);
CoudeGauche_Rot = pelvis_mat(:,:,i);
MainDroite_Rot = pelvis_mat(:,:,i);
MainGauche_Rot = pelvis_mat(:,:,i);
HancheDroite_Rot = eye(3,3);
HancheGauche_Rot = cuissegauche_mat(:,:,i);
GenouDroite_Rot = eye(3,3);
GenouGauche_Rot = cuissegauche_mat(:,:,i);
PiedDroite_Rot = eye(3,3);
PiedGauche_Rot = eye(3,3);

Bassin_POS = BodyCenter_Rot*humanModel.Bassin_Trans+humanModel.BodyCenter_POS;
Lomb1_POS = Bassin_Rot*humanModel.Lomb1_Trans+Bassin_POS;
Cou_POS = Lomb1_Rot*humanModel.Cou_Trans+Lomb1_POS;
Tete_POS = Cou_Rot*humanModel.Tete_Trans+Cou_POS;
EpauleDroite_POS = Lomb1_Rot*humanModel.EpauleDroite_Trans+Lomb1_POS;
EpauleGauche_POS = Lomb1_Rot*humanModel.EpauleGauche_Trans+Lomb1_POS;
CoudeDroite_POS = EpauleDroite_Rot*humanModel.CoudeDroite_Trans+EpauleDroite_POS;
CoudeGauche_POS = EpauleGauche_Rot*humanModel.CoudeGauche_Trans+EpauleGauche_POS;
MainDroite_POS = CoudeDroite_Rot*humanModel.MainDroite_Trans+CoudeDroite_POS;
MainGauche_POS = CoudeGauche_Rot*humanModel.MainGauche_Trans+CoudeGauche_POS;
HancheDroite_POS = BodyCenter_Rot*humanModel.HancheDroite_Trans+Bassin_POS;
HancheGauche_POS = BodyCenter_Rot*humanModel.HancheGauche_Trans+Bassin_POS;
GenouDroite_POS = HancheDroite_Rot*humanModel.GenouDroite_Trans+HancheDroite_POS;
GenouGauche_POS = HancheGauche_Rot*humanModel.GenouGauche_Trans+HancheGauche_POS;
PiedDroite_POS = GenouDroite_Rot*humanModel.PiedDroite_Trans+GenouDroite_POS;
PiedGauche_POS = GenouGauche_Rot*humanModel.PiedGauche_Trans+GenouGauche_POS;

offsetzzero=min(PiedDroite_POS(3)+1,PiedGauche_POS(3)+1);

Bassin_POS(3)=Bassin_POS(3)-offsetzzero;
Lomb1_POS(3)=Lomb1_POS(3)-offsetzzero;
Cou_POS(3)=Cou_POS(3)-offsetzzero;
Tete_POS(3)=Tete_POS(3)-offsetzzero;
EpauleDroite_POS(3)=EpauleDroite_POS(3)-offsetzzero;
EpauleGauche_POS(3)=EpauleGauche_POS(3)-offsetzzero;
CoudeDroite_POS(3)=CoudeDroite_POS(3)-offsetzzero;
CoudeGauche_POS(3)=CoudeGauche_POS(3)-offsetzzero;
MainDroite_POS(3)=MainDroite_POS(3)-offsetzzero;
MainGauche_POS(3)=MainGauche_POS(3)-offsetzzero;
HancheDroite_POS(3)=HancheDroite_POS(3)-offsetzzero;
HancheGauche_POS(3)=HancheGauche_POS(3)-offsetzzero;
GenouDroite_POS(3)=GenouDroite_POS(3)-offsetzzero;
GenouGauche_POS(3)=GenouGauche_POS(3)-offsetzzero;
PiedDroite_POS(3)=PiedDroite_POS(3)-offsetzzero;
PiedGauche_POS(3)=PiedGauche_POS(3)-offsetzzero;


list_of_pos = {
    Bassin_POS,
    Lomb1_POS,
    Cou_POS,
    Tete_POS,
    EpauleDroite_POS,
    EpauleGauche_POS,
    CoudeDroite_POS,
    CoudeGauche_POS,
    MainDroite_POS,
    MainGauche_POS,
    HancheDroite_POS,
    HancheGauche_POS,
    GenouDroite_POS,
    GenouGauche_POS,
    PiedDroite_POS,
    PiedGauche_POS};

list_of_link = {
    [Bassin_POS Lomb1_POS],
    [Lomb1_POS Cou_POS],
    [Cou_POS Tete_POS],
    [Cou_POS EpauleDroite_POS],
    [Cou_POS EpauleGauche_POS],
    [EpauleDroite_POS CoudeDroite_POS],
    [EpauleGauche_POS CoudeGauche_POS],
    [CoudeDroite_POS MainDroite_POS],
    [CoudeGauche_POS MainGauche_POS],
    [Bassin_POS HancheDroite_POS],
    [Bassin_POS HancheGauche_POS],
    [HancheDroite_POS GenouDroite_POS],
    [HancheGauche_POS GenouGauche_POS],
    [GenouDroite_POS PiedDroite_POS],
    [GenouGauche_POS PiedGauche_POS],
    };

list_of_axes = {
    [HancheGauche_POS, HancheGauche_Rot],
    [HancheDroite_POS, HancheDroite_Rot],
    [GenouGauche_POS, GenouGauche_Rot],
    [GenouDroite_POS, GenouDroite_Rot],
    [Bassin_POS, Bassin_Rot]
    };

for j=1:length(list_of_pos)
    data = list_of_pos{j};
    allumoData.p{j}.XData = [data(1);data(1)];
    allumoData.p{j}.YData = [data(2);data(2)];
    allumoData.p{j}.ZData = [data(3);data(3)];
end

for j=1:length(list_of_link)
    data = list_of_link(j);
    data = data{1};
    allumoData.l{j}.XData = [data(1,1);data(1,2)];
    allumoData.l{j}.YData = [data(2,1);data(2,2)];
    allumoData.l{j}.ZData = [data(3,1);data(3,2)];
end

allumoData.tete.XData = [Tete_POS(1)+Tete_Rot(1,2)*0.05;Tete_POS(1)+Tete_Rot(1,2)*0.15];
allumoData.tete.YData = [Tete_POS(2)+Tete_Rot(2,2)*0.05;Tete_POS(2)+Tete_Rot(2,2)*0.15];
allumoData.tete.ZData = [Tete_POS(3)+Tete_Rot(3,2)*0.05;Tete_POS(3)+Tete_Rot(3,2)*0.15];

for j=1:length(list_of_axes)
    idx = j-1;
    POS = list_of_axes{j}(:,1);
    Rot = list_of_axes{j}(:,2:4);
    for k=1:3
        allumoData.a{idx*3+k}.XData=[POS(1);POS(1)+Rot(1,k)*0.1];
        allumoData.a{idx*3+k}.YData=[POS(2);POS(2)+Rot(2,k)*0.1];
        allumoData.a{idx*3+k}.ZData=[POS(3);POS(3)+Rot(3,k)*0.1];
    end
end

drawnow();

end