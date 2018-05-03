classdef HumanModel < handle
    %HUMANMODEL Classe contenant les données des accéléromètre pour
    % l'application Allumo
    
    properties
        pelvisAcc
        cuissegaucheAcc
        
        pelvis_mat
        cuissegauche_mat

        timestamp
        
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
    end
    
    methods
        function obj = HumanModel(pelvisfilename, cuissefilename, varargin)
            day = 1;
            
            for i=1:length(varargin)
                if varargin{i} == 'day'
                    day = varargin{i+1};
                end
            end
            
            
            [pathstr,name,ext] = fileparts(pelvisfilename);
            if strcmp(ext, '.xlsx')
                beginat=1;
                obj.pelvisAcc = xlsread(pelvisfilename);obj.pelvisAcc(1:beginat,:)=[];
                obj.cuissegaucheAcc = xlsread(cuissefilename);obj.cuissegaucheAcc(1:beginat,:)=[];
            elseif strcmp(ext, '.csv')
                obj.pelvisAcc = csvread(pelvisfilename,11,0, [11+30*3600*(day-1) 0 11+30*3600*day 2]);
                obj.cuissegaucheAcc = csvread(cuissefilename,11,0, [11+30*3600*(day-1) 0 11+30*3600*day 2]);
                
                obj.pelvisAcc = [(1:length(obj.pelvisAcc))' obj.pelvisAcc];
                obj.cuissegaucheAcc = [(1:length(obj.cuissegaucheAcc))' obj.cuissegaucheAcc];
            end
            
            cuissegaucheAcctemp=obj.cuissegaucheAcc;obj.cuissegaucheAcc=[];
            pelvisAcctemp=obj.pelvisAcc;obj.pelvisAcc=[];
            
            index=1;
            for i=1:1:size(cuissegaucheAcctemp,1)
                cuissegaucheAcctemp2(index,:)=cuissegaucheAcctemp(i,:);
                pelvisAcctemp2(index,:)=pelvisAcctemp(i,:);
                
                index=index+1;
            end
            
            obj.pelvisAcc = pelvisAcctemp2(:,2:4);
            obj.cuissegaucheAcc = cuissegaucheAcctemp2(:,2:4);
            
            if ~all(pelvisAcctemp2(:,1) == cuissegaucheAcctemp2(:,1))
                error('Les timestamps des deux accéléromètres ne correspondent pas')
            end
            
            obj.timestamp = cuissegaucheAcctemp2(:,1);
            
            methodeAccelAngle = 1;
            if (methodeAccelAngle==1)
                for i=1:1:size(obj.cuissegaucheAcc,1)
                    
                    thetaX_pelvis = atan2(obj.pelvisAcc(i,2),obj.pelvisAcc(i,3));
                    thetaY_pelvis = atan2(obj.pelvisAcc(i,1),obj.pelvisAcc(i,3));
                    Rx_pelvis=[1 0 0;0 cos(thetaX_pelvis) -sin(thetaX_pelvis);0 sin(thetaX_pelvis) cos(thetaX_pelvis)];
                    Ry_pelvis=[cos(thetaY_pelvis) 0 sin(thetaY_pelvis);0 1 0;-sin(thetaY_pelvis) 0 cos(thetaY_pelvis)];
                    pelvis(:,:,i) = Ry_pelvis*Rx_pelvis*eye(3,3);
                    
                    thetaX_cuisse = atan2(obj.cuissegaucheAcc(i,2),obj.cuissegaucheAcc(i,3));
                    thetaY_cuisse = atan2(obj.cuissegaucheAcc(i,1),obj.cuissegaucheAcc(i,3));
                    Rx_cuisse=[1 0 0;0 cos(thetaX_cuisse) -sin(thetaX_cuisse);0 sin(thetaX_cuisse) cos(thetaX_cuisse)];
                    Ry_cuisse=[cos(thetaY_cuisse) 0 sin(thetaY_cuisse);0 1 0;-sin(thetaY_cuisse) 0 cos(thetaY_cuisse)];
                    cuissegauche(:,:,i) = Ry_cuisse*Rx_cuisse*eye(3,3);
                end
            end
            
            cuissegauche_mat_temp=cuissegauche;
            pelvis_mat_temp=pelvis;
            
            pelvis_mat_zero(:,:,:) = pelvis(:,:,:);
            cuissegauche_mat_zero(:,:,:) = cuissegauche(:,:,:);
            
            cuissegauche_offset=cuissegauche_mat_zero(:,:,1)';
            pelvis_offset=pelvis_mat_zero(:,:,1)';
            
            for i=1:1:size(obj.cuissegaucheAcc,1)
                obj.pelvis_mat(:,:,i)=pelvis_mat_zero(:,:,i);
                obj.pelvis_mat(:,:,i)=obj.pelvis_mat(:,:,i)*pelvis_offset;
                obj.cuissegauche_mat(:,:,i)=cuissegauche_mat_zero(:,:,i);
                obj.cuissegauche_mat(:,:,i)=obj.cuissegauche_mat(:,:,i)*cuissegauche_offset;
            end
        end
        
        
    end
    
end

