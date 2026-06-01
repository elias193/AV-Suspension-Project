clear
close all
clc

saveFolder = '/Users/eliasklestinis/Documents/Uni/Semester 1 2026/Advanced Vibrations/Project/PLANE HALF';

if ~exist(saveFolder, 'dir')
    mkdir(saveFolder)
end

set(groot, 'DefaultAxesFontName', 'Arial')
set(groot, 'DefaultTextFontName', 'Arial')
set(groot, 'DefaultAxesFontSize', 40)
set(groot, 'DefaultTextFontSize', 40)
set(groot, 'DefaultLineLineWidth', 3)

p.ms = 580;
p.Iyy = 696;
p.muf = 40;
p.mur = 40;
p.a = 1.4;
p.b = 1.4;
p.wheelbase = p.a + p.b;
p.ktf = 200000;
p.ktr = 200000;

caseNames = {'Comfort', 'Rally', 'Track'};
caseKs = [15000, 25000, 40000];
caseCs = [1200, 2000, 2850];
caseColours = [
    0.0000 0.4470 0.7410
    0.8500 0.3250 0.0980
    0.9290 0.6940 0.1250
];

for i = 1:numel(caseNames)
    cases(i).name = caseNames{i};
    cases(i).ksFront = caseKs(i);
    cases(i).ksRear = caseKs(i);
    cases(i).csFront = caseCs(i);
    cases(i).csRear = caseCs(i);
    cases(i).colour = caseColours(i,:);
end

nCases = numel(cases);

roadHeight = 0.04;
roadSigma = 0.025;
vehicleSpeed = 10;
frontBumpTime = 0.30;
rearBumpTime = frontBumpTime + p.wheelbase / vehicleSpeed;

tBump = (0:0.001:2.5)';
yFrontBump = roadHeight * exp(-((tBump - frontBumpTime) / roadSigma).^2);
yRearBump = roadHeight * exp(-((tBump - rearBumpTime) / roadSigma).^2);
uBump = [yFrontBump, yRearBump];

frequencyHz = linspace(0.5, 20, 800)';
roadSineAmplitude = 0.02;
tSine = (0:0.005:25)';
steadyStateStart = 12.5;
steadyIndex = tSine >= steadyStateStart;

for i = 1:nCases
    models(i) = buildHalfCarModel(p, cases(i));
    fNatHzAll(i,:) = models(i).fNatHz(:)';
end

Case = strings(nCases,1);
f1_Hz = zeros(nCases,1);
f2_Hz = zeros(nCases,1);
f3_Hz = zeros(nCases,1);
f4_Hz = zeros(nCases,1);

for i = 1:nCases
    Case(i) = cases(i).name;
    f1_Hz(i) = fNatHzAll(i,1);
    f2_Hz(i) = fNatHzAll(i,2);
    f3_Hz(i) = fNatHzAll(i,3);
    f4_Hz(i) = fNatHzAll(i,4);
end

naturalFrequencyTable = table(Case, f1_Hz, f2_Hz, f3_Hz, f4_Hz);

for i = 1:nCases
    bumpResults(i).caseName = cases(i).name;
    bumpResults(i).out = simulateHalfCar(models(i), p, tBump, uBump);
end

for i = 1:nCases
    out = bumpResults(i).out;

    bumpPeakBodyBounce(i,1) = max(abs(out.z));
    bumpPeakPitchRad(i,1) = max(abs(out.theta));
    bumpPeakPitchDeg(i,1) = max(abs(out.thetaDeg));
    bumpPeakBodyBounceAcceleration(i,1) = max(abs(out.zdd));
    bumpPeakPitchAcceleration(i,1) = max(abs(out.thetadd));
    bumpPeakFrontSuspensionDeflection(i,1) = max(abs(out.frontSuspensionDeflection));
    bumpPeakRearSuspensionDeflection(i,1) = max(abs(out.rearSuspensionDeflection));
    bumpPeakFrontTyreDeflection(i,1) = max(abs(out.frontTyreDeflection));
    bumpPeakRearTyreDeflection(i,1) = max(abs(out.rearTyreDeflection));
