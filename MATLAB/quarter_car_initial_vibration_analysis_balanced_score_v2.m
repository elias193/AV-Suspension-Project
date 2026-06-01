clc
close all force

outputFolder = '/Users/eliasklestinis/Documents/Uni/Semester 1 2026/Advanced Vibrations/Project/MATLAB/Quarter Car Grpahs';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder)
end

csvFolder = fullfile(outputFolder, 'CSV Results');

if ~exist(csvFolder, 'dir')
    mkdir(csvFolder)
end

set(groot, 'defaultAxesFontSize', 16)
set(groot, 'defaultTextFontSize', 16)
set(groot, 'defaultLegendFontSize', 14)
set(groot, 'defaultLineLineWidth', 2.0)
set(groot, 'defaultFigureVisible', 'off')

m_s = 290;
m_u = 40;
k_t = 200000;

caseNames = {'Comfort', 'Rally', 'Track'};

baseline_k_s = [15000, 25000, 40000];
baseline_c_s = [1200, 2000, 2850];

selected_k_s = [10000, 18000, 30000];
selected_c_s = [1150, 2300, 3600];

caseColours = [
    0.0000, 0.4470, 0.7410
    0.8500, 0.3250, 0.0980
    0.9290, 0.6940, 0.1250
];

bumpHeight = 0.04;
bumpDuration = 0.12;
sineAmplitude = 0.02;
sineFrequency = 1.5;

t_bump = linspace(0, 5, 5001);
t_sine = linspace(0, 10, 10001);

freqWide = linspace(0.5, 20, 400);
freqLow = linspace(0.5, 3.8, 80);

parameterTable = table( ...
    string(caseNames(:)), ...
    baseline_k_s(:), ...
    baseline_c_s(:), ...
    selected_k_s(:), ...
    selected_c_s(:), ...
    'VariableNames', { ...
    'Case', ...
    'baseline_k_s_N_per_m', ...
    'baseline_c_s_Ns_per_m', ...
    'selected_k_s_N_per_m', ...
    'selected_c_s_Ns_per_m'} ...
);

for i = 1:3
    baselineBump(i) = simulateQuarterCarBump(m_s, m_u, k_t, baseline_k_s(i), baseline_c_s(i), bumpHeight, bumpDuration, t_bump);
    selectedBump(i) = simulateQuarterCarBump(m_s, m_u, k_t, selected_k_s(i), selected_c_s(i), bumpHeight, bumpDuration, t_bump);

    baselineSine(i) = simulateQuarterCarSine(m_s, m_u, k_t, baseline_k_s(i), baseline_c_s(i), sineAmplitude, sineFrequency, t_sine);
    selectedSine(i) = simulateQuarterCarSine(m_s, m_u, k_t, selected_k_s(i), selected_c_s(i), sineAmplitude, sineFrequency, t_sine);

    baselineFRWide(i) = quarterCarFrequencyResponse(m_s, m_u, k_t, baseline_k_s(i), baseline_c_s(i), sineAmplitude, freqWide);
    baselineFRLow(i) = quarterCarFrequencyResponse(m_s, m_u, k_t, baseline_k_s(i), baseline_c_s(i), sineAmplitude, freqLow);

    baselineNaturalFrequencies(i, :) = quarterCarNaturalFrequencies(m_s, m_u, k_t, baseline_k_s(i));
end

naturalFrequencyTable = table( ...
    string(caseNames(:)), ...
    baselineNaturalFrequencies(:, 1), ...
    baselineNaturalFrequencies(:, 2), ...
    'VariableNames', {'Case', 'f_body_Hz', 'f_wheel_Hz'} ...
);

disp('Quarter-car natural frequencies')
disp(naturalFrequencyTable)

bumpSummaryTable = table( ...
    string(caseNames(:)), ...
    [baselineBump.peak_abs_sprung_mass_displacement]', ...
    [baselineBump.peak_abs_sprung_mass_acceleration]', ...
    [baselineBump.peak_abs_suspension_deflection]', ...
    [baselineBump.peak_abs_tyre_deflection]', ...
    [selectedBump.peak_abs_sprung_mass_displacement]', ...
    [selectedBump.peak_abs_sprung_mass_acceleration]', ...
    [selectedBump.peak_abs_suspension_deflection]', ...
    [selectedBump.peak_abs_tyre_deflection]', ...
    'VariableNames', { ...
    'Case', ...
    'baseline_peak_abs_xs', ...
    'baseline_peak_abs_xsddot', ...
    'baseline_peak_abs_suspension_deflection', ...
    'baseline_peak_abs_tyre_deflection', ...
    'selected_peak_abs_xs', ...
    'selected_peak_abs_xsddot', ...
    'selected_peak_abs_suspension_deflection', ...
    'selected_peak_abs_tyre_deflection'} ...
);

