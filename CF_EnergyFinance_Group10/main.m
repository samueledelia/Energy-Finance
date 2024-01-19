%% ENERGY FINANCE PROJECT 3 - GROUP 10
% OPTION CALIBRATION AND PRICING WITH HJM MULTIFACTOR ( n = 0 and p = 2 )

clear
close all
clc

%% Importing market data and initializing useful vectors

mkt = import_data(0);   % mkt struct containing all the necessary data

tau_2       = mkt.datesExpiry./252;
tau_1       = mkt.datesStart/252;
strikes     = mkt.strikes;

sigma_1     = zeros(8,4);
sigma_2     = zeros(8,4);
beta        = zeros(21,4);
price       = zeros(1,5);
price_CI    = zeros(2,5);
Error_Prices = zeros(1,4);

%% Point 3

% Use constant Sigma 1 and Sigma 2 to calibrate the model
% In this point beta is fixed at 1 (lower and upper bounds = 1)


% setting sizes of sigma_1, sigma_2 and beta
sz1 = 1; sz2 = 1; szb = 1; 
sizes   = [sz1, sz2, szb];

% setting initial values for the calibration
a = 0.3; b = 0.05; c = 1;
initial = [a, b, c]; 

% setting lower and upper bounds for sigmas and beta
lbs = eps; lbb = 1; ubs = 3; ubb = 1;        
bounds  = [lbs, lbb, ubs, ubb]; 

% estimating sigma1 and sigma2 and plotting results
[sigmas,Error_Prices(1)] = calibrate_sigmas_HJM('Point 3', mkt, sizes, initial, bounds);

sigma_1(1:sz1,1) = sigmas(1:sz1);
sigma_2(1:sz2,1) = sigmas(sz1+1:sz1+sz2);
beta(1:szb,1)    = sigmas(sz1+sz2+1:end);

%% Point 4

% Sigma 1 now changes with time, while Sigma 2 remains constant
% Size of Sigma 1 will now be 8 like the different TTMs that we have.
% Beta is still equal to 1

% setting sizes of sigma_1, sigma_2 and beta
sz1 = 8; sz2 = 1; szb = 1;  % note that sigma1 vector has size 8 now 
sizes = [sz1, sz2, szb];

% setting initial values for the calibration
a = 0.3; b = 0.05; c = 1; 
initial = [a, b, c];

% setting lower and upper bounds for sigmas and beta
lbs = eps; lbb = 1; ubs = 3; ubb = 1; 
bounds = [lbs, lbb, ubs, ubb];

% estimating sigma1 and sigma2 and plotting results
[sigmas,Error_Prices(2)] = calibrate_sigmas_HJM('Point 4', mkt, sizes, initial, bounds);

sigma_1(1:sz1,2) = sigmas(1:sz1);
sigma_2(1:sz2,2) = sigmas(sz1+1:sz1+sz2);
beta(1:szb,2) = sigmas(sz1+sz2+1:end);

%% Point 5

% Sigma 1 and 2 both change with time.
% So now sizes of Sigma 1 and Sigma 2 will be 8 for both.
% Beta still fixed at 1

% setting sizes of sigma_1, sigma_2 and beta
sz1 = 8; sz2 = 8; szb = 1; 
sizes = [sz1, sz2, szb];

% setting initial values for the calibration
a = 0.3; b = 0.05; c = 1; 
initial = [a, b, c];

% setting lower and upper bounds for sigmas and beta
lbs = eps; lbb = 1; ubs = 3; ubb = 1; 
bounds = [lbs, lbb, ubs, ubb];

% estimating sigma1 and sigma2 and plotting results
[sigmas,Error_Prices(3)] = calibrate_sigmas_HJM('Point 5', mkt, sizes, initial, bounds);

sigma_1(1:sz1,3) = sigmas(1:sz1);
sigma_2(1:sz2,3) = sigmas(sz1+1:sz1+sz2);
beta(1:szb,3) = sigmas(sz1+sz2+1:end);

%% Point 6

% Only Sigma 1 change with time, Sigma 2 is now constant (just like point
% 4).
% But now we also add a Beta, a variable that changes with the strike
% price, to match the differences in volatility between the various strike
% prices.
%       Sigma_Hat = sqrt((Sigma_1^2 + Sigma_2^2)*(T-t0))*Beta

% setting sizes of sigma_1, sigma_2 and beta
sz1 = 8; sz2 = 1; szb = 21; 
sizes = [sz1, sz2, szb];

% setting initial values for the calibration
a = 0.5; b = 0.1; c = 0.5; 
initial = [a, b, c];

% setting lower and upper bounds for sigmas and beta
lbs = eps; lbb = -100; ubs = 4; ubb = 1000; 
bounds = [lbs, lbb, ubs, ubb];

% estimating sigma1, sigma2 and beta and plotting results
[sigmas,Error_Prices(4)] = calibrate_sigmas_HJM('Point 6', mkt, sizes, initial, bounds);

