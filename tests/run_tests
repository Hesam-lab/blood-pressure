function run_tests()
%RUN_TESTS Dependency-free regression checks for MATLAB and GNU Octave.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);

% Hand-computed lag order and orientation.
expected = [2 1; 3 2; 4 3];
assert(isequal(arlag(1:5,5,2), expected));
assert(isequal(arlag((1:5)',5,2), expected));
assert_error(@() arlag(1:5,4,2), 'blood_pressure:InvalidLagSize');
assert_error(@() arlag(1:5,5,5), 'blood_pressure:InvalidLagSize');

% Hand-computed updates detect gradient, step-size and history regressions.
x = [1 2; 3 4]; y = [2; 1];
w = onlinelms(x,y,0.1,2);
assert_close(w, [0 0; 0.2 0.4; 0.02 0.16], 1e-12);
assert_close(onlinelms(x,y',0.1,2), w, 1e-12);
w = batchlms(x,y,0.1,2,2);
assert_close(w, [0 0; 0.5 0.8; -0.06 0.05], 1e-12);
assert_close(batchlms(x,y',0.1,2,2), w, 1e-12);
assert_error(@() onlinelms(x,[1 2 3],0.1,2), 'blood_pressure:InvalidLMSSize');
assert_error(@() batchlms(x,y,0.1,1,2), 'blood_pressure:InvalidLMSSize');
assert_error(@() onlinelms([1;2],[realmax;realmax],realmax,1), 'blood_pressure:LMSDiverged');

% A single training pair gives coefficient 3 exactly. Later targets follow
% aortic(t)=3*radial(t-1), so this catches the original shifted-target bug.
r = 1:6; a = [0 3 6 9 12 15];
s = estimate_pressure(r,a,'Order',1,'TrainFraction',0.4,'LearningRate',1,'SampleRate',2);
assert_close(s.coefficients,3,1e-12);
assert_close(s.prediction,[6;9;12;15],1e-12);
assert_close(s.time,[1;1.5;2;2.5],1e-12);
assert(isequal(s.test_indices,(3:6)'));
assert(s.rmse < 1e-12 && s.mae < 1e-12);
assert_close(s.correlation,1,1e-12);
b = estimate_pressure(r,a,'Order',1,'TrainFraction',0.4,'LearningRate',1,'Method','batch','Epochs',1);
assert_close(b.prediction,s.prediction,1e-12);

% Altering held-out targets must not affect the fit or predictions.
altered = a; altered(3:end) = -100;
t = estimate_pressure(r,altered,'Order',1,'TrainFraction',0.4,'LearningRate',1);
assert_close(t.coefficients,s.coefficients,1e-12);
assert_close(t.prediction,s.prediction,1e-12);
assert(isnan(t.correlation));
% Future radial values cannot affect earlier predictions.
altered = r; altered(end-1:end) = 100;
t = estimate_pressure(altered,a,'Order',1,'TrainFraction',0.4,'LearningRate',1);
assert_close(t.prediction(1:3),s.prediction(1:3),1e-12);
assert_error(@() estimate_pressure(r,a(1:5)), 'blood_pressure:SignalLengthMismatch');
assert_error(@() estimate_pressure(r,a,'Order',5), 'blood_pressure:InsufficientSamples');
assert_any_error(@() estimate_pressure([NaN 1 2],[1 2 3]));
assert_any_error(@() estimate_pressure(r,a,'LearningRate',-1));
assert_any_error(@() estimate_pressure(r,a,'TrainFraction',1));

% Bundled-data smoke checks for both methods and both vector orientations.
data = load(fullfile(root,'blood_pressure.mat'));
s = estimate_pressure(data.radial_data,data.aortic_data);
t = estimate_pressure(data.radial_data(:),data.aortic_data(:));
assert(numel(s.prediction) == 600 && s.n_train == 1400);
assert(all(isfinite(s.prediction)) && isfinite(s.rmse));
assert_close(s.prediction,t.prediction,1e-10);
b = estimate_pressure(data.radial_data,data.aortic_data,'Method','batch','Epochs',20);
assert(all(isfinite(b.prediction)) && isfinite(b.rmse));
fprintf('All regression checks passed.\n');
end

function assert_close(actual, expected, tolerance)
assert(isequal(size(actual),size(expected)));
assert(all(abs(actual(:)-expected(:)) <= tolerance));
end

function assert_error(f, identifier)
try
    f();
catch err
    assert(strcmp(err.identifier,identifier), ['Unexpected error: ' err.identifier]);
    return;
end
error('Expected error %s was not raised.',identifier);
end

function assert_any_error(f)
try
    f();
catch
    return;
end
error('Expected an input validation error.');
end
