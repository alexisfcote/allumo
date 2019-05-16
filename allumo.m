function allumo
% Main allumoGUI
addpath('layout', 'ploting', 'actigraph', 'GUI utils', 'math utils', 'utils')
%  Create and then hide the GUI as it is being constructed.

gui_name = 'Allumo';
f = make_singleton(gui_name);
if isempty(f) % Allumo already open
    return
end

f.Visible = 'off';
f.Position = [360,500,1200,800];
f.MenuBar = 'None';


%% Construct the layout
% -- Main Layout Begin -------
vboxmain = uix.VBox('Parent', f, 'Spacing', 3, 'Padding', 5);

p = uix.TabPanel( 'Parent', vboxmain, 'Padding', 5 );
panecontrol = uix.Panel( 'Parent', p );
panesetting = uix.Panel( 'Parent', p );
paneother   = uix.Panel( 'Parent', p );
p.TabTitles = {'Control', 'Settings', 'Other'};
p.Selection = 1;

% ------ Control panel Begin -------
vboxpanesetting = uix.VBox( 'Parent', panecontrol, 'Spacing', 5 );
slidercontrol = uicontrol('Parent', vboxpanesetting, ...
    'Style','slider', 'min',0, 'max',100, 'Value', 1, 'Sliderstep', [1, 1] / 100, ...
    'Callback',@slidercontrol_Callback, 'Visible', 'off');
hatrajectory = axes('Parent', vboxpanesetting, 'Units','Pixels');
hboxhourbutton = uix.HBox( 'Parent', vboxpanesetting, 'Spacing', 5 );
labelhour = uicontrol('Parent', hboxhourbutton, ...
    'Style','text','String','', 'Fontsize', 12);
btnautocalibration = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Auto-Calibration',...
    'Callback',@btnautocalibration_Callback);
btnselectcalibrationzone = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Select Calibrated Zone',...
    'Callback',@btnselectcalibrationzone1_Callback);
btnclearcalibrationzone = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Clear Calibrated Zones',...
    'Callback',@btnclearcalibrationzone1_Callback);
btndetectmisscalibration = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Detect MissCalibration',...
    'Callback',@btndetectmisscalibration_Callback);
btndetect_walking_and_running = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Detect walk and run',...
    'Callback',@btndetect_walking_and_running_Callback);
btnexport_report = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Export results',...
    'Callback',@btnexport_report_Callback);


btnplay = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Play',...
    'Callback',@btnplay_Callback);

% ------ Control panel End -------

% ------ Setting panel Begin -------
hbox = uix.HBox('Parent', panesetting, 'Spacing', 3);
buttonvbox = uix.VBox('Parent', hbox, 'Spacing', 3);

panecuisse = uix.Panel('Parent', buttonvbox);
hboxcuisse = uix.HBox('Parent', panecuisse, 'Spacing', 3);
editcuisse = uicontrol('Parent', hboxcuisse, ...
    'Style','edit','String','',...
    'Callback',@editcuisse_Callback);
btnopencuisse = uicontrol('Parent', hboxcuisse, ...
    'Style','pushbutton','String','Open Thigh',...
    'Callback',@btnopencuisse_Callback);

panepelvis = uix.Panel('Parent', buttonvbox);
hboxpelvis = uix.HBox('Parent', panepelvis, 'Spacing', 3);
editpelvis = uicontrol('Parent', hboxpelvis, ...
    'Style','edit','String','',...
    'Callback',@editpelvis_Callback);
btnopenpelvis = uicontrol('Parent', hboxpelvis, ...
    'Style','pushbutton','String','Open Pelvis',...
    'Callback',@btnopenpelvis_Callback);

popup_filetype = uicontrol('Parent', buttonvbox, ...
    'Style','popupmenu','String',{'Auto', 'ActiGraph', 'ActiGraph-notimestamp', 'xlsx'});

btnclear = uicontrol('Parent', buttonvbox, ...
    'Style','pushbutton','String','Clear',...
    'Callback',@btnclear_Callback);


btnload = uicontrol('Parent', buttonvbox, ...
    'Style','pushbutton','String','Load',...
    'Callback',@btnload_Callback);

vboxvideo = uix.VBox('Parent', hbox);

btnloadvideo = uicontrol('Parent', vboxvideo, ...
    'Style','pushbutton','String','Load Video',...
    'Callback',@btnloadvideo_Callback);

uicontrol('Parent', vboxvideo, 'Style', 'text', 'String', 'Video Time Offset (s)')