disp('Quarter-car bump-response summary')
disp(bumpSummaryTable)

sineSummaryTable = table( ...
    string(caseNames(:)), ...
    [baselineSine.rms_sprung_mass_acceleration]', ...
    [baselineSine.peak_abs_sprung_mass_displacement]', ...
    [baselineSine.peak_abs_suspension_deflection]', ...
    [baselineSine.peak_abs_tyre_deflection]', ...
    [selectedSine.rms_sprung_mass_acceleration]', ...
    [selectedSine.peak_abs_sprung_mass_displacement]', ...
    [selectedSine.peak_abs_suspension_deflection]', ...
    [selectedSine.peak_abs_tyre_deflection]', ...
    'VariableNames', { ...
    'Case', ...
    'baseline_rms_xsddot', ...
    'baseline_peak_abs_xs', ...
    'baseline_peak_abs_suspension_deflection', ...
    'baseline_peak_abs_tyre_deflection', ...
    'selected_rms_xsddot', ...
    'selected_peak_abs_xs', ...
    'selected_peak_abs_suspension_deflection', ...
    'selected_peak_abs_tyre_deflection'} ...
);

disp('Quarter-car sinusoidal-response summary')
disp(sineSummaryTable)

frequencyResponseWideTable = makeFrequencyResponseTable(freqWide, baselineFRWide, caseNames, sineAmplitude);
frequencyResponseLowTable = makeFrequencyResponseTable(freqLow, baselineFRLow, caseNames, sineAmplitude);

writetable(parameterTable, fullfile(csvFolder, 'quarter_car_parameters.csv'))
writetable(naturalFrequencyTable, fullfile(csvFolder, 'quarter_car_natural_frequencies.csv'))
writetable(bumpSummaryTable, fullfile(csvFolder, 'quarter_car_bump_response_summary.csv'))
writetable(sineSummaryTable, fullfile(csvFolder, 'quarter_car_sinusoidal_response_summary.csv'))
writetable(frequencyResponseWideTable, fullfile(csvFolder, 'quarter_car_frequency_response_wide.csv'))
writetable(frequencyResponseLowTable, fullfile(csvFolder, 'quarter_car_frequency_response_low_frequency.csv'))

makeSummaryBarFigure(caseNames, baselineBump, selectedBump, baselineSine, selectedSine, outputFolder)

plotBumpTimeHistory(t_bump, baselineBump, caseNames, caseColours, outputFolder)

plotSineTimeHistory(t_sine, baselineSine, caseNames, caseColours, outputFolder)

