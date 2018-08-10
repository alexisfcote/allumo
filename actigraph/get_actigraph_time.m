function [ date_time ] = get_actigraph_time( filename )

fid=fopen(filename);
for i=1:3
    line = fgetl(fid);
end
timeofday = line(12:end);

line = fgetl(fid);
date = line(12:end);

fclose(fid);

date_time = datetime([date, ' ', timeofday]);

end