editvideooffset = uicontrol('Parent', vboxvideo, ...
    'Style','edit','String','0',...
    'Callback',@editvideooffset_Callback);

btnselectregionofinterest = uicontrol('Parent', vboxvideo, ...
    'Style','pushbutton','String','Select Region of Interest',...
    'Callback',@btnselectregionofinterest_Callback);


% ------ Setting panel End -------

% ------ Other panel Start -------
othergrid = uix.Grid( 'Parent', paneother, 'Spacing', 5 );
btndebug = uicontrol('Parent', othergrid, ...
    'Style','pushbutton','String','Debug',...
    'Callback',@btndebug_Callback);
uix.Empty( 'Parent', othergrid );
uix.Empty( 'Parent', othergrid );
uix.Empty( 'Parent', othergrid );


% ------ Other panel End -------
hboxmain = uix.HBox('Parent', vboxmain, 'Spacing', 0, 'Padding', 0);
ha = axes('Parent', hboxmain);
set(ha, 'DataAspectRatioMode', 'manual')
havideo = axes('Parent', hboxmain);

% -- Main Layout End -------

% Assign the GUI a name to appear in the window title.
f.Name = 'Allumo';
% Move the GUI to the center of the screen.
movegui(f,'center')

% Keyboard callback
set(f, 'KeyPressFcn', @KeyPressFcn_Callback)

% Make the GUI visible.
f.Visible = 'on';

%% Create data

% Create the gui dataclass
data = AllumoData();
data.mainAxes = ha;
data.videoAxes = havideo;

% Create the listeners
addlistener(data,'pelvis_path','PostSet', @update_ui_Callback);
addlistener(data,'cuisse_path','PostSet', @update_ui_Callback);

% Selection Modes
selection_mode = 'normal';
selected_calibration_start_index  = 0;
selected_calibration_stop_index  = 0;
selected_start_index = 0;
selected_stop_index  = 0;
selected_plots = {};

set_layout()
try_get_files();

