function x = arlag(ts, N, p)
%ARLAG Past-sample regressors: row j predicts sample t = p+j.
%   X = ARLAG(TS,N,P) returns an (N-P)-by-P matrix with
%   X(j,:) = [TS(t-1), ..., TS(t-P)]. TS may be a row or column.
validateattributes(ts, {'numeric'}, {'vector','real','finite','nonempty'}, mfilename, 'ts');
validateattributes(N, {'numeric'}, {'scalar','integer','positive','finite'}, mfilename, 'N');
validateattributes(p, {'numeric'}, {'scalar','integer','positive','finite'}, mfilename, 'p');
if N ~= numel(ts) || p >= N
    error('blood_pressure:InvalidLagSize', 'N must equal numel(ts), and p must be smaller than N.');
end
ts = double(ts(:));
x = zeros(N-p, p);
for i = 1:p
    x(:,i) = ts(p-i+1:N-i);
end
end
