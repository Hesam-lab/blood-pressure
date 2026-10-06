function w = batchlms(x, y, mu, p, epoch)
%BATCHLMS Full-batch squared-error descent with step size mu/k.
%   The gradient is a SUM over samples, as in the original implementation.
%   W has (EPOCH+1) rows, including the zero initial state.
[x, y] = validate_lms_inputs(x, y, mu, p);
validateattributes(epoch, {'numeric'}, {'scalar','integer','positive','finite'}, mfilename, 'epoch');
w = zeros(epoch+1, p);
for k = 1:epoch
    e = y - x*w(k,:)';
    w(k+1,:) = w(k,:) + (mu/k)*(e'*x);
    if any(~isfinite(w(k+1,:)))
        error('blood_pressure:LMSDiverged', 'Nonfinite batch coefficients; reduce the learning rate or rescale the data.');
    end
end
end
