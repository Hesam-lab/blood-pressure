function w = onlinelms(x, y, mu, p)
%ONLINELMS One sequential pass with diminishing step size mu/k.
%   W has size (size(X,1)+1)-by-P; row 1 is the zero initial state.
%   The last row contains the fitted coefficients. Y accepts either orientation.
[x, y] = validate_lms_inputs(x, y, mu, p);
L = numel(y);
w = zeros(L+1, p);
for k = 1:L
    e = y(k) - x(k,:)*w(k,:)';
    w(k+1,:) = w(k,:) + (mu/k)*e*x(k,:);
    if any(~isfinite(w(k+1,:)))
        error('blood_pressure:LMSDiverged', 'Nonfinite online coefficients; reduce the learning rate or rescale the data.');
    end
end
end