plotFrequencyResponseSingle(freqWide, baselineFRWide, 'suspension', 'Peak suspension deflection (m)', 'Frequency response - Peak suspension deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_peak_suspension_deflection')
plotFrequencyResponseSingle(freqWide, baselineFRWide, 'tyre', 'Peak tyre deflection (m)', 'Frequency response - Peak tyre deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_peak_tyre_deflection')
plotFrequencyResponseSingle(freqWide, baselineFRWide, 'sprung', 'Peak sprung mass displacement (m)', 'Frequency response - Peak sprung mass displacement', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_peak_sprung_mass_displacement')
plotFrequencyResponseSingle(freqWide, baselineFRWide, 'rmsAcceleration', 'RMS sprung mass acceleration (m/s^2)', 'Frequency response - RMS sprung mass acceleration', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_rms_sprung_mass_acceleration')

plotFrequencyResponseSingle(freqLow, baselineFRLow, 'suspension', 'Peak suspension deflection (m)', 'Frequency response - Peak suspension deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_low_frequency_peak_suspension_deflection')
plotFrequencyResponseSingle(freqLow, baselineFRLow, 'tyre', 'Peak tyre deflection (m)', 'Frequency response - Peak tyre deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_low_frequency_peak_tyre_deflection')
plotFrequencyResponseSingle(freqLow, baselineFRLow, 'sprung', 'Peak sprung mass displacement (m)', 'Frequency response - Peak sprung mass displacement', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_low_frequency_peak_sprung_mass_displacement')
plotFrequencyResponseSingle(freqLow, baselineFRLow, 'rmsAcceleration', 'RMS sprung mass acceleration (m/s^2)', 'Frequency response - RMS sprung mass acceleration', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'frequency_response_low_frequency_rms_sprung_mass_acceleration')

plotNormalisedFrequencyResponse(freqWide, baselineFRWide, sineAmplitude, 'suspension', 'Peak suspension deflection / X_r (-)', 'Normalised frequency response - Peak suspension deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'normalised_frequency_response_peak_suspension_deflection')
plotNormalisedFrequencyResponse(freqWide, baselineFRWide, sineAmplitude, 'tyre', 'Peak tyre deflection / X_r (-)', 'Normalised frequency response - Peak tyre deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'normalised_frequency_response_peak_tyre_deflection')
plotNormalisedFrequencyResponse(freqWide, baselineFRWide, sineAmplitude, 'sprung', 'Peak x_s / X_r (-)', 'Normalised frequency response - Peak sprung mass displacement', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'normalised_frequency_response_peak_sprung_mass_displacement')

plotNormalisedFrequencyResponse(freqLow, baselineFRLow, sineAmplitude, 'suspension', 'Peak suspension deflection / X_r (-)', 'Normalised frequency response - Peak suspension deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'normalised_frequency_response_low_frequency_peak_suspension_deflection')
plotNormalisedFrequencyResponse(freqLow, baselineFRLow, sineAmplitude, 'tyre', 'Peak tyre deflection / X_r (-)', 'Normalised frequency response - Peak tyre deflection', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'normalised_frequency_response_low_frequency_peak_tyre_deflection')
plotNormalisedFrequencyResponse(freqLow, baselineFRLow, sineAmplitude, 'sprung', 'Peak x_s / X_r (-)', 'Normalised frequency response - Peak sprung mass displacement', caseNames, caseColours, baselineNaturalFrequencies, outputFolder, 'normalised_frequency_response_low_frequency_peak_sprung_mass_displacement')

comfortSweep = makeParameterSweep(m_s, m_u, k_t, 10000, 20000, 800, 1600, selected_k_s(1), selected_c_s(1), baseline_k_s(1), baseline_c_s(1), bumpHeight, bumpDuration, sineAmplitude, sineFrequency);
rallySweep = makeParameterSweep(m_s, m_u, k_t, 18000, 32000, 1500, 2600, selected_k_s(2), selected_c_s(2), baseline_k_s(2), baseline_c_s(2), bumpHeight, bumpDuration, sineAmplitude, sineFrequency);
trackSweep = makeParameterSweep(m_s, m_u, k_t, 30000, 50000, 2200, 3600, selected_k_s(3), selected_c_s(3), baseline_k_s(3), baseline_c_s(3), bumpHeight, bumpDuration, sineAmplitude, sineFrequency);

writetable(makeParameterSweepTable(comfortSweep), fullfile(csvFolder, 'comfort_parameter_sweep.csv'))
writetable(makeParameterSweepTable(rallySweep), fullfile(csvFolder, 'rally_parameter_sweep.csv'))
writetable(makeParameterSweepTable(trackSweep), fullfile(csvFolder, 'track_parameter_sweep.csv'))

plotParameterContour(comfortSweep, 'Comfort', outputFolder, 'comfort_parameter_contours')
plotParameterContour(rallySweep, 'Rally', outputFolder, 'rally_parameter_contours')
plotParameterContour(trackSweep, 'Track', outputFolder, 'track_parameter_contours')

plotOneDimensionalSweeps(comfortSweep, 'Comfort', outputFolder, 'comfort_one_dimensional_parameter_sweeps')
plotOneDimensionalSweeps(rallySweep, 'Rally', outputFolder, 'rally_one_dimensional_parameter_sweeps')
plotOneDimensionalSweeps(trackSweep, 'Track', outputFolder, 'track_one_dimensional_parameter_sweeps')

disp(['Saved quarter-car figures to: ', outputFolder])
disp(['Saved quarter-car CSV files to: ', csvFolder])

close all force

function out = simulateQuarterCarBump(m_s, m_u, k_t, k_s, c_s, bumpHeight, bumpDuration, t)
    roadFunction = @(time) bumpRoad(time, bumpHeight, bumpDuration);
    out = simulateQuarterCar(m_s, m_u, k_t, k_s, c_s, roadFunction, t);
end

function out = simulateQuarterCarSine(m_s, m_u, k_t, k_s, c_s, sineAmplitude, sineFrequency, t)
    roadFunction = @(time) sineAmplitude .* sin(2*pi*sineFrequency*time);
    out = simulateQuarterCar(m_s, m_u, k_t, k_s, c_s, roadFunction, t);
    steadyIndex = t >= 5;
    out.rms_sprung_mass_acceleration = rms(out.sprung_mass_acceleration(steadyIndex));
    out.peak_abs_sprung_mass_displacement = max(abs(out.sprung_mass_displacement(steadyIndex)));
    out.peak_abs_suspension_deflection = max(abs(out.suspension_deflection(steadyIndex)));
    out.peak_abs_tyre_deflection = max(abs(out.tyre_deflection(steadyIndex)));
end

function out = simulateQuarterCar(m_s, m_u, k_t, k_s, c_s, roadFunction, t)
    z0 = [0; 0; 0; 0];
    options = odeset('RelTol', 1e-7, 'AbsTol', 1e-9);
    [tout, zout] = ode45(@(time, z) quarterCarODE(time, z, m_s, m_u, k_t, k_s, c_s, roadFunction), t, z0, options);

    x_s = zout(:, 1);
    x_s_dot = zout(:, 2);
    x_u = zout(:, 3);
    x_u_dot = zout(:, 4);
    x_r = roadFunction(tout);

    x_s_ddot = (-c_s .* (x_s_dot - x_u_dot) - k_s .* (x_s - x_u)) ./ m_s;
    x_u_ddot = (c_s .* (x_s_dot - x_u_dot) + k_s .* (x_s - x_u) - k_t .* (x_u - x_r)) ./ m_u;

    out.t = tout;
    out.sprung_mass_displacement = x_s;
    out.sprung_mass_velocity = x_s_dot;
    out.unsprung_mass_displacement = x_u;
    out.unsprung_mass_velocity = x_u_dot;
    out.road_displacement = x_r;
    out.sprung_mass_acceleration = x_s_ddot;
    out.unsprung_mass_acceleration = x_u_ddot;
    out.suspension_deflection = x_s - x_u;
    out.tyre_deflection = x_u - x_r;
    out.peak_abs_sprung_mass_displacement = max(abs(x_s));
    out.peak_abs_sprung_mass_acceleration = max(abs(x_s_ddot));
    out.peak_abs_suspension_deflection = max(abs(x_s - x_u));
    out.peak_abs_tyre_deflection = max(abs(x_u - x_r));
end

function dz = quarterCarODE(time, z, m_s, m_u, k_t, k_s, c_s, roadFunction)
    x_s = z(1);
    x_s_dot = z(2);
    x_u = z(3);
    x_u_dot = z(4);
    x_r = roadFunction(time);

    x_s_ddot = (-c_s*(x_s_dot - x_u_dot) - k_s*(x_s - x_u)) / m_s;
    x_u_ddot = (c_s*(x_s_dot - x_u_dot) + k_s*(x_s - x_u) - k_t*(x_u - x_r)) / m_u;

    dz = [x_s_dot; x_s_ddot; x_u_dot; x_u_ddot];
end

function x_r = bumpRoad(t, bumpHeight, bumpDuration)
    x_r = zeros(size(t));
    index = t >= 0 & t <= bumpDuration;
    x_r(index) = 0.5*bumpHeight*(1 - cos(2*pi*t(index)/bumpDuration));
end

function response = quarterCarFrequencyResponse(m_s, m_u, k_t, k_s, c_s, roadAmplitude, frequencies)
    response.sprung = zeros(size(frequencies));
    response.suspension = zeros(size(frequencies));
    response.tyre = zeros(size(frequencies));
    response.rmsAcceleration = zeros(size(frequencies));

    for j = 1:length(frequencies)
        omega = 2*pi*frequencies(j);

        dynamicStiffness = [
            k_s - m_s*omega^2 + 1i*c_s*omega, -k_s - 1i*c_s*omega
            -k_s - 1i*c_s*omega, k_s + k_t - m_u*omega^2 + 1i*c_s*omega
        ];

        forcing = [0; k_t*roadAmplitude];
        q = dynamicStiffness \ forcing;

        X_s = q(1);
        X_u = q(2);
        X_r = roadAmplitude;

        response.sprung(j) = abs(X_s);
        response.suspension(j) = abs(X_s - X_u);
        response.tyre(j) = abs(X_u - X_r);
        response.rmsAcceleration(j) = abs(omega^2 * X_s) / sqrt(2);
    end
end

function naturalFrequencies = quarterCarNaturalFrequencies(m_s, m_u, k_t, k_s)
    M = [m_s, 0; 0, m_u];
    K = [k_s, -k_s; -k_s, k_s + k_t];
    eigenvalues = eig(K, M);
    naturalFrequencies = sort(sqrt(eigenvalues) / (2*pi)).';
end

function makeSummaryBarFigure(caseNames, baselineBump, selectedBump, baselineSine, selectedSine, outputFolder)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 1000]);
    tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact')

    nexttile
    values = [[baselineBump.peak_abs_sprung_mass_acceleration].', [selectedBump.peak_abs_sprung_mass_acceleration].'];
    makeGroupedBar(values, caseNames, 'Bump peak sprung-mass acceleration', 'Peak |x_s''''| for bump (m/s^2)')

    nexttile
    values = [[baselineSine.rms_sprung_mass_acceleration].', [selectedSine.rms_sprung_mass_acceleration].'];
    makeGroupedBar(values, caseNames, 'Sinusoidal RMS sprung-mass acceleration', 'RMS x_s'''' for sinusoidal 1.5 Hz (m/s^2)')

    nexttile
    values = [[baselineBump.peak_abs_suspension_deflection].', [selectedBump.peak_abs_suspension_deflection].'];
    makeGroupedBar(values, caseNames, 'Bump peak suspension deflection', 'Peak suspension deflection for bump (m)')

    nexttile
    values = [[baselineSine.peak_abs_tyre_deflection].', [selectedSine.peak_abs_tyre_deflection].'];
    makeGroupedBar(values, caseNames, 'Sinusoidal peak tyre deflection', 'Peak tyre deflection for sinusoidal (m)')

    saveFigure(fig, outputFolder, 'summary_baseline_selected_bars')
end

function makeGroupedBar(values, caseNames, titleText, yLabelText)
    b = bar(values);
    b(1).FaceColor = [0.0000, 0.4470, 0.7410];
    b(2).FaceColor = [0.8500, 0.3250, 0.0980];
    set(gca, 'XTickLabel', caseNames)
    ylabel(yLabelText)
    xlabel('Vehicle case')
    title(titleText)
    legend({'Baseline', 'Selected'}, 'Location', 'best')
    grid on
    box on
end

function plotBumpTimeHistory(t, results, caseNames, caseColours, outputFolder)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).suspension_deflection, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Suspension deflection, x_s - x_u (m)')
    title('Bump Input - Suspension deflection, x_s - x_u (m)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'bump_suspension_deflection')

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).tyre_deflection, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Tyre deflection, x_u - x_r (m)')
    title('Bump Input - Tyre deflection, x_u - x_r (m)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'bump_tyre_deflection')

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).sprung_mass_displacement, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Sprung mass displacement, x_s (m)')
    title('Bump Input - Sprung mass displacement, x_s (m)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'bump_sprung_mass_displacement')

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).sprung_mass_acceleration, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Sprung mass acceleration, x_s'''' (m/s^2)')
    title('Bump Input - Sprung mass acceleration, x_s'''' (m/s^2)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'bump_sprung_mass_acceleration')
end

function plotSineTimeHistory(t, results, caseNames, caseColours, outputFolder)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).suspension_deflection, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Suspension deflection, x_s - x_u (m)')
    title('Sinusoidal Input - Suspension deflection, x_s - x_u (m)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'sinusoidal_suspension_deflection')

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).tyre_deflection, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Tyre deflection, x_u - x_r (m)')
    title('Sinusoidal Input - Tyre deflection, x_u - x_r (m)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'sinusoidal_tyre_deflection')

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).sprung_mass_displacement, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Sprung mass displacement, x_s (m)')
    title('Sinusoidal Input - Sprung mass displacement, x_s (m)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'sinusoidal_sprung_mass_displacement')

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 900]);
    hold on
    for i = 1:3
        plot(t, results(i).sprung_mass_acceleration, 'Color', caseColours(i, :))
    end
    xlabel('Time (s)')
    ylabel('Sprung mass acceleration, x_s'''' (m/s^2)')
    title('Sinusoidal Input - Sprung mass acceleration, x_s'''' (m/s^2)')
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, 'sinusoidal_sprung_mass_acceleration')
end

