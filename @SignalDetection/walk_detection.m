function output = walk_detection( raw_cuissegaucheAcc, fs, thresh)
%WALKDETECTION Detect walking event from thigh accelerometer data

acc_magnitude = sqrt(sum(raw_cuissegaucheAcc.^2, 2));

output = SignalDetection.butter_bandpass(acc_magnitude, 1/10, 10, fs);

figure

plot(output)
hold on

output = conv(abs(output), hamming(fs*20)/sum(hamming(fs*20)), 'same');

plot(output)
output = output > thresh;
plot(output)

figure
end

