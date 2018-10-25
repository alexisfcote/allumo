function y = butter_bandpass(x, fc_low, fc_high, fs)
%butter_bandpass Filters input x and returns output y.

d = designfilt('bandpassiir', 'FilterOrder', 2, 'HalfPowerFrequency1', fc_low, 'HalfPowerFrequency2', fc_high, 'SampleRate', fs);

y = filtfilt(d,x);