function plotFrequencyResponseSingle(frequencies, responses, fieldName, yLabelText, titleText, caseNames, caseColours, naturalFrequencies, outputFolder, fileName)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 900]);
    hold on

    for i = 1:3
        plot(frequencies, responses(i).(fieldName), 'Color', caseColours(i, :))
    end

    for i = 1:3
        if naturalFrequencies(i, 1) >= min(frequencies) && naturalFrequencies(i, 1) <= max(frequencies)
            xline(naturalFrequencies(i, 1), '--', 'Color', caseColours(i, :), 'HandleVisibility', 'off')
        end
        if naturalFrequencies(i, 2) >= min(frequencies) && naturalFrequencies(i, 2) <= max(frequencies)
            xline(naturalFrequencies(i, 2), '--', 'Color', caseColours(i, :), 'HandleVisibility', 'off')
        end
    end

    xlabel('Excitation frequency (Hz)')
    ylabel(yLabelText)
    title(titleText)
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, fileName)
end

function plotNormalisedFrequencyResponse(frequencies, responses, roadAmplitude, fieldName, yLabelText, titleText, caseNames, caseColours, naturalFrequencies, outputFolder, fileName)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1200, 900]);
    hold on

    for i = 1:3
        plot(frequencies, responses(i).(fieldName) ./ roadAmplitude, 'Color', caseColours(i, :))
    end

    for i = 1:3
        if naturalFrequencies(i, 1) >= min(frequencies) && naturalFrequencies(i, 1) <= max(frequencies)
            xline(naturalFrequencies(i, 1), '--', 'Color', caseColours(i, :), 'HandleVisibility', 'off')
        end
        if naturalFrequencies(i, 2) >= min(frequencies) && naturalFrequencies(i, 2) <= max(frequencies)
            xline(naturalFrequencies(i, 2), '--', 'Color', caseColours(i, :), 'HandleVisibility', 'off')
        end
    end

    xlabel('Excitation frequency (Hz)')
    ylabel(yLabelText)
    title(titleText)
    legend(caseNames, 'Location', 'best')
    grid on
    box on
    saveFigure(fig, outputFolder, fileName)
