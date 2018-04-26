function allumo
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.
addpath('layout')
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
p.Selection = 2;

% ------ Control panel Begin -------
controlegrid = uix.Grid( 'Parent', panecontrol, 'Spacing', 5 );
slidercontrol = uicontrol('Parent', controlegrid, ...
    'Style','slider', 'min',0, 'max',100, 'Value', 50, 'Sliderstep', [1, 1] / 100, ...
    'Callback',@slidercontrol_Callback);
hatrajectory = axes('Parent', controlegrid,'Units','Pixels');
uix.Empty( 'Parent', controlegrid );
uix.Empty( 'Parent', controlegrid );

set(controlegrid, 'Height', [30 -1], 'Width', [-3 -1])

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
set( hboxcuisse, 'Widths', [-4 -1] );

panepelvis = uix.Panel('Parent', buttonvbox);
hboxpelvis = uix.HBox('Parent', panepelvis, 'Spacing', 3);
editpelvis = uicontrol('Parent', hboxpelvis, ...
    'Style','edit','String','',...
    'Callback',@editpelvis_Callback);
btnopenpelvis = uicontrol('Parent', hboxpelvis, ...
    'Style','pushbutton','String','Open Pelvis',...
    'Callback',@btnopenpelvis_Callback);
set( hboxpelvis, 'Widths', [-4 -1] );


btnclear = uicontrol('Parent', buttonvbox, ...
    'Style','pushbutton','String','Clear',...
    'Callback',@btnclear_Callback);

btnload = uicontrol('Parent', hbox, ...
    'Style','pushbutton','String','Load',...
    'Callback',@btnload_Callback);

set( hbox, 'Widths', [-3 -1] );
set( buttonvbox, 'Height', [30, 30, 30]);
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

ha = axes('Parent', vboxmain,'Units','Pixels','Position',[50,60,200,185]);
% Create the data to plot.
peaks_data = peaks(35);
membrane_data = membrane;
[x,y] = meshgrid(-8:.5:8);
r = sqrt(x.^2+y.^2) + eps;
sinc_data = sin(r)./r;

%Create a plot in the axes.
current_data = peaks_data;
surf(current_data);

set( vboxmain, 'Height', [-1 -5] );

% -- Main Layout End -------

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

try_get_files();

%% Callbacks
%  Callbacks for simple_gui. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.

    function update_ui_Callback(source, eventdata)
        set(editpelvis, 'String', data.pelvis_path)
        set(editcuisse, 'String', data.cuisse_path)
    end

    function editpelvis_Callback(source, eventdata)
        data.pelvis_path = source.String;
    end

    function editcuisse_Callback(source, eventdata)
        data.cuisse_path = source.String;
    end

    function btnopenpelvis_Callback(source,eventdata)
        [FileName,PathName,FilterIndex] = uigetfile('*.xlsx');
        if FilterIndex
            data.pelvis_path = strcat(PathName, FileName);
        end
    end

    function btnopencuisse_Callback(source,eventdata)
        [FileName,PathName,FilterIndex] = uigetfile('*.xlsx');
        if FilterIndex
            data.cuisse_path = strcat(PathName, FileName);
        end
    end

    function btnclear_Callback(source,eventdata)
        data.cuisse_path = '';
        data.pelvis_path = '';
    end

    function btnload_Callback(source,eventdata)
        %axes(ha)
        if ~isempty(data.pelvis_path) && ~isempty(data.cuisse_path)
            data.humanmodel = HumanModel(data.pelvis_path, data.cuisse_path);
            data.humanmodel.init_plot()
            set(slidercontrol, 'Value', 0,...
                'min', 0, 'max', length(data.humanmodel.timestamp), ...
                'SliderStep', [1, 1] / length(data.humanmodel.timestamp))
            
        end
    end

    function slidercontrol_Callback(source, eventdata)
        %axes(ha)
        value = round(source.Value);
        set(source, 'Value', value);
        data.humanmodel.update_plot(value)
    end
    
    function btndebug_Callback(source, event)
        keyboard
    end
    
    %% Misc function 
    function try_get_files()
        cuisse_path = dir('*Cuisse*');
        if ~isempty(cuisse_path)
            cuisse_path = strcat(pwd, '\', cuisse_path.name);
            data.cuisse_path = cuisse_path;
        end
        
        pelvis_path = dir('*Pelvis*');
        if ~isempty(pelvis_path)
            pelvis_path = strcat(pwd, '\', pelvis_path.name);
            data.pelvis_path = pelvis_path;
        end
    end
end