end

bumpSummaryTable = table( ...
    Case, ...
    bumpPeakBodyBounce, ...
    bumpPeakPitchRad, ...
    bumpPeakPitchDeg, ...
    bumpPeakBodyBounceAcceleration, ...
    bumpPeakPitchAcceleration, ...
    bumpPeakFrontSuspensionDeflection, ...
    bumpPeakRearSuspensionDeflection, ...
    bumpPeakFrontTyreDeflection, ...
    bumpPeakRearTyreDeflection, ...
    'VariableNames', { ...
    'Case', ...
    'peak_abs_body_bounce', ...
    'peak_abs_pitch_angle_rad', ...
    'peak_abs_pitch_angle_deg', ...
    'peak_abs_body_bounce_acceleration', ...
    'peak_abs_pitch_acceleration', ...
    'peak_abs_front_suspension_deflection', ...
    'peak_abs_rear_suspension_deflection', ...
    'peak_abs_front_tyre_deflection', ...
    'peak_abs_rear_tyre_deflection'});

for i = 1:nCases
    frequencyResults(i).caseName = cases(i).name;
    frequencyResults(i).frequencyHz = frequencyHz;
    frequencyResults(i).peakBodyBounce = zeros(size(frequencyHz));
    frequencyResults(i).peakPitchAngleDeg = zeros(size(frequencyHz));
    frequencyResults(i).rmsBodyBounceAcceleration = zeros(size(frequencyHz));
    frequencyResults(i).peakFrontSuspensionDeflection = zeros(size(frequencyHz));
    frequencyResults(i).peakRearSuspensionDeflection = zeros(size(frequencyHz));
    frequencyResults(i).peakFrontTyreDeflection = zeros(size(frequencyHz));
    frequencyResults(i).peakRearTyreDeflection = zeros(size(frequencyHz));

    for j = 1:numel(frequencyHz)
        f = frequencyHz(j);
        w = 2*pi*f;

        yFront = roadSineAmplitude * sin(w * tSine);
        yRear = roadSineAmplitude * sin(w * (tSine - p.wheelbase / vehicleSpeed));
        uSine = [yFront, yRear];

        out = simulateHalfCar(models(i), p, tSine, uSine);

        frequencyResults(i).peakBodyBounce(j) = max(abs(out.z(steadyIndex)));
        frequencyResults(i).peakPitchAngleDeg(j) = max(abs(out.thetaDeg(steadyIndex)));
        frequencyResults(i).rmsBodyBounceAcceleration(j) = sqrt(mean(out.zdd(steadyIndex).^2));
        frequencyResults(i).peakFrontSuspensionDeflection(j) = max(abs(out.frontSuspensionDeflection(steadyIndex)));
        frequencyResults(i).peakRearSuspensionDeflection(j) = max(abs(out.rearSuspensionDeflection(steadyIndex)));
        frequencyResults(i).peakFrontTyreDeflection(j) = max(abs(out.frontTyreDeflection(steadyIndex)));
        frequencyResults(i).peakRearTyreDeflection(j) = max(abs(out.rearTyreDeflection(steadyIndex)));
    end
end

for i = 1:nCases
    [peakBodyBounceValue(i,1), idx] = max(frequencyResults(i).peakBodyBounce);
    peakBodyBounceFrequencyHz(i,1) = frequencyHz(idx);

    [peakPitchAngleDegValue(i,1), idx] = max(frequencyResults(i).peakPitchAngleDeg);
    peakPitchAngleFrequencyHz(i,1) = frequencyHz(idx);

    [peakRmsBodyBounceAcceleration(i,1), idx] = max(frequencyResults(i).rmsBodyBounceAcceleration);
    peakRmsBodyBounceAccelerationFrequencyHz(i,1) = frequencyHz(idx);

    [peakFrontSuspensionDeflectionValue(i,1), idx] = max(frequencyResults(i).peakFrontSuspensionDeflection);
    peakFrontSuspensionDeflectionFrequencyHz(i,1) = frequencyHz(idx);

    [peakRearSuspensionDeflectionValue(i,1), idx] = max(frequencyResults(i).peakRearSuspensionDeflection);
    peakRearSuspensionDeflectionFrequencyHz(i,1) = frequencyHz(idx);

    [peakFrontTyreDeflectionValue(i,1), idx] = max(frequencyResults(i).peakFrontTyreDeflection);
    peakFrontTyreDeflectionFrequencyHz(i,1) = frequencyHz(idx);

    [peakRearTyreDeflectionValue(i,1), idx] = max(frequencyResults(i).peakRearTyreDeflection);
    peakRearTyreDeflectionFrequencyHz(i,1) = frequencyHz(idx);