end

function sweep = makeParameterSweep(m_s, m_u, k_t, kMin, kMax, cMin, cMax, selectedK, selectedC, baselineK, baselineC, bumpHeight, bumpDuration, sineAmplitude, sineFrequency)
    kValues = linspace(kMin, kMax, 15);
    cValues = linspace(cMin, cMax, 15);
    [K, C] = meshgrid(kValues, cValues);

    bumpAcceleration = zeros(size(K));
    bumpSuspension = zeros(size(K));
    sineRmsAcceleration = zeros(size(K));
    sineTyre = zeros(size(K));

    t = linspace(0, 5, 2501);

    for row = 1:size(K, 1)
        for col = 1:size(K, 2)
            bump = simulateQuarterCarBump(m_s, m_u, k_t, K(row, col), C(row, col), bumpHeight, bumpDuration, t);
            sineFR = quarterCarFrequencyResponse(m_s, m_u, k_t, K(row, col), C(row, col), sineAmplitude, sineFrequency);

            bumpAcceleration(row, col) = bump.peak_abs_sprung_mass_acceleration;
            bumpSuspension(row, col) = bump.peak_abs_suspension_deflection;
            sineRmsAcceleration(row, col) = sineFR.rmsAcceleration;
            sineTyre(row, col) = sineFR.tyre;
        end
    end

    baselineBump = simulateQuarterCarBump(m_s, m_u, k_t, baselineK, baselineC, bumpHeight, bumpDuration, t);
    baselineSineFR = quarterCarFrequencyResponse(m_s, m_u, k_t, baselineK, baselineC, sineAmplitude, sineFrequency);

    balancedScore = 0.25*( ...
        bumpAcceleration ./ baselineBump.peak_abs_sprung_mass_acceleration + ...
        sineRmsAcceleration ./ baselineSineFR.rmsAcceleration + ...
        bumpSuspension ./ baselineBump.peak_abs_suspension_deflection + ...
        sineTyre ./ baselineSineFR.tyre);

    sweep.K = K;
    sweep.C = C;
    sweep.kValues = kValues;
    sweep.cValues = cValues;
    sweep.bumpAcceleration = bumpAcceleration;
    sweep.sineRmsAcceleration = sineRmsAcceleration;
    sweep.bumpSuspension = bumpSuspension;
    sweep.sineTyre = sineTyre;
    sweep.balancedScore = balancedScore;
    sweep.selectedK = selectedK;
    sweep.selectedC = selectedC;
    sweep.baselineK = baselineK;
    sweep.baselineC = baselineC;
    sweep.benchmarkBumpAcceleration = baselineBump.peak_abs_sprung_mass_acceleration;
    sweep.benchmarkSineRmsAcceleration = baselineSineFR.rmsAcceleration;
