%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: D:\Users\ANDHY\Documents\0_KULIAH_S2\0_COLLAGE\3th_semester\Centrifuge\MATLAB\Data and Matlab\7.11m-80%\CSW_TEST7\TEST7_ACC_65g.lvm
%
% Auto-generated by MATLAB on 20-Jul-2024 22:43:07

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 13);

% Specify range and delimiter
opts.DataLines = [24, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["X_Value", "Acc_6", "Acc_42", "Acc_60", "Acc_48", "Acc_49", "Acc_52", "Acc_53", "Acc_56", "Acc_58", "Acc_46", "Acc_47", "Var13"];
opts.SelectedVariableNames = ["X_Value", "Acc_6", "Acc_42", "Acc_60", "Acc_48", "Acc_49", "Acc_52", "Acc_53", "Acc_56", "Acc_58", "Acc_46", "Acc_47"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Var13", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Var13", "EmptyFieldRule", "auto");

% Import the data
tbl = readtable("D:\Users\ANDHY\Documents\0_KULIAH_S2\0_COLLAGE\3th_semester\Centrifuge\MATLAB\Data and Matlab\7.11m-80%\CSW_TEST7\TEST7_ACC_65g.lvm", opts);
% Convert to output type
X_Value = tbl.X_Value;
Acc_6 = tbl.Acc_6;
Acc_42 = tbl.Acc_42;
Acc_60 = tbl.Acc_60;
Acc_48 = tbl.Acc_48;
Acc_49 = tbl.Acc_49;
Acc_52 = tbl.Acc_52;
Acc_53 = tbl.Acc_53;
Acc_56 = tbl.Acc_56;
Acc_58 = tbl.Acc_58;
Acc_46 = tbl.Acc_46;
Acc_47 = tbl.Acc_47;
% Clear temporary variables
clear opts tbl
signal=Acc_6;
%% PREPARATION
N=65;
time=(X_Value*N);
signal=Acc_6/N;
%% FILTERING MAK NYUS
close all;
% Butterworth filter parameters
applyFiltering = true;      % Set to true to apply filtering, false to skip filtering
filterType = 'bandpass';    % Choose 'low', 'high', 'bandpass', or 'stop'
cutoffFrequency1 = 0.1;       % Example cutoff frequency for lowpass and highpass
cutoffFrequency2 = 3;      % Example upper cutoff frequency for bandpass and stop
filterOrder = 4;            % Example filter order
check_frequency = true;     % Set to true to perform FFT analysis before and after processing

% Smoothing parameters
applySmoothing = false;      % Set to true to apply smoothing
smoothingMethod = 'exponential'; % Choose 'moving', 'exponential', or 'savitzky-golay'
movingAverageWindow = 1000000;    % Example window size for moving average
exponentialAlpha = 0.0001;     % Smoothing factor for exponential smoothing, enol sampai satu
savitzkyOrder = 3;          % Polynomial order for Savitzky-Golay filter
savitzkyFrameLength = 11;   % Frame length for Savitzky-Golay filter

% Get the screen size
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Calculate the sampling period and sampling frequency
T = time(2) - time(1);
Fs = 1 / T;

% Length of the signal
L = length(signal);

if check_frequency
    % Perform the FFT before processing
    Y = fft(signal);

    % Compute the two-sided spectrum and then the single-sided spectrum
    P2 = abs(Y / L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2 * P1(2:end-1);

    % Define the frequency domain f
    f = Fs * (0:(L/2)) / L;

    % Plot the single-sided amplitude spectrum before processing
    figure('Position', [0, screenHeight/2 - 200, screenWidth/2, screenHeight/2]);
    plot(f, P1);
    title('Single-Sided Amplitude Spectrum of Signal Before Processing');
    xlabel('Frequency (f)');
    ylabel('|P1(f)|');
    grid on;
end

if applyFiltering
    % Normalize the cutoff frequencies
    Wn1 = cutoffFrequency1 / (Fs / 2); % Normalized cutoff frequency
    Wn2 = cutoffFrequency2 / (Fs / 2); % Normalized upper cutoff frequency

    % Design the Butterworth filter
    switch filterType
        case 'low'
            [b, a] = butter(filterOrder, Wn1, 'low');
        case 'high'
            [b, a] = butter(filterOrder, Wn1, 'high');
        case 'bandpass'
            [b, a] = butter(filterOrder, [Wn1, Wn2], 'bandpass');
        case 'stop'
            [b, a] = butter(filterOrder, [Wn1, Wn2], 'stop');
        otherwise
            error('Invalid filter type. Choose ''low'', ''high'', ''bandpass'', or ''stop''.');
    end

    % Apply the Butterworth filter
    processedSignal = filtfilt(b, a, signal); % Use filtfilt to avoid phase distortion
else
    processedSignal = signal;
end

if applySmoothing
    % Apply the selected smoothing method
    switch smoothingMethod
        case 'moving'
            processedSignal = movmean(processedSignal, movingAverageWindow);
        case 'exponential'
            processedSignal = filter(exponentialAlpha, [1 exponentialAlpha-1], processedSignal, processedSignal(1)*(1-exponentialAlpha));
        case 'savitzky-golay'
            processedSignal = sgolayfilt(processedSignal, savitzkyOrder, savitzkyFrameLength);
        otherwise
            error('Invalid smoothing method. Choose ''moving'', ''exponential'', or ''savitzky-golay''.');
    end
end

if check_frequency
    % Perform the FFT after processing
    Y_processed = fft(processedSignal);

    % Compute the two-sided spectrum and then the single-sided spectrum
    P2_processed = abs(Y_processed / L);
    P1_processed = P2_processed(1:L/2+1);
    P1_processed(2:end-1) = 2 * P1_processed(2:end-1);

    % Plot the single-sided amplitude spectrum after processing
    figure('Position', [0, 0, screenWidth/2, screenHeight/2]);
    plot(f, P1_processed);
    title('Single-Sided Amplitude Spectrum of Signal After Processing');
    xlabel('Frequency (f)');
    ylabel('|P1(f)|');
    grid on;
end

% Plot the original signal
figure('Position', [screenWidth/2, screenHeight/2 - 200, screenWidth/2, screenHeight/2]);
plot(time, signal);
title('Original Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Plot the processed signal (filtered or just smoothed)
figure('Position', [screenWidth/2, 0, screenWidth/2, screenHeight/2]);
plot(time, processedSignal);
title('Processed Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;