end

frequencySummaryTable = table( ...
    Case, ...
    peakBodyBounceValue, ...
    peakBodyBounceFrequencyHz, ...
    peakPitchAngleDegValue, ...
    peakPitchAngleFrequencyHz, ...
    peakRmsBodyBounceAcceleration, ...
    peakRmsBodyBounceAccelerationFrequencyHz, ...
    peakFrontSuspensionDeflectionValue, ...
    peakFrontSuspensionDeflectionFrequencyHz, ...
    peakRearSuspensionDeflectionValue, ...
    peakRearSuspensionDeflectionFrequencyHz, ...
    peakFrontTyreDeflectionValue, ...
    peakFrontTyreDeflectionFrequencyHz, ...
    peakRearTyreDeflectionValue, ...
    peakRearTyreDeflectionFrequencyHz, ...
    'VariableNames', { ...
    'Case', ...
    'peak_body_bounce_value', ...
    'peak_body_bounce_frequency_Hz', ...
    'peak_pitch_angle_value_deg', ...
    'peak_pitch_angle_frequency_Hz', ...
    'peak_rms_body_bounce_acceleration', ...
    'peak_rms_body_bounce_acceleration_frequency_Hz', ...
    'peak_front_suspension_deflection_value', ...
    'peak_front_suspension_deflection_frequency_Hz', ...
    'peak_rear_suspension_deflection_value', ...
    'peak_rear_suspension_deflection_frequency_Hz', ...
    'peak_front_tyre_deflection_value', ...
    'peak_front_tyre_deflection_frequency_Hz', ...
    'peak_rear_tyre_deflection_value', ...
    'peak_rear_tyre_deflection_frequency_Hz'});

writetable(naturalFrequencyTable, fullfile(saveFolder, 'half_car_pitch_natural_frequencies.csv'))
writetable(bumpSummaryTable, fullfile(saveFolder, 'half_car_pitch_bump_response_summary.csv'))
writetable(frequencySummaryTable, fullfile(saveFolder, 'half_car_pitch_frequency_response_summary.csv'))

disp('Half-car pitch natural frequencies')
disp(naturalFrequencyTable)
disp('Half-car pitch bump-response summary')
disp(bumpSummaryTable)
disp('Half-car pitch frequency-response summary')
disp(frequencySummaryTable)

if any(abs(peakBodyBounceFrequencyHz - frequencyHz(1)) < 1e-12)
    disp('Note: at least one peak body-bounce value occurs at the lower sweep bound of 0.50 Hz. Do not describe this as a confirmed resonance unless the sweep is extended below this frequency.')
end

plotBumpSingleMetric(tBump, bumpResults, cases, 'zdd', 'Half-car bump input: body bounce acceleration', 'Body bounce acceleration (m/s^2)', [0 2.5], saveFolder, 'half_car_bump_body_bounce_acceleration')
plotBumpSingleMetric(tBump, bumpResults, cases, 'z', 'Half-car bump input: body bounce', 'Body bounce x (m)', [0 2.5], saveFolder, 'half_car_bump_body_bounce')
plotBumpSingleMetric(tBump, bumpResults, cases, 'thetaDeg', 'Half-car bump input: pitch angle', 'Pitch angle (deg)', [0 2.5], saveFolder, 'half_car_bump_pitch_angle_deg')

