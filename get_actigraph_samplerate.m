function [ samplerate ] = get_actigraph_samplerate( filename )

fid=fopen(filename);
line = fgetl(fid);

fclose(fid);

hz_string = regexp(line, '[0-9]+ Hz', 'match');
scan_result = textscan(hz_string{1}, '%d');
samplerate = scan_result{1};
end