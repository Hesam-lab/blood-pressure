function [x, y] = validate_lms_inputs(x, y, mu, p)
%VALIDATE_LMS_INPUTS Shared validation and orientation for LMS solvers.
validateattributes(x, {'numeric'}, {'2d','real','finite','nonempty'}, mfilename, 'x');
validateattributes(y, {'numeric'}, {'vector','real','finite','nonempty'}, mfilename, 'y');
validateattributes(mu, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'mu');
validateattributes(p, {'numeric'}, {'scalar','integer','finite','positive'}, mfilename, 'p');
if size(x,1) ~= numel(y) || size(x,2) ~= p
    error('blood_pressure:InvalidLMSSize', 'x must have numel(y) rows and p columns.');
end
x = double(x);
y = double(y(:));
end
