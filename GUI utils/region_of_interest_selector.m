function f = region_of_interest_selector(allumo_data)
%  Create and then hide the GUI as it is being constructed.
gui_name = 'region_of_interest_selector';
f = make_singleton(gui_name);
if isempty(f) % already open
    return
end
f.Visible = 'off';
f.Position = [360,500,1200,400];
f.MenuBar = 'None';

%% Construct the layout
% -- Main Layout Begin -------
vboxmain = uix.VBox('Parent', f, 'Spacing', 3, 'Padding', 5);

hboxmain = uix.HBox('Parent', vboxmain, 'Spacing', 0, 'Padding', 0);
btnok = uicontrol('Parent', hboxmain, ...
    'Style','pushbutton','String','ok',...
    'Callback',@btnok_Callback);
uix.Empty( 'Parent', hboxmain )
hatrajectory = axes('Parent', vboxmain);



% -- Main Layout End -------

% Assign the GUI a name to appear in the window title.
f.Name = 'Select region of interest';
% Move the GUI to the center of the screen.
movegui(f,'center')

% Keyboard callback
set(f, 'KeyPressFcn', @KeyPressFcn_Callback)

% Make the GUI visible.
f.Visible = 'on';

%% Create data

% Create the gui dataclass
data = allumo_data;

% Create the listeners

% Create plot
data.humanModel.working_index = 1:length(data.humanModel.raw_pelvisAcc);
data.humanModel.working_pelvisAcc = data.humanModel.raw_pelvisAcc;
data.humanModel.working_cuissegaucheAcc = data.humanModel.raw_cuissegaucheAcc;
init_graph_plot(data);

% Selection Modes
selection_mode = 'first_selection';
selected_start_index = 0;
selected_stop_index  = 0;
selected_plots = {};

update_ui_Callback(0, 0)


%% Callbacks
%  Callbacks for simple_gui. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.

    function set_layout()
        set( vboxmain, 'Height', [20 -1]);
        set( hboxmain, 'Width', [80 -1] );
    end

    function update_ui_Callback(~, ~)
        set(hatrajectory, 'ButtonDownFcn', @hatrajectory_Callback)
        if exist('data', 'var') && length(data.pelvisplot)>1
            for i=1:3
                set(data.pelvisplot{i}, 'ButtonDownFcn', @hatrajectory_Callback)
                set(data.cuisseplot{i}, 'ButtonDownFcn', @hatrajectory_Callback)
            end
        end
        set_layout()
        
    end


    function btnok_Callback(source, event)
        if selected_stop_index == 0
            errordlg('Choose a region of interest first')
            return
        end
        if (selected_stop_index - selected_start_index) > data.humanModel.working_index_max_length
            warndlg('Region of interest too long. Computation time would be too long. Data will be interpolated.', ...
                    'Data to big', ...
                    'modal')
        end
        data.humanModel.set_working_index(selected_start_index:selected_stop_index)
        delete(f);
    end

    function hatrajectory_Callback(source, event) %#ok<*INUSL>
        if strcmp(selection_mode, 'first_selection')
            clear_selection()
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
            selection_mode = 'first_selection';
            
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
            
        end
    end
%% Misc function
    function clear_selection()
        for i=1:length(selected_plots)
            delete(selected_plots{i});
        end
    end
end