%% Callbacks
%  Callbacks for simple_gui. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.

    function set_layout()
        set( vboxpanesetting, 'Height', [0 30 -1])
        set( hboxhourbutton, 'Widths', [200 100 130 130 130 130 130 80])
        set( hboxcuisse, 'Widths', [-4 -1] );
        set( hboxpelvis, 'Widths', [-4 -1] );
        set( hbox, 'Widths', [-3 -1] );
        set( buttonvbox, 'Height', [30, 30, 30, 30, 30]);
        set( vboxvideo, 'Height', [30, 20, 30, 30]);
        set( vboxmain, 'Height', [200 -1] );
        if isempty(data.videoReader)
            set( hboxmain, 'Widths', [0, -1] )
        else
            set( hboxmain, 'Widths', [-1 -1] )
        end
        
    end

    function update_ui_Callback(~, ~)
        set(f, 'Pointer', 'watch')
        drawnow
        
        set(editpelvis, 'String', data.pelvis_path)
        set(editcuisse, 'String', data.cuisse_path)
        
        set(hatrajectory, 'ButtonDownFcn', @hatrajectory_Callback)
        if exist('data', 'var') && length(data.pelvisplot)>1
            for i=1:3
                set(data.pelvisplot{i}, 'ButtonDownFcn', @hatrajectory_Callback)
                set(data.cuisseplot{i}, 'ButtonDownFcn', @hatrajectory_Callback)
            end
            set_labelhour()
        end
        set_layout()
        set(ha, 'DataAspectRatioMode', 'manual')
        set(f, 'Pointer', 'arrow')
    end

    function editpelvis_Callback(source, eventdata)
        data.pelvis_path = source.String;
    end

    function editcuisse_Callback(source, eventdata)
        data.cuisse_path = source.String;
    end

    function btnopenpelvis_Callback(source,eventdata)
        [FileName,PathName,FilterIndex] = uigetfile({'*'; '*.xlsx'; '*.csv'});
        if FilterIndex
            data.pelvis_path = strcat(PathName, FileName);
        end
    end

    function btnopencuisse_Callback(source,eventdata)
        [FileName,PathName,FilterIndex] = uigetfile({'*'; '*.xlsx'; '*.csv'});
        if FilterIndex
            data.cuisse_path = strcat(PathName, FileName);
        end
    end

    function btnclear_Callback(source,eventdata)
        data.cuisse_path = '';
        data.pelvis_path = '';
    end

    function btnload_Callback(source,eventdata) %#ok<*INUSD>
        set(f, 'Pointer', 'watch')
        drawnow
        if ~isempty(data.pelvis_path) && ~isempty(data.cuisse_path)
            data.humanModel = HumanModel(data.pelvis_path, ...
                                         data.cuisse_path,...
                                         'filetype', popup_filetype.String{popup_filetype.Value});
            if length(data.humanModel.working_index) == data.humanModel.working_index_max_length
                rois = region_of_interest_selector(data);
                uiwait(rois);
            end
            axes(ha)
            init_plot(data)
            set(slidercontrol, 'Value', 1,...
                'min', 1, 'max', length(data.humanModel.working_index) , ...
                'SliderStep', [1, 1] / length(data.humanModel.working_index))
            
            axes(hatrajectory)
            init_graph_plot(data)
            
            update_ui_Callback(0,0)
        end
        set(f, 'Pointer', 'arrow')
    end

    function btnautocalibration_Callback(source, eventdata)
        set(f, 'Pointer', 'watch')
        drawnow
        data.humanModel.rectify()
        set(f, 'Pointer', 'arrow')
        update_plot(data, 1)
        update_graph_plot(data, 1);
    end

    function btnselectcalibrationzone1_Callback(source, eventdata)
        selection_mode = 'selectcalibrationzone1';
        set(f, 'Pointer', 'crosshair')
    end

    function slidercontrol_Callback(source, eventdata)
        value = round(source.Value);
        set(source, 'Value', value);
        update_plot(data, value)
        update_graph_plot(data, value);
        if ~isempty(data.videoReader)
            update_video(value/data.humanModel.sampling_rate + str2double(get(editvideooffset, 'String')))
        end
        set_labelhour()  
    end

    function btndebug_Callback(source, event)
        keyboard
    end

    function hatrajectory_Callback(source, event) %#ok<*INUSL>
        if strcmp(selection_mode, 'normal')
            index = find(data.humanModel.timestamp > event.IntersectionPoint(1), 1, 'first');
            slidercontrol.Value = index;
            slidercontrol_Callback(slidercontrol, 0)
            
        elseif strcmp(selection_mode, 'selectcalibrationzone1')
            timestamp = data.humanModel.timestamp();
            selected_calibration_start_index = find( timestamp > event.IntersectionPoint(1), 1, 'first');
            slidercontrol.Value = selected_calibration_start_index;
            slidercontrol_Callback(slidercontrol, 0)
            selection_mode = 'selectcalibrationzone2';
            
            axes(hatrajectory)
            selected_calibration_time1 = timestamp(selected_calibration_start_index);
            h = plot([selected_calibration_time1, selected_calibration_time1], get(hatrajectory, 'Ylim'), 'r');
            selected_plots{end+1} = h;
            
        elseif strcmp(selection_mode, 'selectcalibrationzone2')
            timestamp = data.humanModel.timestamp();
            selected_calibration_stop_index = find(timestamp > event.IntersectionPoint(1), 1, 'first');
            slidercontrol.Value = selected_calibration_stop_index;
            slidercontrol_Callback(slidercontrol, 0)
            set(f, 'Pointer', 'ibeam')
            selection_mode = 'first_selection';
            
            axes(hatrajectory)
            selected_calibration_time2 = timestamp(selected_calibration_start_index);
            h = plot([selected_calibration_time2, selected_calibration_time2], get(hatrajectory, 'Ylim'), 'r');
            selected_plots{end+1} = h;
            
        elseif strcmp(selection_mode, 'first_selection')
            timestamp = data.humanModel.timestamp();
            selected_start_index = find(timestamp > event.IntersectionPoint(1), 1, 'first');
            selection_mode = 'second_selection';
            
            axes(hatrajectory)
            selected_start_time = timestamp(selected_start_index);
            h = plot([selected_start_time, selected_start_time], get(hatrajectory, 'Ylim'), 'g');
            selected_plots{end+1} = h;
            
        elseif strcmp(selection_mode, 'second_selection')
            timestamp = data.humanModel.timestamp();
            selected_stop_index = find(timestamp > event.IntersectionPoint(1), 1, 'first');
            
            set(f, 'Pointer', 'arrow')
            selection_mode = 'normal';
            
            selected_stop_time = timestamp(selected_stop_index);
            
            % plot the selection
            axes(hatrajectory)
            h = plot([selected_stop_time, selected_stop_time], get(hatrajectory, 'Ylim'), 'g');
            selected_plots{end+1} = h;
            
            selected_start_time = timestamp(selected_start_index);
            
            ylim = get(hatrajectory, 'Ylim');
            h = fill([selected_start_time selected_start_time selected_stop_time selected_stop_time],[ ylim(1) ylim(2) ylim(2) ylim(1)], 'g');
            set(h,'facealpha',.3)
            set(h, 'edgealpha', 0)
            set(h, 'ButtonDownFcn', @hatrajectory_Callback)
            selected_plots{end+1} = h;
            
            if selected_stop_index < selected_start_index
                tmp = selected_stop_index;
                selected_stop_index = selected_start_index;
                selected_start_index = tmp;
            end
            
            if selected_calibration_stop_index < selected_calibration_start_index
                tmp = selected_calibration_stop_index;
                selected_calibration_stop_index = selected_calibration_start_index;
                selected_calibration_start_index = tmp;
            end
            
            % save to model and process
            data.humanModel.set_calibrationzone_point(selected_calibration_start_index, selected_calibration_stop_index, selected_start_index, selected_stop_index)
            
            % update plots
            slidercontrol_Callback(slidercontrol, 0)
        end
        
    end

    function btnclearcalibrationzone1_Callback(source, event)
        set(f, 'Pointer', 'watch')
        drawnow
        for i=1:length(selected_plots)
            delete(selected_plots{i});
            data.humanModel.clear_all_calibration_time();
        end
        slidercontrol_Callback(slidercontrol, 0)
        set(f, 'Pointer', 'arrow')
    end

    function btndetectmisscalibration_Callback(source, event)
        set(f, 'Pointer', 'watch')
        drawnow
        data.humanModel.detect_misscalibration()
        set(f, 'Pointer', 'arrow')
        slidercontrol_Callback(slidercontrol, 0)
    end

    function btndetect_walking_and_running_Callback(source, event)
        set(f, 'Pointer', 'watch')
        drawnow
        data.humanModel.detect_walking_and_running()
        set(f, 'Pointer', 'arrow')
        slidercontrol_Callback(slidercontrol, 0)
    end

    function btnexport_report_Callback(source, event)
        
        [FileName,PathName,FilterIndex] = uiputfile('*.xlsx',...
            'Save report', ...
            getappdata(0, 'filepath_to_last_report'));
        if ~FilterIndex
            return
        end
        set(f, 'Pointer', 'watch')
        FilePath = fullfile(PathName, FileName);
        setappdata(0, 'filepath_to_last_report', FilePath)
        
        % main sheet
        main_sheet = {'Start Time','Sampling Rate (Hz)';
            datestr(data.humanModel.start_time), data.humanModel.sampling_rate;};
        xlRange = 'A1';
        xlswrite(FilePath, main_sheet, 1, xlRange)
        
        % Walkging and running
        if any(data.humanModel.walking_mask)
            walking_percent = data.humanModel.walking_percent;
            running_percent = data.humanModel.running_percent;
            walking_time = data.humanModel.walking_time;
            running_time = data.humanModel.running_time;
            
            walking_sheet = {'Walking percent', 'Running percent', ...
                'Walking time(s)', 'Running time(s)', ...
                'Total time(s)';
                walking_percent, running_percent, ...
                walking_time, running_time, ...
                length(data.humanModel.walking_mask)/data.humanModel.sampling_rate};
            
            xlswrite(FilePath, walking_sheet, 1, 'A3')
        end
        
        % Trunk angle
        [pxx, fs] = periodogram(data.humanModel.trunk_angle,...
            [], [], data.humanModel.sampling_rate, 'power');
        
        trunk_sheet = {'min angle', 'max angle', 'mean angle', 'std', ...
            'fs', 'spectralpower density';
            min(data.humanModel.trunk_angle), ...
            max(data.humanModel.trunk_angle), ...
            mean(data.humanModel.trunk_angle), ...
            std(data.humanModel.trunk_angle), ...
            fs(1), pxx(1)};
        
        xlswrite(FilePath, trunk_sheet, 1, 'A5')
        
        
        
        % calibration sheet
        if ~isempty(data.humanModel.calibration_times)
            calibration_sheet = {};
            
            for idx = 1:length(data.humanModel.calibration_times)
                props = properties(data.humanModel.calibration_times{idx});
                for iprop = 1:length(props)
                    thisprop = props{iprop};
                    calibration_sheet{1, iprop} = thisprop;
                    thisprop_value = data.humanModel.calibration_times{idx}.(thisprop);
                    calibration_sheet{idx+1, iprop} = mat2str(thisprop_value);
                end
            end
            xlswrite(FilePath,calibration_sheet, 'calibration_sheet')
        end
        
        set(f, 'Pointer', 'arrow')
    end

    function btnselectregionofinterest_Callback(source, event)
        rois = region_of_interest_selector(data);
        uiwait(rois);
        axes(ha)
        init_plot(data)
        set(slidercontrol, 'Value', 1,...
            'min', 1, 'max', length(data.humanModel.working_index) , ...
            'SliderStep', [1, 1] / length(data.humanModel.working_index))
        
        axes(hatrajectory)
        init_graph_plot(data)
        
        update_ui_Callback(0,0)
    end

    function btnloadvideo_Callback(source, event)
        [FileName,PathName,FilterIndex] = uigetfile('*.*' ,'Charger un fichier video');
        if ~FilterIndex
            return
        end
        data.videoReader = VideoReader([PathName, FileName]);
        image(readFrame(data.videoReader), 'Parent', havideo);
        axes(havideo)
        axis equal
        set(havideo, 'Visible', 'Off')
        
        update_ui_Callback(0, 0)
        update_video(max(0 + str2double(get(editvideooffset, 'String')), 0))
        
    end

    function editvideooffset_Callback(source, event)
        slidercontrol_Callback(slidercontrol, 0)
    end

    function btnplay_Callback(source, event)
        if ~data.playing
            data.playing = true;
            framerate = 3; % Base framerate. It will be adapted to play at ~1x speed
            while data.playing
                slidercontrol.Value = slidercontrol.Value+framerate;
                if slidercontrol.Value > slidercontrol.Max;
                    slidercontrol.Value = slidercontrol.Max;
                    data.playing = false;
                    break
                end
                tic
                slidercontrol_Callback(slidercontrol, 0)
                time_elapsed = toc;
                if time_elapsed/framerate > 1/data.humanModel.sampling_rate % Adaptive framerate
                    framerate = framerate + 1;
                else
                    framerate = framerate - 1;
                end
                framerate = max(1, framerate);
            end
        else
            data.playing = false;
        end
    end

    function KeyPressFcn_Callback(source, event)
        if strcmp(event.Key, 'space')
            btnplay_Callback(source, event)
        end
    end

    function update_video(time)
        time = max(time,0);
        time = min(time, data.videoReader.Duration-0.1);
        set(data.videoReader, 'CurrentTime', time)
        havideo.Children.CData = readFrame(data.videoReader);
        drawnow()
    end