end

function plotParameterContour(sweep, caseName, outputFolder, fileName)
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 1000]);
    tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact')

    nexttile
    contourf(sweep.K ./ 1000, sweep.C ./ 1000, sweep.balancedScore, 18, 'LineStyle', 'none')
    hold on
    plot(sweep.baselineK ./ 1000, sweep.baselineC ./ 1000, 'wo', 'MarkerFaceColor', 'w', 'MarkerSize', 8)
    plot(sweep.selectedK ./ 1000, sweep.selectedC ./ 1000, 'r*', 'MarkerSize', 10)
    xlabel('k_s (kN/m)')
    ylabel('c_s (kNs/m)')
    title('Balanced score (-)')
    colorbar
    grid on
    box on

    nexttile
    contourf(sweep.K ./ 1000, sweep.C ./ 1000, sweep.sineRmsAcceleration, 18, 'LineStyle', 'none')
    hold on
    plot(sweep.baselineK ./ 1000, sweep.baselineC ./ 1000, 'wo', 'MarkerFaceColor', 'w', 'MarkerSize', 8)
    plot(sweep.selectedK ./ 1000, sweep.selectedC ./ 1000, 'r*', 'MarkerSize', 10)
    xlabel('k_s (kN/m)')
    ylabel('c_s (kNs/m)')
    title('Sine RMS sprung-mass acceleration (m/s^2)')
    colorbar
    grid on
    box on

    nexttile
    contourf(sweep.K ./ 1000, sweep.C ./ 1000, sweep.bumpSuspension, 18, 'LineStyle', 'none')
    hold on
    plot(sweep.baselineK ./ 1000, sweep.baselineC ./ 1000, 'wo', 'MarkerFaceColor', 'w', 'MarkerSize', 8)
    plot(sweep.selectedK ./ 1000, sweep.selectedC ./ 1000, 'r*', 'MarkerSize', 10)
    xlabel('k_s (kN/m)')
    ylabel('c_s (kNs/m)')
    title('Bump peak suspension deflection (m)')
    colorbar
    grid on
    box on

    nexttile
    contourf(sweep.K ./ 1000, sweep.C ./ 1000, sweep.sineTyre, 18, 'LineStyle', 'none')
    hold on
    plot(sweep.baselineK ./ 1000, sweep.baselineC ./ 1000, 'wo', 'MarkerFaceColor', 'w', 'MarkerSize', 8)
    plot(sweep.selectedK ./ 1000, sweep.selectedC ./ 1000, 'r*', 'MarkerSize', 10)
    xlabel('k_s (kN/m)')
    ylabel('c_s (kNs/m)')
    title('Sine peak tyre deflection (m)')
    colorbar
    grid on
    box on

    sgtitle([caseName, ' parameter contour sweep'])
    saveFigure(fig, outputFolder, fileName)