fig = newReportFigure();
plot(tBump, yFrontBump, 'Color', cases(1).colour)
hold on
plot(tBump, yRearBump, '--', 'Color', cases(2).colour)
configureAxes(gca)
xlim([0 1.2])
xlabel('Time (s)')
ylabel('Road displacement (m)')
title('Half-car bump input: front and rear road inputs')
legend({'Front road input y_1', 'Rear road input y_2'}, 'Location', 'northeast')
saveReportFigure(fig, saveFolder, 'half_car_bump_front_rear_road_inputs')

plotFrontRearBump(tBump, bumpResults, cases, 'frontSuspensionDeflection', 'rearSuspensionDeflection', 'Suspension deflection (m)', 'suspension deflection', [0 2.5], saveFolder, 'half_car_bump_suspension_deflection_front_rear')
plotFrontRearBump(tBump, bumpResults, cases, 'frontTyreDeflection', 'rearTyreDeflection', 'Tyre deflection (m)', 'tyre deflection', [0 2.5], saveFolder, 'half_car_bump_tyre_deflection_front_rear')
plotFrontRearBump(tBump, bumpResults, cases, 'xf', 'xr', 'Wheel displacement (m)', 'wheel displacement', [0 2.5], saveFolder, 'half_car_validation_bump_wheel_displacement_front_rear')

plotFrequencySingleMetric(frequencyResults, cases, fNatHzAll, 'peakBodyBounce', 'Half-car frequency response: peak body bounce', 'Peak body bounce (m)', [0.5 20], [1 2], saveFolder, 'half_car_frequency_response_peak_body_bounce')
plotFrequencySingleMetric(frequencyResults, cases, fNatHzAll, 'peakPitchAngleDeg', 'Half-car frequency response: peak pitch angle', 'Peak pitch angle (deg)', [0.5 20], [1 2], saveFolder, 'half_car_frequency_response_peak_pitch_angle_deg')
plotFrequencySingleMetric(frequencyResults, cases, fNatHzAll, 'rmsBodyBounceAcceleration', 'Half-car frequency response: RMS body bounce acceleration', 'RMS body bounce acceleration (m/s^2)', [0.5 20], [1 2 3 4], saveFolder, 'half_car_frequency_response_rms_body_bounce_acceleration')
plotFrequencySingleMetric(frequencyResults, cases, fNatHzAll, 'rmsBodyBounceAcceleration', 'Half-car low-frequency response: RMS body bounce acceleration', 'RMS body bounce acceleration (m/s^2)', [0.5 4], [1 2], saveFolder, 'half_car_frequency_response_rms_body_bounce_acceleration_low_frequency_zoom')

plotFrontRearFrequency(frequencyResults, cases, fNatHzAll, 'peakFrontSuspensionDeflection', 'peakRearSuspensionDeflection', 'Peak suspension deflection (m)', 'suspension frequency response', [0.5 20], saveFolder, 'half_car_frequency_response_suspension_deflection_front_rear')
plotFrontRearFrequency(frequencyResults, cases, fNatHzAll, 'peakFrontTyreDeflection', 'peakRearTyreDeflection', 'Peak tyre deflection (m)', 'tyre frequency response', [0.5 20], saveFolder, 'half_car_frequency_response_tyre_deflection_front_rear')

fig = newReportFigure();
tiledlayout(2,2, 'Padding', 'compact', 'TileSpacing', 'compact')

nexttile
bar(categorical(Case), bumpPeakBodyBounceAcceleration)
configureAxes(gca)
ylabel('Peak body acceleration (m/s^2)')
title('Bump body acceleration')

nexttile
bar(categorical(Case), bumpPeakPitchDeg)
configureAxes(gca)
ylabel('Peak pitch angle (deg)')
title('Bump pitch angle')

nexttile
bar(categorical(Case), bumpPeakBodyBounce * 1000)
configureAxes(gca)
ylabel('Peak body bounce (mm)')
title('Bump body bounce')

