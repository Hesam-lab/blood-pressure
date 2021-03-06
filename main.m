clc; clear; close all;
% In this code, the aortic blood pressure is estimated from radial
% blood pressure by AR model based on two least-mean-square (LMS)
% approaches:
% 1- Offline method: all training samples are inserted into LMS equation,
% and through several iteration (epoch), the AR coefficients (w) are
% calculated.
% 2- online method: For each given input and output samples, w is computed
% iteratively. Thus the number of epoch is equal to total samples
% Note: AR order and learning rate should be adujsted manually
% 
% written by: Hesam Shokouh Alaei
% 
% data description==> Fs:200 Hz, length: 10 seconds
data = load('blood_pressure.mat');
sig1 = data.radial_data;    % model input
sig2 = data.aortic_data;    % model output

N=length(sig1)*7/10;
ts_train = sig1(1:N);   % train data: 7 seconds
ts_test = sig1(N+1:end);    % test data: 3 seconds
M = length(ts_test);

p = 20; % AR order
y_train = sig2(1:N-p)';
x_train = arlag(ts_train,N,p);  % create lag matrix of radial signal

% online least mean square
mu = 2e-4;  %learning rate
w = onlinelms(x_train,y_train,mu,p);    % AR parameters

% offline least mean square
% mu = 2e-7;    %learning rate
% epoch = 1e4;    % number of iteration
% w = batchlms(x_train,y_train,mu,p,epoch); % AR parameters

y_test = sig2(N+1:end-p)';
x_test = arlag(ts_test,M,p);
y(:,1) = x_test*w(end,:)';
rmse = sqrt(mse(y_test - y))    % root mean square error
cc = corrcoef(y_test,y)     % correlation coefficient

% plot 
figure(1);
t = linspace(7,10,M-p);
plot(t,y_test)
hold on
plot(t,y)
legend ('real aortic blood pressure','simulated aortic blood pressure')
grid minor
xlabel('time(s)')
ylabel('amplitude')
title('Estimation of Aortic blood pressure with AR model and online LMS')    %for online mode
% title('Estimation of Aortic blood pressure with AR model and offline LMS') % for offline mode





