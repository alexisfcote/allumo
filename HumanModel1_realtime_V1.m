close all
clear all

Video=1;
MethodeAccelAngle=1;

    if Video==1
        v = VideoWriter('WalkingTest1.avi');
        open(v);
        ftime = figure;
    end

    
beginat=1;
pelvisAcc = xlsread('TestBidonAccelPelvis.xlsx');pelvisAcc(1:beginat,:)=[];
cuissegaucheAcc = xlsread('TestBidonAccelCuisse.xlsx');cuissegaucheAcc(1:beginat,:)=[];

cuissegaucheAcctemp=cuissegaucheAcc;cuissegaucheAcc=[];
pelvisAcctemp=pelvisAcc;pelvisAcc=[];

index=1;
for i=1:1:size(cuissegaucheAcctemp,1)
    cuissegaucheAcctemp2(index,:)=cuissegaucheAcctemp(i,:);
    pelvisAcctemp2(index,:)=pelvisAcctemp(i,:);

    index=index+1;
end



pelvisAcc = pelvisAcctemp2(:,2:4);
cuissegaucheAcc = cuissegaucheAcctemp2(:,2:4);


pelvistimestamp = pelvisAcctemp2(:,1);
cuissegauchetimestamp = cuissegaucheAcctemp2(:,1);





for i=1:1:size(cuissegaucheAcc,1)
    if (MethodeAccelAngle==1)
        thetaX_pelvis = atan2(pelvisAcc(i,2),pelvisAcc(i,3));
        thetaY_pelvis = atan2(pelvisAcc(i,1),pelvisAcc(i,3));
        Rx_pelvis=[1 0 0;0 cos(thetaX_pelvis) -sin(thetaX_pelvis);0 sin(thetaX_pelvis) cos(thetaX_pelvis)];
        Ry_pelvis=[cos(thetaY_pelvis) 0 sin(thetaY_pelvis);0 1 0;-sin(thetaY_pelvis) 0 cos(thetaY_pelvis)];
        pelvis(:,:,i) = Ry_pelvis*Rx_pelvis*eye(3,3);

        thetaX_cuisse = atan2(cuissegaucheAcc(i,2),cuissegaucheAcc(i,3));
        thetaY_cuisse = atan2(cuissegaucheAcc(i,1),cuissegaucheAcc(i,3));
        Rx_cuisse=[1 0 0;0 cos(thetaX_cuisse) -sin(thetaX_cuisse);0 sin(thetaX_cuisse) cos(thetaX_cuisse)];
        Ry_cuisse=[cos(thetaY_cuisse) 0 sin(thetaY_cuisse);0 1 0;-sin(thetaY_cuisse) 0 cos(thetaY_cuisse)];
        cuissegauche(:,:,i) = Ry_cuisse*Rx_cuisse*eye(3,3);
    else

    end
end


cuissegauche_mat_temp=cuissegauche;
pelvis_mat_temp=pelvis;


pelvis_mat_zero(:,:,:) = pelvis(:,:,:);
cuissegauche_mat_zero(:,:,:) = cuissegauche(:,:,:);


cuissegauche_offset=cuissegauche_mat_zero(:,:,1)';
pelvis_offset=pelvis_mat_zero(:,:,1)';



for i=1:1:size(cuissegaucheAcc,1)

    pelvis_mat(:,:,i)=pelvis_mat_zero(:,:,i);
    pelvis_mat(:,:,i)=pelvis_mat(:,:,i)*pelvis_offset;
    
    cuissegauche_mat(:,:,i)=cuissegauche_mat_zero(:,:,i);
    cuissegauche_mat(:,:,i)=cuissegauche_mat(:,:,i)*cuissegauche_offset;

end





BodyCenter_POS = [0;0;0];

BodyCenter_Trans = [0;0;0];
Bassin_Trans = [0;0;0];
Lomb1_Trans = [0;0;0.2];
Cou_Trans = [0;0;0.3];
Tete_Trans = [0;0;0.2];
EpauleDroite_Trans = [0.2;0;0.25];
EpauleGauche_Trans = [-0.2;0;0.25];
CoudeDroite_Trans = [0;0;-0.25];
CoudeGauche_Trans = [0;0;-0.25];
MainDroite_Trans = [0;0;-0.25];
MainGauche_Trans = [0;0;-0.25];
HancheDroite_Trans = [0.1;0;-0.1];
HancheGauche_Trans = [-0.1;0;-0.1];
GenouDroite_Trans = [0;0;-0.5];
GenouGauche_Trans = [0;0;-0.5];
PiedDroite_Trans = [0;0;-0.4];
PiedGauche_Trans = [0;0;-0.4];



