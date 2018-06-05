function rectified_mat = rectify_acc( mat, fs, window, skip )
% mat : matrix (3, :) with accelerometer data 
% fs  : sampling rate of the accelerometer data
% window : averaging windows length for gravity compensation and SVD
% skip : Value to skip and interpolate after for faster processing

s = size(mat);
if s(1) > s(2)
    mat = mat';
end

len = length(mat(1,:));

cof = 1/10; % Hz
nyquist = fs/2;
wn = cof/nyquist;

[b, a] = butter(2, wn, 'low');

filtered_mat = [
    filtfilt(b, a, mat(1,:));
    filtfilt(b, a, mat(2,:));
    filtfilt(b, a, mat(3,:))];

ssc = @(v) [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
RU = @(A,B) eye(3) + ssc(cross(A,B)) + ssc(cross(A,B))^2*(1-dot(A,B))/(norm(cross(A,B))^2);

WINDOW = window*fs;
gravity_compensated_mat = zeros(size(filtered_mat));

first = true;
for i=1:len
    if ~mod(i, skip) || first
        idx_min = max(1, ceil(i-WINDOW/2));
        idx_max = min(len, floor(i+WINDOW/2));

        gvector = mean(filtered_mat(:, idx_min:idx_max), 2);
        g = [0, 0, -1]';
        G = RU(gvector, g);
        
        first = false;
    end
    gravity_compensated_mat(:, i) = G * mat(:, i);
end


rectified_mat = zeros(size(filtered_mat));

first = true;
for i=1:len
    if ~mod(i, skip) || first
        idx_min = max(1, ceil(i-WINDOW/2));
        idx_max = min(len, floor(i+WINDOW/2));

        [U,~,~] = svd(gravity_compensated_mat(1:2, idx_min:idx_max));
    
        first = false;
    end
    rectified_mat(:, i) = [U*gravity_compensated_mat(1:2, i);
        gravity_compensated_mat(3, i)];
end

if s(1) > s(2)
    rectified_mat = rectified_mat';
end

end

function mat = fill_nan(mat)
for i=1:length(mat(:,1))
    x = mat(i, :);
    nanx = isnan(x);
    t    = 1:numel(x);
    x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));
    mat(i,:) = x;
end


end