function [ new_handle ] = make_singleton( gui_name )
h = findall(0, 'tag', gui_name);
new_handle = [];
if (isempty(h))
      %Launch the figure
      new_handle = figure('tag', gui_name);
else
      %Figure exists so bring Figure to the focus
      figure(h);
end;
end

