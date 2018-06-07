%% simulate

fs = 30; % hz

t = 1:1/fs:100;

angle = (sin(2*pi/5*t))/2 * pi/4;
x = sin(angle);
y = sin(8*pi*t)*0.05;
z = -cos(angle);

x(1:5*fs) = 0;
y(1:5*fs) = 0;
z(1:5*fs) = -1;

x(end-5*fs:end) = 0;
y(end-5*fs:end) = 0;
z(end-5*fs:end) = -1;

init_mat = [x; y; z];

theta = pi/4;
psi   = pi/8;
phi   = pi/3;

Q = eulerXZX(theta, psi, phi);

mat = Q * [x; y; z];
%mat = mat + 0.1*randn(size(mat));


% half way a shift of the sensor occured
mat(:, ceil(length(mat(1,:))/2:end)) = eulerXZX(pi/6, pi/6, pi/4) * mat(:, ceil(length(mat(1,:))/2:end));


%% Post treatment

rectified_mat = rectify_acc(mat, fs, 10, 20, 100);

%% plot
figure
N = 3;

subplot(N,1,1)
plot(t, init_mat')
title('Actual acceleration')


subplot(N,1,2)
hold off
plot(t, (mat)')
hold on
plot([t(end)/2 t(end)/2]+0.5, [-1 1], 'k')
title('Sensor reading with the sensor moving at t= 50')

subplot(N,1,3)
plot(t, (rectified_mat)')
title('Rectified readings')

%% make test file
csvwrite('pelvis-test.csv', mat')


%% make jambe test file
angle = (sin(pi*t))/2 * pi/4;

x = sin(angle);
y = sin(32*pi*t)*0.03;
z = -cos(angle);

x(1:5*fs) = 0;
y(1:5*fs) = 0;
z(1:5*fs) = -1;

x(end-5*fs:end) = 0;
y(end-5*fs:end) = 0;
z(end-5*fs:end) = -1;

init_mat = [x; y; z];

theta = pi/4;
psi   = pi/8;
phi   = pi/3;

Q = eulerXZX(theta, psi, phi);

mat = Q * [x; y; z];
%mat = mat + 0.1*randn(size(mat));

% two third way a shift of the sensor occured
mat(:, ceil(length(mat(1,:))*2/3:end)) = eulerXZX(pi/3, -pi/6, pi/4) * mat(:, ceil(length(mat(1,:))*2/3:end));
%% Post treatment

rectified_mat = rectify_acc(mat, fs, 10, 20, 100);

%% plot
figure
N = 3;

subplot(N,1,1)
plot(t, init_mat')
title('Actual acceleration')


subplot(N,1,2)
hold off
plot(t, (mat)')
hold on
plot([t(end)*2/3 t(end)*2/3]+0.5, [-1 1], 'k')
title('Sensor reading with the sensor moving at t=68')

subplot(N,1,3)
plot(t, (rectified_mat)')
title('Rectified readings')

%mat = [zeros(1,length(t)); zeros(1,length(t)); ones(1,length(t));];
csvwrite('jambe-test.csv', mat')