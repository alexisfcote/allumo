classdef HumanModel < handle
    %HUMANMODEL Classe contenant les données des accéléromètre pour
    % l'application Allumo
    
    properties
        pelvisAcc
        cuissegaucheAcc
        
        pelvis_mat
        cuissegauche_mat
        
        pelvisfilename,
        cuissefilename

        sampling_rate
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
        function obj = HumanModel(pelvisfilename, cuissefilename, sampling_rate)
            obj.pelvisfilename = pelvisfilename;
            obj.cuissefilename = cuissefilename;
            obj.sampling_rate = sampling_rate;
            
            obj.load_data()
            
        end
        
        function load_data(obj, varargin)
            pelvisfilename = obj.pelvisfilename;
            cuissefilename = obj.cuissefilename;
            
            hour = 0;
            for i=1:length(varargin)
                if varargin{i} == 'hour'
                    hour = varargin{i+1};
                end
            end
   
            
            [pathstr,name,ext] = fileparts(pelvisfilename);
            if strcmp(ext, '.xlsx')
                start_at=1;
                obj.pelvisAcc = xlsread(pelvisfilename);
                obj.pelvisAcc(1:start_at,:)=[];
                obj.cuissegaucheAcc = xlsread(cuissefilename);
                obj.cuissegaucheAcc(1:start_at,:)=[];
            elseif strcmp(ext, '.csv')
                start_at = 11+obj.sampling_rate*3600*hour+1;
                end_at   = 11+obj.sampling_rate*3600*(hour+1);
                
                obj.pelvisAcc       = dlmread(pelvisfilename, ',',[start_at 0 end_at 2]);
                obj.cuissegaucheAcc = dlmread(cuissefilename, ',',[start_at 0 end_at 2]);
            end
            
            obj.timestamp = (start_at + [1:length(obj.cuissegaucheAcc)]) / obj.sampling_rate;
            
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