end

function plotOneDimensionalSweeps(sweep, caseName, outputFolder, fileName)
    [~, cIndex] = min(abs(sweep.cValues - sweep.selectedC));
    [~, kIndex] = min(abs(sweep.kValues - sweep.selectedK));

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100, 100, 1400, 1000]);
    tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact')

    nexttile
    plot(sweep.kValues ./ 1000, sweep.bumpAcceleration(cIndex, :), '-o')
    xlabel('k_s (kN/m)')
    ylabel('Peak |x_s''''| for bump (m/s^2)')
    title([caseName, ' - k_s sweep, bump'])
    grid on
    box on

    nexttile
    plot(sweep.kValues ./ 1000, sweep.sineRmsAcceleration(cIndex, :), '-o')
    xlabel('k_s (kN/m)')
    ylabel('RMS x_s'''' for sinusoidal 1.5 Hz (m/s^2)')
    title([caseName, ' - k_s sweep, sinusoidal 1.5 Hz'])
    grid on
    box on

    nexttile
    plot(sweep.cValues ./ 1000, sweep.bumpAcceleration(:, kIndex), '-o')
    xlabel('c_s (kNs/m)')
    ylabel('Peak |x_s''''| for bump (m/s^2)')
    title([caseName, ' - c_s sweep, bump'])
    grid on
    box on

    nexttile
    plot(sweep.cValues ./ 1000, sweep.sineRmsAcceleration(:, kIndex), '-o')
    xlabel('c_s (kNs/m)')
    ylabel('RMS x_s'''' for sinusoidal 1.5 Hz (m/s^2)')
    title([caseName, ' - c_s sweep, sinusoidal 1.5 Hz'])
    grid on
    box on

    saveFigure(fig, outputFolder, fileName)
