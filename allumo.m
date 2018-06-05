function allumo
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.
addpath('layout')
addpath('ploting')
%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[360,500,1200,800]);

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
    'Callback',@slidercontrol_Callback);
hatrajectory = axes('Parent', vboxpanesetting, 'Units','Pixels');
hboxhourbutton = uix.HBox( 'Parent', vboxpanesetting, 'Spacing', 5 );
labelhour = uicontrol('Parent', hboxhourbutton, ...
    'Style','text','String','', 'Fontsize', 16);
btnprevhour = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Previous hour',...
    'Callback',@btnprevhour_Callback);
btnnexthour = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Next hour',...
    'Callback',@btnnexthour_Callback);
btnrectify = uicontrol('Parent', hboxhourbutton, ...
    'Style','pushbutton','String','Rectify',...
    'Callback',@btnrectify_Callback);


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
    'Style','pushbutton','String','Open Cuisse',...
    'Callback',@btnopencuisse_Callback);

panepelvis = uix.Panel('Parent', buttonvbox);
hboxpelvis = uix.HBox('Parent', panepelvis, 'Spacing', 3);
editpelvis = uicontrol('Parent', hboxpelvis, ...
    'Style','edit','String','',...
    'Callback',@editpelvis_Callback);
btnopenpelvis = uicontrol('Parent', hboxpelvis, ...
    'Style','pushbutton','String','Open Pelvis',...
    'Callback',@btnopenpelvis_Callback);


btnclear = uicontrol('Parent', buttonvbox, ...
    'Style','pushbutton','String','Clear',...
    'Callback',@btnclear_Callback);

btnload = uicontrol('Parent', hbox, ...
    'Style','pushbutton','String','Load',...
    'Callback',@btnload_Callback);

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

ha = axes('Parent', vboxmain);
set(ha, 'DataAspectRatioMode', 'manual')

% Create the data to plot.
peaks_data = peaks(35);
membrane_data = membrane;
[x,y] = meshgrid(-8:.5:8);
r = sqrt(x.^2+y.^2) + eps;
sinc_data = sin(r)./r;

%Create a plot in the axes.
current_data = peaks_data;
surf(current_data);

% -- Main Layout End -------
set_layout()

% Assign the GUI a name to appear in the window title.
f.Name = 'Allumo';
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
f.Visible = 'on';

%% Create data

% Create the gui dataclass
data = AllumoData();

% Create the listeners
addlistener(data,'pelvis_path','PostSet', @update_ui_Callback);
addlistener(data,'cuisse_path','PostSet', @update_ui_Callback);
addlistener(data,'hour','PostSet', @update_ui_Callback);

try_get_files();

%% Callbacks
%  Callbacks for simple_gui. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.

    function set_layout()
        set(vboxpanesetting, 'Height', [30 30 -1])
        set(hboxhourbutton, 'Widths', [100 100 100 100])
        set( hboxcuisse, 'Widths', [-4 -1] );
        set( hboxpelvis, 'Widths', [-4 -1] );
        set( hbox, 'Widths', [-3 -1] );
        set( buttonvbox, 'Height', [30, 30, 30]);
        set( vboxmain, 'Height', [200 600] );
        
        
    end

    function update_ui_Callback(~, ~)
        set(editpelvis, 'String', data.pelvis_path)
        set(editcuisse, 'String', data.cuisse_path)
        
        set(hatrajectory, 'ButtonDownFcn', @hatrajectory_Callback)
        if exist('data', 'var') && length(data.pelvisplot)>1
            for i=1:3
                set(data.pelvisplot{i}, 'ButtonDownFcn', @hatrajectory_Callback)
                set(data.cuisseplot{i}, 'ButtonDownFcn', @hatrajectory_Callback)
            end
            set(labelhour, 'String', datestr(seconds(data.hour*3600),'HH:MM:SS PM'))
        end        
        set_layout()
        set(ha, 'DataAspectRatioMode', 'manual')

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

    function btnload_Callback(source,eventdata)
        if ~isempty(data.pelvis_path) && ~isempty(data.cuisse_path)
            axes(ha)
            data.humanModel = HumanModel(data.pelvis_path, data.cuisse_path, 30);
            init_plot(data)
            set(slidercontrol, 'Value', 1,...
                'min', 1, 'max', length(data.humanModel.timestamp) , ...
                'SliderStep', [1, 1] / length(data.humanModel.timestamp))
            
            axes(hatrajectory)
            init_graph_plot(data)
            
            update_ui_Callback(0,0)
        end
    end

    function btnprevhour_Callback(source, eventdata)
        data.hour = min(data.hour-1, 1);
        data.humanModel.load_data('hour', data.hour)
        update_plot(data, 1)
        update_graph_plot(data, 1);
    end
        
    function btnnexthour_Callback(source, eventdata)
        data.hour = data.hour+1;
        data.humanModel.load_data('hour', data.hour)
        update_plot(data, 1)
        update_graph_plot(data, 1);
    end

    function btnrectify_Callback(source, eventdata)
        data.humanModel.pelvisAcc = rectify_acc(data.humanModel.raw_pelvisAcc, data.humanModel.sampling_rate, 20, 100 );
        data.humanModel.cuissegaucheAcc = rectify_acc(data.humanModel.raw_cuissegaucheAcc, data.humanModel.sampling_rate, 20, 100 );
        data.humanModel.calculate_rotation_matrix()
        update_plot(data, 1)
        update_graph_plot(data, 1);
    end

    function slidercontrol_Callback(source, eventdata)
        value = round(source.Value);
        set(source, 'Value', value);
        update_plot(data, value)
        update_graph_plot(data, value);
    end
    
    function btndebug_Callback(source, event)
        keyboard
    end

    function hatrajectory_Callback(source, event)
        index = find(data.humanModel.timestamp() > event.IntersectionPoint(1), 1, 'first');
        slidercontrol.Value = index;
        slidercontrol_Callback(slidercontrol, 0)
    end
    
    %% Misc function 
    function try_get_files()
        
        % load sentinelle
        cuisse_path = dir('data\*Jambe*');
        cuisse_path = cuisse_path(2);
        if ~isempty(cuisse_path)
            cuisse_path = strcat(pwd, '\data\', cuisse_path.name);
            data.cuisse_path = cuisse_path;
        end
        
        pelvis_path = dir('data\*Tronc*');
        pelvis_path = pelvis_path(2);
        if ~isempty(pelvis_path)
            pelvis_path = strcat(pwd, '\data\', pelvis_path.name);
            data.pelvis_path = pelvis_path;
        end
        
        % load test
        data.cuisse_path = strcat(pwd, '\jambe-test.csv');
        data.pelvis_path = strcat(pwd, '\pelvis-test.csv');
        btnload_Callback(0, 0)
    end
end