nexttile
bar(categorical(Case), max([bumpPeakFrontTyreDeflection, bumpPeakRearTyreDeflection], [], 2) * 1000)
configureAxes(gca)
ylabel('Peak tyre deflection (mm)')
title('Bump tyre deflection')

saveReportFigure(fig, saveFolder, 'half_car_bump_summary_bar_chart')

function model = buildHalfCarModel(p, c)
    ms = p.ms;
    Iyy = p.Iyy;
    muf = p.muf;
    mur = p.mur;
    a = p.a;
    b = p.b;

    ksf = c.ksFront;
    ksr = c.ksRear;
    csf = c.csFront;
    csr = c.csRear;
    ktf = p.ktf;
    ktr = p.ktr;

    M = diag([ms, Iyy, muf, mur]);

    K = [
        ksf + ksr,          a*ksf - b*ksr,          -ksf,       -ksr
        a*ksf - b*ksr,      a^2*ksf + b^2*ksr,      -a*ksf,      b*ksr
        -ksf,               -a*ksf,                 ksf + ktf,  0
        -ksr,                b*ksr,                 0,          ksr + ktr
    ];

    C = [
        csf + csr,          a*csf - b*csr,          -csf,       -csr
        a*csf - b*csr,      a^2*csf + b^2*csr,      -a*csf,      b*csr
        -csf,               -a*csf,                 csf,        0
        -csr,                b*csr,                 0,          csr
    ];

    E = [
        0,   0
        0,   0
        ktf, 0
        0,   ktr
    ];

    A = [
        zeros(4), eye(4)
        -M\K,     -M\C
    ];

    B = [
        zeros(4,2)
        M\E
    ];

    outputMatrix = eye(8);
    feedthroughMatrix = zeros(8,2);

    lambda = eig(K, M);
    lambda = real(lambda);
    lambda = lambda(lambda > 0);
    fNatHz = sort(sqrt(lambda) / (2*pi));

    model.M = M;
    model.K = K;
    model.C = C;
    model.E = E;
    model.A = A;
    model.B = B;
    model.sys = ss(A, B, outputMatrix, feedthroughMatrix);
    model.fNatHz = fNatHz(:);
end

function out = simulateHalfCar(model, p, t, u)
    x = lsim(model.sys, u, t);

    q = x(:,1:4);
    qd = x(:,5:8);

    roadForce = u * model.E';
    rhs = roadForce' - model.C * qd' - model.K * q';
    qdd = (model.M \ rhs)';

    z = q(:,1);
    theta = q(:,2);
    xf = q(:,3);
    xr = q(:,4);

    frontSuspensionDeflection = z + p.a * theta - xf;
    rearSuspensionDeflection = z - p.b * theta - xr;
    frontTyreDeflection = xf - u(:,1);
    rearTyreDeflection = xr - u(:,2);

    out.z = z;
    out.theta = theta;
    out.thetaDeg = theta * 180 / pi;
    out.xf = xf;
    out.xr = xr;
    out.zd = qd(:,1);
    out.thetad = qd(:,2);
    out.xfd = qd(:,3);
    out.xrd = qd(:,4);
    out.zdd = qdd(:,1);
    out.thetadd = qdd(:,2);
    out.xfdd = qdd(:,3);
    out.xrdd = qdd(:,4);
    out.frontSuspensionDeflection = frontSuspensionDeflection;
    out.rearSuspensionDeflection = rearSuspensionDeflection;
    out.frontTyreDeflection = frontTyreDeflection;
    out.rearTyreDeflection = rearTyreDeflection;
end

function fig = newReportFigure()
    fig = figure('Color', 'w', 'Position', [80 80 1350 760]);
end

function configureAxes(ax)
    ax.FontName = 'Arial';
    ax.FontSize = 22;
    ax.LineWidth = 1.5;
    ax.Box = 'on';
    grid(ax, 'on')
    ax.GridAlpha = 0.16;
    ax.MinorGridAlpha = 0.08;
end