sigma_1(1:sz1,4) = sigmas(1:sz1);
sigma_2(1:sz2,4) = sigmas(sz1+1:sz1+sz2);
beta(1:szb,4) = sigmas(sz1+sz2+1:end);

%% Point 7

% Price a barrier swaption with the parameters that we got from the
% calibrations in point 3, 4, 5.

% Daily Monitoring.

Nsim = 1e5;     %params(1);
T = 0.5;        %params(2);
K = 500;        %params(3);
L = 450;        %params(4);
Ndates = T*252; %params(5);
params = [Nsim, T, K, L ,Ndates];

% 7.3
[price(1), price_CI(:,1)] = down_in(sigma_1(1,1), sigma_2(1,1), beta(1,1), mkt, params);
% 7.4
[price(2), price_CI(:,2)] = down_in(sigma_1(:,2), sigma_2(1,2), beta(1,2), mkt, params);
% 7.5
[price(3), price_CI(:,3)] = down_in(sigma_1(:,3), sigma_2(:,3), beta(1,3), mkt, params);

% Weekly monitoring with parameters that we calibrated in Point 5.
Ndates = T*52; % 52 trading weeks in a year.
params = [Nsim, T, K, L ,Ndates];
[price(4), price_CI(:,4)] = down_in(sigma_1(:,3), sigma_2(:,3), beta(1,3), mkt, params);

% 7.6
Ndates = T*252;
params = [Nsim, T, K, L ,Ndates];
[price(5), price_CI(:,5)] = down_in(sigma_1(:,4), sigma_2(:,4), beta(:,4), mkt, params);

%% Analytical price

r = -log(mkt.OIS(8))./yearfrac(mkt.t0,mkt.datesExpiry(8));
fwd = mkt.fwd;

% getting HJM model's sigma_hat using the parameters we calibrated
Sigma_hat = calculate_sigma(sigma_1, sigma_2, beta);

%% Computing errors for all the daily monitoring resuluts we obtained

% we are considering 4 out of the 5 values of the "price" vector, where we
% excluded price(4) which is the weekly monitoring case 

sigma = zeros(1,4);
sigma(1:4) = Sigma_hat(8,11,1:4);
Error_Prices_Analytical = zeros(1,4);
prices = [price(1:3), price(5)];
for i=1:4
    Error_Prices_Analytical(i) = abs(barrier_DI_price(fwd, r, sigma(i), K, L, T) - prices(i));
end

%% Plotting the errors we just computed
x = 1:4;
figure;
plot(x, Error_Prices_Analytical, 'r*--', 'MarkerSize', 10);

for i = 1:length(x)
    text(x(i), Error_Prices_Analytical(i), sprintf('(Point: %d, %.2f)', x(i), Error_Prices_Analytical(i)));
end
xlim([1,4.5])
xlabel('X-axis');
ylabel('Error Prices');
title('Error Prices Analytical Plot');
grid on;

%% Computing errors analytical price Model vs Market

% we are considering 4 out of the 5 values of the "price" vector, where we
% excluded price(4) which is the weekly monitoring case 
% In this case we are comparing the model with the market volatility, and
% we are using the exact formula to check whether our models are able to
% explain the market conditions


Error_ModVSMkt_Analytical = zeros(1,4);
prices = [price(1:3), price(5)];
for i=1:4
    Error_ModVSMkt_Analytical(i) = abs(barrier_DI_price(fwd, r, sigma(i), K, L, T) - barrier_DI_price(fwd, r, mkt.volatilitySurface(8, 11), K, L, T));
end

%% Plotting the errors we just computed
x = 1:4;
figure;
plot(x, Error_ModVSMkt_Analytical, 'b*--', 'MarkerSize', 10);

for i = 1:length(x)
    text(x(i), Error_ModVSMkt_Analytical(i), sprintf('(Point: %d, %.2f)', x(i), Error_ModVSMkt_Analytical(i)));
end
xlim([1,4.5])
xlabel('X-axis');
ylabel('Error Prices');
title('Error Prices Analytical Plot');
grid on;

%% Plotting Volatility Surfaces

Sigma_hat = calculate_sigma(sigma_1, sigma_2, beta);
tau_2 = mkt.datesExpiry./252; % divided by 252 so that we work with years
tau_1 = mkt.datesStart/252;
strikes = mkt.strikes;

n = plot_volatilities('Sigma_hat', tau_2, tau_1, strikes, ...
    Sigma_hat(:,:,3), Sigma_hat(:,:,4), mkt.volatilitySurface, ...
    'Point 5', 'Point 6', 'Market Volatility');
hold on

T_index = find(mkt.tenors == T);
K_index = find(mkt.strikes == K);
scatter3(T,K,Sigma_hat(T_index,K_index,3),'filled','MarkerFaceColor','k');
scatter3(T,K,Sigma_hat(T_index,K_index,4),'filled','MarkerFaceColor','k');
scatter3(T,K,mkt.volatilitySurface(T_index,K_index),'filled','MarkerFaceColor','k');
hold off