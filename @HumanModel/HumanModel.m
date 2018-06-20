classdef HumanModel < handle
    %HUMANMODEL Classe contenant les données des accéléromètre pour
    % l'application Allumo
    
    properties
        raw_pelvisAcc
        raw_cuissegaucheAcc
        
        pelvisAcc
        cuissegaucheAcc
        
        pelvis_mat
        cuissegauche_mat
        
        pelvisfilename
        cuissefilename
        
        sampling_rate
        timestamp
        
        calibration_times = {};
    end
    
    properties
        % Configuration parameters
        rectify_window_length = 20 % s
        rectify_skip = 100 % samples
        rectify_low_pass_cutoff = 1/10 % Hz
        filter_low_pass_cutoff = 5 % Hz
    end
    
    properties
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
            elseif strcmp(name(1:2), 'SN')
                start_at = 11+obj.sampling_rate*3600*hour+1;
                end_at   = 11+obj.sampling_rate*3600*(hour+1);
                
                obj.pelvisAcc       = dlmread(pelvisfilename, ',',[start_at 0 end_at 2]);
                obj.cuissegaucheAcc = dlmread(cuissefilename, ',',[start_at 0 end_at 2]);
            elseif strcmp(ext, '.csv')
                start_at = obj.sampling_rate*3600*hour+1;
                end_at   = obj.sampling_rate*3600*(hour+1);
                
                obj.pelvisAcc       = dlmread(pelvisfilename, ',');
                obj.cuissegaucheAcc = dlmread(cuissefilename, ',');
            end
            
            obj.raw_pelvisAcc = obj.pelvisAcc(:, :);
            obj.raw_cuissegaucheAcc = obj.cuissegaucheAcc(:, :);
            obj.timestamp = (start_at + [1:length(obj.cuissegaucheAcc)]) / obj.sampling_rate;
            
            obj.calculate_rotation_matrix();
        end
        
        function calculate_rotation_matrix(obj)
            
            for i=1:1:size(obj.cuissegaucheAcc,1)
                
                thetaX_pelvis = atan2(obj.pelvisAcc(i,1),obj.pelvisAcc(i,3));
                thetaY_pelvis = atan2(obj.pelvisAcc(i,2),obj.pelvisAcc(i,3));
                Rx_pelvis=[1 0 0;0 cos(thetaX_pelvis) -sin(thetaX_pelvis);0 sin(thetaX_pelvis) cos(thetaX_pelvis)];
                Ry_pelvis=[cos(thetaY_pelvis) 0 sin(thetaY_pelvis);0 1 0;-sin(thetaY_pelvis) 0 cos(thetaY_pelvis)];
                pelvis(:,:,i) = Ry_pelvis*Rx_pelvis*eye(3,3);
                
                thetaX_cuisse = atan2(obj.cuissegaucheAcc(i,1),obj.cuissegaucheAcc(i,3));
                thetaY_cuisse = atan2(obj.cuissegaucheAcc(i,2),obj.cuissegaucheAcc(i,3));
                Rx_cuisse=[1 0 0;0 cos(thetaX_cuisse) -sin(thetaX_cuisse);0 sin(thetaX_cuisse) cos(thetaX_cuisse)];
                Ry_cuisse=[cos(thetaY_cuisse) 0 sin(thetaY_cuisse);0 1 0;-sin(thetaY_cuisse) 0 cos(thetaY_cuisse)];
                cuissegauche(:,:,i) = Ry_cuisse*Rx_cuisse*eye(3,3);
            end
            
            cuissegauche_mat_temp=cuissegauche;
            
            pelvis_mat_zero(:,:,:) = pelvis(:,:,:);
            cuissegauche_mat_zero(:,:,:) = cuissegauche(:,:,:);
            
            cuissegauche_offset=cuissegauche_mat_zero(:,:,1)';
            pelvis_offset=pelvis_mat_zero(:,:,1)';
            
            for i=1:1:size(obj.cuissegaucheAcc,1)
                obj.pelvis_mat(:,:,i)=pelvis_mat_zero(:,:,i);
                %obj.pelvis_mat(:,:,i)=obj.pelvis_mat(:,:,i)*pelvis_offset;
                obj.cuissegauche_mat(:,:,i)=cuissegauche_mat_zero(:,:,i);
                %obj.cuissegauche_mat(:,:,i)=obj.cuissegauche_mat(:,:,i)*cuissegauche_offset;
            end
        end
        
        function filter(obj)
            obj.pelvisAcc = obj.filter_mat(obj.raw_pelvisAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            obj.cuissegaucheAcc = obj.filter_mat(obj.raw_cuissegaucheAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
        end
        
        function rectify(obj)
            obj.filter()
            obj.pelvisAcc = rectify_acc(...
                obj.pelvisAcc,...
                obj.sampling_rate, ...
                obj.rectify_low_pass_cutoff, ...
                obj.rectify_window_length, ...
                obj.rectify_skip );
            obj.cuissegaucheAcc = rectify_acc(...
                obj.cuissegaucheAcc, ...
                obj.sampling_rate, ...
                obj.rectify_low_pass_cutoff, ...
                obj.rectify_window_length, ...
                obj.rectify_skip );
            
            obj.apply_all_calibration_time()
            obj.calculate_rotation_matrix()
            
        end
        
        function set_calibrationzone_point(obj,index_calibration_start,index_calibration_stop, index_start, index_stop)
            lowpelvisAcc = obj.filter_mat(obj.raw_pelvisAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            lowcuissegaucheAcc = obj.filter_mat(obj.raw_cuissegaucheAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            
            Qpelvis = HumanModel.get_rectifying_Q(...
                mean(lowpelvisAcc(index_calibration_start:index_calibration_stop, :))', ...
                lowpelvisAcc(index_start:index_stop, :)'...
                );
            Qcuissegauche = HumanModel.get_rectifying_Q(...
                mean(lowcuissegaucheAcc(index_calibration_start:index_calibration_stop, :))', ...
                lowcuissegaucheAcc(index_start:index_stop, :)'...
                );
            
            calibration_time = CalibrationTime(index_start, index_stop, Qpelvis, Qcuissegauche);
            obj.calibration_times{end+1} = calibration_time;
            
            obj.apply_calibration_time(calibration_time);
            obj.calculate_rotation_matrix()
        end
        
        function apply_calibration_time(obj, calibration_time)
            pelvisAcc = obj.filter_mat(obj.raw_pelvisAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            cuissegaucheAcc = obj.filter_mat(obj.raw_cuissegaucheAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            
            for i=calibration_time.start_index:calibration_time.stop_index
                obj.pelvisAcc(i, :) = (calibration_time.Qpelvis *  pelvisAcc(i, :)')';
                obj.cuissegaucheAcc(i, :) = (calibration_time.Qcuissegauche *  cuissegaucheAcc(i, :)')';
            end
        end       
        
        function apply_all_calibration_time(obj)
            for i = 1:length(obj.calibration_times)
                calibration_time = obj.calibration_times{i};
                if ~isempty(calibration_time)
                    obj.apply_calibration_time(calibration_time);
                end
            end
        end
        
        function clear_all_calibration_time(obj)
            obj.calibration_times = {};
            obj.rectify();
        end
    end
    methods(Static)
        function Q = get_rectifying_Q(gvector, mat)
            g = [0 0 -1]';
            Q1 = get_Q_aligning_2_vector(gvector, g);
            
            gravity_compensated_mat = Q1*mat;
            [U,~,~] = svd(gravity_compensated_mat(1:2, :));
            Q2 = eye(3);
            Q2(1:2, 1:2) = U;
            Q = Q2 * Q1;
            
        end
        
        function filtered_mat = filter_mat(mat, sampling_rate, cut_off_frequency)
            cof = cut_off_frequency; % Hz
            nyquist = sampling_rate/2;
            wn = cof/nyquist;
            
            [b, a] = butter(4, wn, 'low');
            
            filtered_mat = zeros(size(mat));
            for i=1:length(mat(1,:))
                filtered_mat(:,i) = filtfilt(b, a, mat(:,i));
            end
        end
        
    end
end