end

function responseTable = makeFrequencyResponseTable(frequencies, responses, caseNames, roadAmplitude)
    responseTable = table(frequencies(:), 'VariableNames', {'frequency_Hz'});

    for i = 1:length(caseNames)
        prefix = lower(char(caseNames{i}));

        responseTable.([prefix, '_peak_sprung_mass_displacement_m']) = responses(i).sprung(:);
        responseTable.([prefix, '_rms_sprung_mass_acceleration_mps2']) = responses(i).rmsAcceleration(:);
        responseTable.([prefix, '_peak_suspension_deflection_m']) = responses(i).suspension(:);
        responseTable.([prefix, '_peak_tyre_deflection_m']) = responses(i).tyre(:);

        responseTable.([prefix, '_normalised_peak_sprung_mass_displacement']) = responses(i).sprung(:) ./ roadAmplitude;
        responseTable.([prefix, '_normalised_peak_suspension_deflection']) = responses(i).suspension(:) ./ roadAmplitude;
        responseTable.([prefix, '_normalised_peak_tyre_deflection']) = responses(i).tyre(:) ./ roadAmplitude;
    end
end

function sweepTable = makeParameterSweepTable(sweep)
    sweepTable = table( ...
        sweep.K(:), ...
        sweep.C(:), ...
        sweep.K(:) ./ 1000, ...
        sweep.C(:) ./ 1000, ...
        sweep.balancedScore(:), ...
        sweep.bumpAcceleration(:), ...
        sweep.sineRmsAcceleration(:), ...
        sweep.bumpSuspension(:), ...
        sweep.sineTyre(:), ...
        repmat(sweep.baselineK, numel(sweep.K), 1), ...
        repmat(sweep.baselineC, numel(sweep.C), 1), ...
        repmat(sweep.selectedK, numel(sweep.K), 1), ...
        repmat(sweep.selectedC, numel(sweep.C), 1), ...
        'VariableNames', { ...
        'k_s_N_per_m', ...
        'c_s_Ns_per_m', ...
        'k_s_kN_per_m', ...
        'c_s_kNs_per_m', ...
        'balanced_score', ...
        'bump_peak_sprung_mass_acceleration_mps2', ...
        'sine_rms_sprung_mass_acceleration_mps2', ...
        'bump_peak_suspension_deflection_m', ...
        'sine_peak_tyre_deflection_m', ...
        'baseline_k_s_N_per_m', ...
        'baseline_c_s_Ns_per_m', ...
        'selected_k_s_N_per_m', ...
        'selected_c_s_Ns_per_m'} ...
    );
end

function saveFigure(fig, outputFolder, fileName)
    drawnow
    exportgraphics(fig, fullfile(outputFolder, [fileName, '.png']), 'Resolution', 300)
    close(fig)
end
