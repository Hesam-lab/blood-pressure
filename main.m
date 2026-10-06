% Radial-to-aortic pressure estimation demonstration.
% Written by Hesam Shokouh Alaei; see README.md for model assumptions.
% Resolve data and helper functions relative to this script.
projectDir = fileparts(mfilename('fullpath'));
addpath(projectDir);
data = load(fullfile(projectDir, 'blood_pressure.mat'));

% Use 'batch' to select full-batch LMS. Learning rates are method-specific.
result = estimate_pressure(data.radial_data, data.aortic_data, ...
    'Method', 'online', 'Order', 20, 'SampleRate', 200);

fprintf('Method: %s | Test samples: %d\n', result.config.Method, numel(result.target));
fprintf('RMSE: %.4f | MAE: %.4f | Pearson r: %.4f\n', ...
    result.rmse, result.mae, result.correlation);
fprintf('Training-mean baseline RMSE: %.4f\n', result.baseline_rmse);
figure;
plot(result.time, result.target, result.time, result.prediction);
legend('Measured aortic pressure', 'Estimated aortic pressure');
grid on;
xlabel('Time (s)');
ylabel('Pressure (original data units)');
title(sprintf('Lagged radial-to-aortic model: %s LMS', result.config.Method));