function saveReportFigure(fig, saveFolder, fileName)
    drawnow
    try
        exportgraphics(fig, fullfile(saveFolder, [fileName '.png']), 'Resolution', 300)
    catch
        saveas(fig, fullfile(saveFolder, [fileName '.png']))
    end
    close(fig)
end

function plotBumpSingleMetric(t, bumpResults, cases, fieldName, plotTitle, yLabelText, xLimits, saveFolder, fileName)
    fig = newReportFigure();
    hold on

    for i = 1:numel(cases)
        y = bumpResults(i).out.(fieldName);
        plot(t, y, 'Color', cases(i).colour)
    end

    configureAxes(gca)
    xlim(xLimits)
    xlabel('Time (s)')
    ylabel(yLabelText)
    title(plotTitle)
    legend({cases.name}, 'Location', 'northeast')
    saveReportFigure(fig, saveFolder, fileName)
end

function plotFrontRearBump(t, bumpResults, cases, frontField, rearField, yLabelText, resultName, xLimits, saveFolder, fileName)
    fig = figure('Color', 'w', 'Position', [80 80 1450 900]);
    tiledlayout(3,1, 'Padding', 'compact', 'TileSpacing', 'compact')

    for i = 1:numel(cases)
        nexttile
        plot(t, bumpResults(i).out.(frontField), 'Color', cases(i).colour)
        hold on
        plot(t, bumpResults(i).out.(rearField), '--', 'Color', cases(i).colour)
        configureAxes(gca)
        xlim(xLimits)
        xlabel('Time (s)')
        ylabel(yLabelText)
        title([cases(i).name ' ' resultName])
        legend({'Front', 'Rear'}, 'Location', 'northeast')
    end

    saveReportFigure(fig, saveFolder, fileName)
end

function plotFrequencySingleMetric(frequencyResults, cases, fNatHzAll, fieldName, plotTitle, yLabelText, xLimits, modeIndices, saveFolder, fileName)
    fig = newReportFigure();
    hold on

    for i = 1:numel(cases)
        plot(frequencyResults(i).frequencyHz, frequencyResults(i).(fieldName), 'Color', cases(i).colour)
    end

    configureAxes(gca)
    xlim(xLimits)
    xlabel('Excitation frequency (Hz)')
    ylabel(yLabelText)
    title(plotTitle)
    legend({cases.name}, 'Location', 'northeast')
    addNaturalFrequencyLines(gca, cases, fNatHzAll, modeIndices, 1:numel(cases))
    saveReportFigure(fig, saveFolder, fileName)
end

function plotFrontRearFrequency(frequencyResults, cases, fNatHzAll, frontField, rearField, yLabelText, resultName, xLimits, saveFolder, fileName)
    fig = figure('Color', 'w', 'Position', [80 80 1450 900]);
    tiledlayout(3,1, 'Padding', 'compact', 'TileSpacing', 'compact')

    for i = 1:numel(cases)
        nexttile
        plot(frequencyResults(i).frequencyHz, frequencyResults(i).(frontField), 'Color', cases(i).colour)
        hold on
        plot(frequencyResults(i).frequencyHz, frequencyResults(i).(rearField), '--', 'Color', cases(i).colour)
        configureAxes(gca)
        xlim(xLimits)
        xlabel('Excitation frequency (Hz)')
        ylabel(yLabelText)
        title([cases(i).name ' ' resultName])
        legend({'Front', 'Rear'}, 'Location', 'northeast')
        addNaturalFrequencyLines(gca, cases, fNatHzAll, [1 2 3 4], i)
    end

    saveReportFigure(fig, saveFolder, fileName)
end

function addNaturalFrequencyLines(ax, cases, fNatHzAll, modeIndices, caseIndices)
    yLimits = ylim(ax);

    for i = caseIndices
        for j = modeIndices
            xline(ax, fNatHzAll(i,j), ':', 'Color', lightenColour(cases(i).colour, 0.35), 'LineWidth', 1.2, 'HandleVisibility', 'off');
        end
    end

    ylim(ax, yLimits)
end

function cOut = lightenColour(cIn, amount)
    cOut = cIn + (1 - cIn) * amount;
end
