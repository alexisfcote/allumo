function init_plot(allumoData)

humanModel = allumoData.humanModel;
i=1;
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


hold off;
allumoData.p{1} = plot3([Bassin_POS(1);Bassin_POS(1)],[Bassin_POS(2);Bassin_POS(2)],[Bassin_POS(3);Bassin_POS(3)],'ob');
hold on;
allumoData.p{2} = plot3([Lomb1_POS(1);Lomb1_POS(1)],[Lomb1_POS(2);Lomb1_POS(2)],[Lomb1_POS(3);Lomb1_POS(3)],'ob');
allumoData.p{3} = plot3([Cou_POS(1);Cou_POS(1)],[Cou_POS(2);Cou_POS(2)],[Cou_POS(3);Cou_POS(3)],'ob');
allumoData.p{4} = plot3([Tete_POS(1);Tete_POS(1)],[Tete_POS(2);Tete_POS(2)],[Tete_POS(3);Tete_POS(3)],'ob','MarkerSize',20);
allumoData.p{5} = plot3([EpauleDroite_POS(1);EpauleDroite_POS(1)],[EpauleDroite_POS(2);EpauleDroite_POS(2)],[EpauleDroite_POS(3);EpauleDroite_POS(3)],'ob');
allumoData.p{6} = plot3([EpauleGauche_POS(1);EpauleGauche_POS(1)],[EpauleGauche_POS(2);EpauleGauche_POS(2)],[EpauleGauche_POS(3);EpauleGauche_POS(3)],'ob');
allumoData.p{7} = plot3([CoudeDroite_POS(1);CoudeDroite_POS(1)],[CoudeDroite_POS(2);CoudeDroite_POS(2)],[CoudeDroite_POS(3);CoudeDroite_POS(3)],'ob');
allumoData.p{8} = plot3([CoudeGauche_POS(1);CoudeGauche_POS(1)],[CoudeGauche_POS(2);CoudeGauche_POS(2)],[CoudeGauche_POS(3);CoudeGauche_POS(3)],'ob');
allumoData.p{9} = plot3([MainDroite_POS(1);MainDroite_POS(1)],[MainDroite_POS(2);MainDroite_POS(2)],[MainDroite_POS(3);MainDroite_POS(3)],'ob');
allumoData.p{10} = plot3([MainGauche_POS(1);MainGauche_POS(1)],[MainGauche_POS(2);MainGauche_POS(2)],[MainGauche_POS(3);MainGauche_POS(3)],'ob');
allumoData.p{11} = plot3([HancheDroite_POS(1);HancheDroite_POS(1)],[HancheDroite_POS(2);HancheDroite_POS(2)],[HancheDroite_POS(3);HancheDroite_POS(3)],'ob');
allumoData.p{12} = plot3([HancheGauche_POS(1);HancheGauche_POS(1)],[HancheGauche_POS(2);HancheGauche_POS(2)],[HancheGauche_POS(3);HancheGauche_POS(3)],'ob');
allumoData.p{13} = plot3([GenouDroite_POS(1);GenouDroite_POS(1)],[GenouDroite_POS(2);GenouDroite_POS(2)],[GenouDroite_POS(3);GenouDroite_POS(3)],'ob');
allumoData.p{14} = plot3([GenouGauche_POS(1);GenouGauche_POS(1)],[GenouGauche_POS(2);GenouGauche_POS(2)],[GenouGauche_POS(3);GenouGauche_POS(3)],'ob');
allumoData.p{15} = plot3([PiedDroite_POS(1);PiedDroite_POS(1)],[PiedDroite_POS(2);PiedDroite_POS(2)],[PiedDroite_POS(3);PiedDroite_POS(3)],'ob');
allumoData.p{16} = plot3([PiedGauche_POS(1);PiedGauche_POS(1)],[PiedGauche_POS(2);PiedGauche_POS(2)],[PiedGauche_POS(3);PiedGauche_POS(3)],'ob');