%% Misc function
    function set_labelhour()
        datetime_t = data.humanModel.start_time + seconds(round(slidercontrol.Value + data.humanModel.working_index(1))/data.humanModel.sampling_rate);
        set(labelhour, 'String', datestr(datetime_t))
    end

    function try_get_files()
        
        % load sentinelle
        %         cuisse_path = dir('data\*Jambe*');
        %         cuisse_path = cuisse_path(2);
        %         if ~isempty(cuisse_path)
        %             cuisse_path = strcat(pwd, '\data\', cuisse_path.name);
        %             data.cuisse_path = cuisse_path;
        %         end
        %
        %         pelvis_path = dir('data\*Tronc*');
        %         pelvis_path = pelvis_path(2);
        %         if ~isempty(pelvis_path)
        %             pelvis_path = strcat(pwd, '\data\', pelvis_path.name);
        %             data.pelvis_path = pelvis_path;
        %         end
        
        %         load test
        %         data.cuisse_path = strcat(pwd, '\jambe-test.csv');
        %         data.pelvis_path = strcat(pwd, '\pelvis-test.csv');
        
        %         load test
        %         data.cuisse_path = strcat(pwd, '\data', '\LBP49jambe (2018-03-20)RAW.csv');
        %         data.pelvis_path = strcat(pwd, '\data', '\LBP49tronc (2018-03-20)RAW.csv');
        
        %         load test
                data.cuisse_path = strcat(pwd, '\data', '\CLE2B23130402 (2018-06-20)RAW jambe.csv');
                data.pelvis_path = strcat(pwd, '\data', '\CLE2B23130391 (2018-06-20)RAW tronc.csv');
        
%         data.cuisse_path = strcat(pwd, '\data', '\Sujet8Jambe (2016-03-08)RAW.csv');
%         data.pelvis_path = strcat(pwd, '\data', '\Sujet8Tronc (2016-03-08)RAW.csv');
        
        btnload_Callback(0, 0)
    end
end