index=0;
figure(1)     
     axis([-1 1 -1 1 -1 1]);
     view([5, 15, 6]);
     

%% ALEXIS, IT'S HERE !!!  
first_pass = true;
p = {};
l = {};
a = {};
tic
for i=1:size(pelvis_mat,3)

    
    CameraPosition=campos;
    CameraTarget=camtarget;
    CameraUpVector=camtarget;
    CameraViewAngle=camva;
    
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


    
%     BodyCenter_POS(3) = -min(PiedDroite_POS(3)+1,PiedGauche_POS(3)+1);
    
    
    
    Bassin_POS = BodyCenter_Rot*Bassin_Trans+BodyCenter_POS;
    Lomb1_POS = Bassin_Rot*Lomb1_Trans+Bassin_POS;
    Cou_POS = Lomb1_Rot*Cou_Trans+Lomb1_POS; 
    Tete_POS = Cou_Rot*Tete_Trans+Cou_POS; 
    EpauleDroite_POS = Lomb1_Rot*EpauleDroite_Trans+Lomb1_POS; 
    EpauleGauche_POS = Lomb1_Rot*EpauleGauche_Trans+Lomb1_POS;
    CoudeDroite_POS = EpauleDroite_Rot*CoudeDroite_Trans+EpauleDroite_POS; 
    CoudeGauche_POS = EpauleGauche_Rot*CoudeGauche_Trans+EpauleGauche_POS; 
    MainDroite_POS = CoudeDroite_Rot*MainDroite_Trans+CoudeDroite_POS; 
    MainGauche_POS = CoudeGauche_Rot*MainGauche_Trans+CoudeGauche_POS; 
    HancheDroite_POS = BodyCenter_Rot*HancheDroite_Trans+Bassin_POS;
    HancheGauche_POS = BodyCenter_Rot*HancheGauche_Trans+Bassin_POS;
    GenouDroite_POS = HancheDroite_Rot*GenouDroite_Trans+HancheDroite_POS;
    GenouGauche_POS = HancheGauche_Rot*GenouGauche_Trans+HancheGauche_POS;
    PiedDroite_POS = GenouDroite_Rot*PiedDroite_Trans+GenouDroite_POS;
    PiedGauche_POS = GenouGauche_Rot*PiedGauche_Trans+GenouGauche_POS;

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
        

    %% ALEXIS, IT'S EVEN MORE HERE !!!  
    % ANIMATION SQUELETTE
    if first_pass
        hold off;
        p{1} = plot3([Bassin_POS(1);Bassin_POS(1)],[Bassin_POS(2);Bassin_POS(2)],[Bassin_POS(3);Bassin_POS(3)],'ob');
        hold on;
        p{2} = plot3([Lomb1_POS(1);Lomb1_POS(1)],[Lomb1_POS(2);Lomb1_POS(2)],[Lomb1_POS(3);Lomb1_POS(3)],'ob');
        p{3} = plot3([Cou_POS(1);Cou_POS(1)],[Cou_POS(2);Cou_POS(2)],[Cou_POS(3);Cou_POS(3)],'ob');
        p{4} = plot3([Tete_POS(1);Tete_POS(1)],[Tete_POS(2);Tete_POS(2)],[Tete_POS(3);Tete_POS(3)],'ob','MarkerSize',20);
        p{5} = plot3([EpauleDroite_POS(1);EpauleDroite_POS(1)],[EpauleDroite_POS(2);EpauleDroite_POS(2)],[EpauleDroite_POS(3);EpauleDroite_POS(3)],'ob');
        p{6} = plot3([EpauleGauche_POS(1);EpauleGauche_POS(1)],[EpauleGauche_POS(2);EpauleGauche_POS(2)],[EpauleGauche_POS(3);EpauleGauche_POS(3)],'ob');
        p{7} = plot3([CoudeDroite_POS(1);CoudeDroite_POS(1)],[CoudeDroite_POS(2);CoudeDroite_POS(2)],[CoudeDroite_POS(3);CoudeDroite_POS(3)],'ob');
        p{8} = plot3([CoudeGauche_POS(1);CoudeGauche_POS(1)],[CoudeGauche_POS(2);CoudeGauche_POS(2)],[CoudeGauche_POS(3);CoudeGauche_POS(3)],'ob');
        p{9} = plot3([MainDroite_POS(1);MainDroite_POS(1)],[MainDroite_POS(2);MainDroite_POS(2)],[MainDroite_POS(3);MainDroite_POS(3)],'ob');
        p{10} = plot3([MainGauche_POS(1);MainGauche_POS(1)],[MainGauche_POS(2);MainGauche_POS(2)],[MainGauche_POS(3);MainGauche_POS(3)],'ob');
        p{11} = plot3([HancheDroite_POS(1);HancheDroite_POS(1)],[HancheDroite_POS(2);HancheDroite_POS(2)],[HancheDroite_POS(3);HancheDroite_POS(3)],'ob');
        p{12} = plot3([HancheGauche_POS(1);HancheGauche_POS(1)],[HancheGauche_POS(2);HancheGauche_POS(2)],[HancheGauche_POS(3);HancheGauche_POS(3)],'ob');
        p{13} = plot3([GenouDroite_POS(1);GenouDroite_POS(1)],[GenouDroite_POS(2);GenouDroite_POS(2)],[GenouDroite_POS(3);GenouDroite_POS(3)],'ob');
        p{14} = plot3([GenouGauche_POS(1);GenouGauche_POS(1)],[GenouGauche_POS(2);GenouGauche_POS(2)],[GenouGauche_POS(3);GenouGauche_POS(3)],'ob');
        p{15} = plot3([PiedDroite_POS(1);PiedDroite_POS(1)],[PiedDroite_POS(2);PiedDroite_POS(2)],[PiedDroite_POS(3);PiedDroite_POS(3)],'ob');
        p{16} = plot3([PiedGauche_POS(1);PiedGauche_POS(1)],[PiedGauche_POS(2);PiedGauche_POS(2)],[PiedGauche_POS(3);PiedGauche_POS(3)],'ob');

        linewidth=1;
        l{1} = plot3([Bassin_POS(1);Lomb1_POS(1)],[Bassin_POS(2);Lomb1_POS(2)],[Bassin_POS(3);Lomb1_POS(3)],'b','LineWidth',linewidth);
        l{2} = plot3([Lomb1_POS(1);Cou_POS(1)],[Lomb1_POS(2);Cou_POS(2)],[Lomb1_POS(3);Cou_POS(3)],'b','LineWidth',linewidth);
        l{3} = plot3([Cou_POS(1);Tete_POS(1)],[Cou_POS(2);Tete_POS(2)],[Cou_POS(3);Tete_POS(3)],'b','LineWidth',linewidth);
        l{4} = plot3([Cou_POS(1);EpauleDroite_POS(1)],[Cou_POS(2);EpauleDroite_POS(2)],[Cou_POS(3);EpauleDroite_POS(3)],'b','LineWidth',linewidth);
        l{5} = plot3([Cou_POS(1);EpauleGauche_POS(1)],[Cou_POS(2);EpauleGauche_POS(2)],[Cou_POS(3);EpauleGauche_POS(3)],'b','LineWidth',linewidth);
        l{6} = plot3([EpauleDroite_POS(1);CoudeDroite_POS(1)],[EpauleDroite_POS(2);CoudeDroite_POS(2)],[EpauleDroite_POS(3);CoudeDroite_POS(3)],'b','LineWidth',linewidth);
        l{7} = plot3([EpauleGauche_POS(1);CoudeGauche_POS(1)],[EpauleGauche_POS(2);CoudeGauche_POS(2)],[EpauleGauche_POS(3);CoudeGauche_POS(3)],'b','LineWidth',linewidth);
        l{8} = plot3([CoudeDroite_POS(1);MainDroite_POS(1)],[CoudeDroite_POS(2);MainDroite_POS(2)],[CoudeDroite_POS(3);MainDroite_POS(3)],'b','LineWidth',linewidth);
        l{9} = plot3([CoudeGauche_POS(1);MainGauche_POS(1)],[CoudeGauche_POS(2);MainGauche_POS(2)],[CoudeGauche_POS(3);MainGauche_POS(3)],'b','LineWidth',linewidth);
        l{10} = plot3([Bassin_POS(1);HancheDroite_POS(1)],[Bassin_POS(2);HancheDroite_POS(2)],[Bassin_POS(3);HancheDroite_POS(3)],'b','LineWidth',linewidth);
        l{11} = plot3([Bassin_POS(1);HancheGauche_POS(1)],[Bassin_POS(2);HancheGauche_POS(2)],[Bassin_POS(3);HancheGauche_POS(3)],'b','LineWidth',linewidth);
        l{12} = plot3([HancheDroite_POS(1);GenouDroite_POS(1)],[HancheDroite_POS(2);GenouDroite_POS(2)],[HancheDroite_POS(3);GenouDroite_POS(3)],'b','LineWidth',linewidth);
        l{13} = plot3([HancheGauche_POS(1);GenouGauche_POS(1)],[HancheGauche_POS(2);GenouGauche_POS(2)],[HancheGauche_POS(3);GenouGauche_POS(3)],'b','LineWidth',linewidth);
        l{14} = plot3([GenouDroite_POS(1);PiedDroite_POS(1)],[GenouDroite_POS(2);PiedDroite_POS(2)],[GenouDroite_POS(3);PiedDroite_POS(3)],'b','LineWidth',linewidth);
        l{15} = plot3([GenouGauche_POS(1);PiedGauche_POS(1)],[GenouGauche_POS(2);PiedGauche_POS(2)],[GenouGauche_POS(3);PiedGauche_POS(3)],'b','LineWidth',linewidth);
        
        tete = plot3([Tete_POS(1)+Tete_Rot(1,2)*0.05;Tete_POS(1)+Tete_Rot(1,2)*0.15],[Tete_POS(2)+Tete_Rot(2,2)*0.05;Tete_POS(2)+Tete_Rot(2,2)*0.15],[Tete_POS(3)+Tete_Rot(3,2)*0.05;Tete_POS(3)+Tete_Rot(3,2)*0.15],'b','LineWidth',linewidth);
    
    
        % ANIMATION AXES
        [a{1}, a{2}, a{3}] = plotaxes(HancheGauche_POS, HancheGauche_Rot);
        [a{4}, a{5}, a{6}] = plotaxes(HancheDroite_POS, HancheDroite_Rot);
        [a{7}, a{8}, a{9}] = plotaxes(GenouGauche_POS, GenouGauche_Rot);
        [a{10}, a{11}, a{12}] = plotaxes(GenouDroite_POS, GenouDroite_Rot);
        [a{13}, a{14}, a{15}] = plotaxes(Bassin_POS, Bassin_Rot);

        xlim([-1 1])
        ylim([-1 1])
        zlim([-1 1])
        grid on
        xlabel('x')
        ylabel('y')
        zlabel('z')
        % axis equal

        campos(CameraPosition);
        camtarget(CameraTarget);
        camup(CameraUpVector);
        camva(CameraViewAngle);
        
        first_pass = false;
    else % not first image
        for j=1:length(list_of_pos)
            data = list_of_pos{j};
            p{j}.XData = [data(1);data(1)];
            p{j}.YData = [data(2);data(2)];
            p{j}.ZData = [data(3);data(3)];
        end
       
        for j=1:length(list_of_link)
            data = list_of_link(j);
            data = data{1};
            l{j}.XData = [data(1,1);data(1,2)];
            l{j}.YData = [data(2,1);data(2,2)];
            l{j}.ZData = [data(3,1);data(3,2)];
        end
        
        tete.XData = [Tete_POS(1)+Tete_Rot(1,2)*0.05;Tete_POS(1)+Tete_Rot(1,2)*0.15];
        tete.YData = [Tete_POS(2)+Tete_Rot(2,2)*0.05;Tete_POS(2)+Tete_Rot(2,2)*0.15];
        tete.ZData = [Tete_POS(3)+Tete_Rot(3,2)*0.05;Tete_POS(3)+Tete_Rot(3,2)*0.15];
    
        for j=1:length(list_of_axes)
            idx = j-1;
            POS = list_of_axes{j}(:,1);
            Rot = list_of_axes{j}(:,2:4);
            for k=1:3
                a{idx*3+k}.XData=[POS(1);POS(1)+Rot(1,k)*0.1];
                a{idx*3+k}.YData=[POS(2);POS(2)+Rot(2,k)*0.1];
                a{idx*3+k}.ZData=[POS(3);POS(3)+Rot(3,k)*0.1];
            end
        end
        
    end
    
    title(['Tstamp ' num2str(pelvistimestamp(i)) ' ' num2str(cuissegauchetimestamp(i))],'Color', 'black');
    if Video==1
        writeVideo(v,getframe(ftime));
    end
    
    drawnow;
    

end
toc
if Video==1
    close(v);
end



