linewidth=1;
allumoData.l{1} = plot3([Bassin_POS(1);Lomb1_POS(1)],[Bassin_POS(2);Lomb1_POS(2)],[Bassin_POS(3);Lomb1_POS(3)],'b','LineWidth',linewidth);
allumoData.l{2} = plot3([Lomb1_POS(1);Cou_POS(1)],[Lomb1_POS(2);Cou_POS(2)],[Lomb1_POS(3);Cou_POS(3)],'b','LineWidth',linewidth);
allumoData.l{3} = plot3([Cou_POS(1);Tete_POS(1)],[Cou_POS(2);Tete_POS(2)],[Cou_POS(3);Tete_POS(3)],'b','LineWidth',linewidth);
allumoData.l{4} = plot3([Cou_POS(1);EpauleDroite_POS(1)],[Cou_POS(2);EpauleDroite_POS(2)],[Cou_POS(3);EpauleDroite_POS(3)],'b','LineWidth',linewidth);
allumoData.l{5} = plot3([Cou_POS(1);EpauleGauche_POS(1)],[Cou_POS(2);EpauleGauche_POS(2)],[Cou_POS(3);EpauleGauche_POS(3)],'b','LineWidth',linewidth);
allumoData.l{6} = plot3([EpauleDroite_POS(1);CoudeDroite_POS(1)],[EpauleDroite_POS(2);CoudeDroite_POS(2)],[EpauleDroite_POS(3);CoudeDroite_POS(3)],'b','LineWidth',linewidth);
allumoData.l{7} = plot3([EpauleGauche_POS(1);CoudeGauche_POS(1)],[EpauleGauche_POS(2);CoudeGauche_POS(2)],[EpauleGauche_POS(3);CoudeGauche_POS(3)],'b','LineWidth',linewidth);
allumoData.l{8} = plot3([CoudeDroite_POS(1);MainDroite_POS(1)],[CoudeDroite_POS(2);MainDroite_POS(2)],[CoudeDroite_POS(3);MainDroite_POS(3)],'b','LineWidth',linewidth);
allumoData.l{9} = plot3([CoudeGauche_POS(1);MainGauche_POS(1)],[CoudeGauche_POS(2);MainGauche_POS(2)],[CoudeGauche_POS(3);MainGauche_POS(3)],'b','LineWidth',linewidth);
allumoData.l{10} = plot3([Bassin_POS(1);HancheDroite_POS(1)],[Bassin_POS(2);HancheDroite_POS(2)],[Bassin_POS(3);HancheDroite_POS(3)],'b','LineWidth',linewidth);
allumoData.l{11} = plot3([Bassin_POS(1);HancheGauche_POS(1)],[Bassin_POS(2);HancheGauche_POS(2)],[Bassin_POS(3);HancheGauche_POS(3)],'b','LineWidth',linewidth);
allumoData.l{12} = plot3([HancheDroite_POS(1);GenouDroite_POS(1)],[HancheDroite_POS(2);GenouDroite_POS(2)],[HancheDroite_POS(3);GenouDroite_POS(3)],'b','LineWidth',linewidth);
allumoData.l{13} = plot3([HancheGauche_POS(1);GenouGauche_POS(1)],[HancheGauche_POS(2);GenouGauche_POS(2)],[HancheGauche_POS(3);GenouGauche_POS(3)],'b','LineWidth',linewidth);
allumoData.l{14} = plot3([GenouDroite_POS(1);PiedDroite_POS(1)],[GenouDroite_POS(2);PiedDroite_POS(2)],[GenouDroite_POS(3);PiedDroite_POS(3)],'b','LineWidth',linewidth);
allumoData.l{15} = plot3([GenouGauche_POS(1);PiedGauche_POS(1)],[GenouGauche_POS(2);PiedGauche_POS(2)],[GenouGauche_POS(3);PiedGauche_POS(3)],'b','LineWidth',linewidth);

allumoData.tete = plot3([Tete_POS(1)+Tete_Rot(1,2)*0.05;Tete_POS(1)+Tete_Rot(1,2)*0.15],[Tete_POS(2)+Tete_Rot(2,2)*0.05;Tete_POS(2)+Tete_Rot(2,2)*0.15],[Tete_POS(3)+Tete_Rot(3,2)*0.05;Tete_POS(3)+Tete_Rot(3,2)*0.15],'b','LineWidth',linewidth);


% ANIMATION AXES
[allumoData.a{1}, allumoData.a{2}, allumoData.a{3}] = plotaxes(HancheGauche_POS, HancheGauche_Rot);
[allumoData.a{4}, allumoData.a{5}, allumoData.a{6}] = plotaxes(HancheDroite_POS, HancheDroite_Rot);
[allumoData.a{7}, allumoData.a{8}, allumoData.a{9}] = plotaxes(GenouGauche_POS, GenouGauche_Rot);
[allumoData.a{10}, allumoData.a{11}, allumoData.a{12}] = plotaxes(GenouDroite_POS, GenouDroite_Rot);
[allumoData.a{13}, allumoData.a{14}, allumoData.a{15}] = plotaxes(Bassin_POS, Bassin_Rot);

xlim([-1 1])
ylim([-1 1])
zlim([-1 1])
grid on
xlabel('x')
ylabel('y')
zlabel('z')
% axis equal
end

