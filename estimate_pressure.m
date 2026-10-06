function result = estimate_pressure(radial, aortic, varargin)
%ESTIMATE_PRESSURE Fit a lagged radial-to-aortic linear model.
%   RESULT = ESTIMATE_PRESSURE(RADIAL,AORTIC,'Order',20,'Method','online')
%   uses a chronological 70/30 split. See README.md for all options.
validateattributes(radial, {'numeric'}, {'vector','real','finite','nonempty'}, mfilename, 'radial');
validateattributes(aortic, {'numeric'}, {'vector','real','finite','nonempty'}, mfilename, 'aortic');
if numel(radial) ~= numel(aortic)
    error('blood_pressure:SignalLengthMismatch', 'Radial and aortic signals must have equal lengths.');
end
parser = inputParser;
addParameter(parser, 'Order', 20);
addParameter(parser, 'TrainFraction', 0.7);
addParameter(parser, 'SampleRate', 200);
addParameter(parser, 'Method', 'online');
addParameter(parser, 'LearningRate', []);
addParameter(parser, 'Epochs', 10000);
parse(parser, varargin{:});
cfg = parser.Results;
validateattributes(cfg.Order, {'numeric'}, {'scalar','integer','positive','finite'});
validateattributes(cfg.TrainFraction, {'numeric'}, {'scalar','real','finite','>',0,'<',1});
validateattributes(cfg.SampleRate, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(cfg.Epochs, {'numeric'}, {'scalar','integer','positive','finite'});
cfg.Method = validatestring(cfg.Method, {'online','batch'});
if isempty(cfg.LearningRate)
    if strcmp(cfg.Method, 'online')
        cfg.LearningRate = 2e-4;
    else
        cfg.LearningRate = 2e-7;
    end
end
validateattributes(cfg.LearningRate, {'numeric'}, {'scalar','real','finite','positive'});
radial = double(radial(:));
aortic = double(aortic(:));
N = numel(radial);
nTrain = floor(N*cfg.TrainFraction);
p = cfg.Order;
if nTrain <= p || nTrain >= N
    error('blood_pressure:InsufficientSamples', 'The training split must contain more than Order samples and leave at least one test sample.');
end
% Row j contains radial(t-1:t-p) for target aortic(t), where t=p+j.
% Building all rows retains past radial context at the train/test boundary;
% no future radial samples or test aortic targets enter the fit.
x = arlag(radial, N, p);
xTrain = x(1:nTrain-p,:);
yTrain = aortic(p+1:nTrain);
if strcmp(cfg.Method, 'online')
    history = onlinelms(xTrain, yTrain, cfg.LearningRate, p);
else
    history = batchlms(xTrain, yTrain, cfg.LearningRate, p, cfg.Epochs);
end
result.coefficients = history(end,:)';
result.test_indices = (nTrain+1:N)';
result.time = (result.test_indices-1)/cfg.SampleRate;
result.target = aortic(result.test_indices);
result.prediction = x(nTrain-p+1:end,:)*result.coefficients;
if any(~isfinite(result.prediction))
    error('blood_pressure:NonfinitePrediction', 'Nonfinite prediction; reduce the learning rate or rescale the data.');
end
residual = result.target-result.prediction;
result.rmse = norm(residual)/sqrt(numel(residual));
result.mae = mean(abs(residual));
% Pearson correlation is undefined for constant or single-sample signals.
result.correlation = NaN;
if numel(result.target) > 1 && std(result.target) > 0 && std(result.prediction) > 0
    cc = corrcoef(result.target, result.prediction);
    result.correlation = cc(1,2);
end
% Training-mean baseline provides a simple reference without test fitting.
result.baseline_prediction = repmat(mean(yTrain), numel(result.target), 1);
result.baseline_rmse = norm(result.target-result.baseline_prediction)/sqrt(numel(result.target));
result.n_train = nTrain;
result.config = cfg;
end
