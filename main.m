clc; clear; close all;
% In this code, the aortic blood pressure (sig1) is estimated from radial
% blood pressure (sig2) by AR model based on two least-mean-square (LMS)
% approaches:
% 1- Offline method: all training samples are inserted into LMS equation,
% and through several iteration (epoch), the AR coefficient (w) is
% calculated.
% 2- online method: For each given input and output samples, w is computed
% iteratively. Thus the number of epoch is equal to total samples
% Note: AR order and learning rate should be adujsted manually
% 
% written by: Hesam Shokouh Alaei
% 
% data description==> Fs:200 Hz, length: 10 seconds
data = load('Data_Project1.mat');
sig1 = data.aortic_data;    % model output
sig2 = data.radial_data;    % model input

N=length(sig2)*7/10;
ts_train = sig2(1:N);   % train data: 7 seconds
ts_test = sig2(N+1:end);    % test data: 3 seconds
M = length(ts_test);

p = 20; % AR order
d_train = sig1(1:N-p)';
x_train = arlag(ts_train,N,p);  % create lag matrix 

% online least mean square
mu = 2e-4;  %learning rate
w = onlinelms(x_train,d_train,mu,p);    % AR parameters

% offline least mean square
% mu = 2e-7;    %learning rate
% epoch = 1e4;    % number of iteration
% w = batchlms(x_train,d_train,mu,p,epoch); % AR parameters

d_test = sig1(N+1:end-p)';
x_test = arlag(ts_test,M,p);
y(:,1) = x_test*w(end,:)';
rmse = sqrt(mse(d_test - y))    % root mean square error
cc = corrcoef(d_test,y)     % correlation coefficient

% plot 
figure(1);
t = linspace(7,10,M-p);
plot(t,d_test)
hold on
plot(t,y)
legend ('real aortic blood pressure','simulated aortic blood pressure')
grid minor
xlabel('time(s)')
ylabel('amplitude')
title('Estimation of Aortic blood pressure with AR model and online LMS')    %for online mode
% title('Estimation of Aortic blood pressure with AR model and offline LMS') % for offline mode





