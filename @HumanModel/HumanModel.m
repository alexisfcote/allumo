classdef HumanModel < handle
    %HUMANMODEL Classe contenant les données des accéléromètre pour
    % l'application Allumo
    
    properties
        pelvisfilename
        cuissefilename
        
        raw_pelvisAcc
        raw_cuissegaucheAcc
        raw_timestamp
        
        working_pelvisAcc
        working_cuissegaucheAcc
        working_index
        
        pelvis_mat % "working"
        cuissegauche_mat % "working"
        
        sampling_rate = 60;
        start_time = datetime(2000, 01, 01);
        
        
        calibration_times = {};
        misscalibration_mask
        
        walking_mask
        running_mask
        
        trunk_angle
        
    end
    
    properties
        % Configuration parameters
        rectify_window_length = 60 % s
        rectify_skip = 100 % samples
        rectify_low_pass_cutoff = 1/10 % Hz
        filter_low_pass_cutoff = 2 % Hz
        detect_misscalibration_cutoff = 1/30 %Hz
        
        misscalibration_threshold = -0.5; % g
        
        working_index_max_length = 3600*12*30;
        
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
        function obj = HumanModel(pelvisfilename, cuissefilename, varargin)
            obj.pelvisfilename = pelvisfilename;
            obj.cuissefilename = cuissefilename;
            
            filetype = 'Auto';
            
            for i=1:length(varargin)
                if strcmp(varargin{i}, 'filetype')
                    filetype = varargin{i+1};
                end
            end
            
            [~,~,ext] = fileparts(pelvisfilename);
            
            if strcmp(filetype, 'Auto')
                if strcmp(ext, '.xlsx')
                    filetype = 'xlsx';
                end
                if strcmp(ext, '.csv')
                    fid=fopen(pelvisfilename);
                    for i=1:11
                        line = fgetl(fid);
                    end
                    fclose(fid);
                    
                    if strcmp(line(1:9), 'Timestamp')
                        filetype = 'ActiGraph';
                    else
                        filetype = 'ActiGraph-notimestamp';
                    end
                end
            end
            
            obj.load_data(filetype);
            
        end
        
        function load_data(obj, filetype)
            pelvisfilename = obj.pelvisfilename;
            cuissefilename = obj.cuissefilename; %#ok<*PROPLC>
            
            
            if strcmp(filetype, 'xlsx')
                start_at=1;
                obj.raw_pelvisAcc = xlsread(pelvisfilename);
                obj.raw_pelvisAcc(1:start_at,:)=[];
                obj.raw_cuissegaucheAcc = xlsread(cuissefilename);
                obj.raw_cuissegaucheAcc(1:start_at,:)=[];
                
                
            elseif strcmp(filetype, 'ActiGraph')
                start_at = 1;
                
                obj.raw_pelvisAcc       = dlmread(pelvisfilename, ',', 11+start_at, 1);
                obj.raw_cuissegaucheAcc = dlmread(cuissefilename, ',', 11+start_at, 1);
                
                obj.start_time = get_actigraph_time(pelvisfilename);
                obj.sampling_rate = get_actigraph_samplerate( pelvisfilename );
                
                
            elseif strcmp(filetype, 'ActiGraph-notimestamp')
                start_at = 1;
                
                obj.raw_pelvisAcc       = dlmread(pelvisfilename, ',', 11+start_at, 0);
                obj.raw_cuissegaucheAcc = dlmread(cuissefilename, ',', 11+start_at, 0);
                
                obj.start_time = get_actigraph_time(pelvisfilename);
                obj.sampling_rate = get_actigraph_samplerate( pelvisfilename );
            end
            
            min_len = min(length(obj.raw_pelvisAcc), length(obj.raw_cuissegaucheAcc));
            obj.raw_pelvisAcc       = obj.raw_pelvisAcc(1:min_len,1:3);
            obj.raw_cuissegaucheAcc = obj.raw_cuissegaucheAcc(1:min_len,1:3);
            
            obj.raw_timestamp   = (1:min_len) / obj.sampling_rate;
            
            if length(obj.raw_timestamp) > obj.working_index_max_length
                warning('Data to long, opening region selector')
                obj.working_index = 1:obj.working_index_max_length;
            else
                obj.working_index = 1:length(obj.raw_timestamp);
            end
            
            obj.load_and_filter_working_from_raw();
        end
        
        function set_working_index(obj, index)
            obj.working_index = index;
            obj.load_and_filter_working_from_raw();
        end
        
        function load_and_filter_working_from_raw(obj)
            obj.working_pelvisAcc       = obj.filter_mat(obj.raw_pelvisAcc(obj.working_index, :),...
                                                         obj.sampling_rate, ...
                                                         obj.filter_low_pass_cutoff);
            obj.working_cuissegaucheAcc = obj.filter_mat(obj.raw_cuissegaucheAcc(obj.working_index, :),...
                                                         obj.sampling_rate,...
                                                         obj.filter_low_pass_cutoff);
                                                     
            obj.compute_rotation_matrix();
            obj.compute_trunk_angle()
        end
        
        function compute_rotation_matrix(obj)
            obj.pelvis_mat = nan(3,3,length(obj.working_index));
            obj.cuissegauche_mat = nan(3,3,length(obj.working_index));
            step = ceil(length(obj.working_index) / obj.working_index_max_length);
            for i=[1:step:length(obj.working_index), length(obj.working_index)]
                thetaX_pelvis = atan2(obj.working_pelvisAcc(i,1), obj.working_pelvisAcc(i,3));
                thetaY_pelvis = atan2(obj.working_pelvisAcc(i,2), obj.working_pelvisAcc(i,3));
                Rx_pelvis=[1 0 0;0 cos(thetaX_pelvis) -sin(thetaX_pelvis);0 sin(thetaX_pelvis) cos(thetaX_pelvis)];
                Ry_pelvis=[cos(thetaY_pelvis) 0 sin(thetaY_pelvis);0 1 0;-sin(thetaY_pelvis) 0 cos(thetaY_pelvis)];
                obj.pelvis_mat(:,:,i) = Ry_pelvis*Rx_pelvis;
                
                thetaX_cuisse = atan2(obj.working_cuissegaucheAcc(i,1),obj.working_cuissegaucheAcc(i,3));
                thetaY_cuisse = atan2(obj.working_cuissegaucheAcc(i,2),obj.working_cuissegaucheAcc(i,3));
                Rx_cuisse=[1 0 0;0 cos(thetaX_cuisse) -sin(thetaX_cuisse);0 sin(thetaX_cuisse) cos(thetaX_cuisse)];
                Ry_cuisse=[cos(thetaY_cuisse) 0 sin(thetaY_cuisse);0 1 0;-sin(thetaY_cuisse) 0 cos(thetaY_cuisse)];
                obj.cuissegauche_mat(:,:,i) = Ry_cuisse*Rx_cuisse;
            end
            
            for ii=1:3
                for jj=1:3
                    obj.pelvis_mat(ii,jj,:) = fill_nan(obj.pelvis_mat(ii,jj,:));
                    obj.cuissegauche_mat(ii,jj,:) = fill_nan(obj.cuissegauche_mat(ii,jj,:));
                end
            end
        end
        
        function compute_trunk_angle(obj)
            obj.trunk_angle = zeros(1, length(obj.pelvis_mat(1,1,:)));
            
            for i=1:length(obj.trunk_angle)
                BodyCenter_Rot = obj.pelvis_mat(:,:,i);
                obj.trunk_angle(i) = acosd(dot(BodyCenter_Rot * [0;0;1],[0;0;1]));
            end
        end
        
        function detect_misscalibration(obj)
            tmp_working_pelvisAcc = rectify_acc(...
                obj.working_pelvisAcc,...
                obj.sampling_rate, ...
                obj.rectify_low_pass_cutoff, ...
                obj.rectify_window_length, ...
                obj.rectify_skip );
            
            tmp_cuissegaucheAcc = rectify_acc(...
                obj.working_cuissegaucheAcc, ...
                obj.sampling_rate, ...
                obj.rectify_low_pass_cutoff, ...
                obj.rectify_window_length, ...
                obj.rectify_skip );
            
            tmp_working_pelvisAcc = obj.filter_mat(tmp_working_pelvisAcc(:,3),...
                obj.sampling_rate, ...
                obj.detect_misscalibration_cutoff);
            tmp_cuissegaucheAcc = obj.filter_mat(tmp_cuissegaucheAcc(:,3),...
                obj.sampling_rate, ...
                obj.detect_misscalibration_cutoff);
            
            obj.misscalibration_mask = (tmp_working_pelvisAcc > -0.5 ...
                | tmp_cuissegaucheAcc > -0.5);
            
            if ~isempty(obj.calibration_times)
                for idx = 1:length(obj.calibration_times)
                    start = obj.calibration_times{idx}.start_index;
                    stop = obj.calibration_times{idx}.stop_index;
                    obj.misscalibration_mask(start:stop) = 0;
                end
            end
        end
        
        function detect_walking_and_running(obj)
            obj.walking_mask = SignalDetection.walk_detection(obj.working_cuissegaucheAcc, obj.sampling_rate, 0.05);
            obj.running_mask = SignalDetection.walk_detection(obj.working_cuissegaucheAcc, obj.sampling_rate, 0.25);
            obj.walking_mask = obj.walking_mask - obj.running_mask; % Walk only if not running
        end
        
        function value=walking_percent(obj)
            value = sum(obj.walking_mask) / length(obj.walking_mask);
        end
        
        function value=running_percent(obj)
            value = sum(obj.running_mask) / length(obj.walking_mask);
        end
        
        function value=walking_time(obj)
            value = sum(obj.walking_mask) / obj.sampling_rate;
        end
        
        function value = running_time(obj)
            value = sum(obj.running_mask) / obj.sampling_rate;
        end
        
        function rectify(obj)
            obj.load_and_filter_working_from_raw()
            obj.working_pelvisAcc = rectify_acc(...
                obj.working_pelvisAcc,...
                obj.sampling_rate, ...
                obj.rectify_low_pass_cutoff, ...
                obj.rectify_window_length, ...
                obj.rectify_skip );
            obj.working_cuissegaucheAcc = rectify_acc(...
                obj.working_cuissegaucheAcc, ...
                obj.sampling_rate, ...
                obj.rectify_low_pass_cutoff, ...
                obj.rectify_window_length, ...
                obj.rectify_skip );
            
            obj.apply_all_calibration_time()
            obj.compute_rotation_matrix()
            obj.compute_trunk_angle()
            
        end
        
        function set_calibrationzone_point(obj,index_calibration_start, index_calibration_stop, index_start, index_stop)
            lowpelvisAcc       = obj.filter_mat(obj.raw_pelvisAcc(obj.working_index, :),...
                                                         obj.sampling_rate, ...
                                                         obj.rectify_low_pass_cutoff);
            lowcuissegaucheAcc = obj.filter_mat(obj.raw_cuissegaucheAcc(obj.working_index, :),...
                                                         obj.sampling_rate,...
                                                         obj.rectify_low_pass_cutoff);
            
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
            obj.compute_rotation_matrix()
            obj.compute_trunk_angle()
        end
        
        function apply_calibration_time(obj, calibration_time)
            pelvisAcc = obj.filter_mat(obj.raw_pelvisAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            cuissegaucheAcc = obj.filter_mat(obj.raw_cuissegaucheAcc, obj.sampling_rate, obj.filter_low_pass_cutoff);
            
            for i=calibration_time.start_index:calibration_time.stop_index
                obj.working_pelvisAcc(i, :) = (calibration_time.Qpelvis *  pelvisAcc(i, :)')';
                obj.working_cuissegaucheAcc(i, :) = (calibration_time.Qcuissegauche *  cuissegaucheAcc(i, :)')';
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
            obj.load_and_filter_working_from_raw();
        end
        
        function timestamp = timestamp(obj)
            timestamp = obj.raw_timestamp(obj.working_index);
        end
    end
    
    
    methods(Static)
        function Q = get_rectifying_Q(gvector, mat)
            g = [0 0 -1]';
            Q1 = get_Q_aligning_2_vector(gvector, g);
            
            gravity_compensated_mat = Q1*mat;
            gravity_compensated_mat = gravity_compensated_mat(:,1:ceil(length(gravity_compensated_mat)/10000):end); % On garde au maximum 10000 points
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

