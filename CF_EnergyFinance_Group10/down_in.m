function [P, P_CI] = down_in(sigma_1, sigma_2, Beta, mkt, params)

% Montecarlo with Antithetic Variates to price a down and in swaption.
% Underlying forward dynamics simulated as a sum of two Brownian Motions as
%   seen in formula (6.9) on the Benth.
%
% INPUTS:
% sigma_1, sigma_2 and Beta = HJM model parameters
% mkt = struct containing all the market data we need
% params = vector containing the following parameters:
%           1) NSim = Number of simulations
%           2) T = TTM
%           3) K = strike
%           4) L = barrier
%           5) Ndates = Number of monitoring dates
% 
% OUTPUTS:
% P = price
% CI = Confidence Interval for the price

% Interpolating to find the right discounts
mkt.DF = interpol(mkt.t0,mkt.dates, mkt.OIS,mkt.datesExpiry);

% Parameters
Nsim = params(1);
T = params(2);
K = params(3);
L = params(4);
Ndates = params(5);

tau_2 = mkt.datesExpiry./252;
tau_1 = mkt.datesStart/252;
fwd = mkt.fwd;
strikes = mkt.strikes;
Beta = repelem(Beta, size(strikes,2)/size(Beta,1));
% Interpolating to find the beta corresponding to the strike we have
beta = interp1(strikes, Beta, K);

%% Simulate the underlying dynamics using MC with Antithetic Variable technique

[Path_X, Path_X_AV] = XAV(Nsim, T, Ndates, fwd, tau_1, tau_2, sigma_1, sigma_2, beta);

%% Calculate Payoffs

% Initializing payoffs vectors
Payoff = zeros(1,Nsim);
Payoff_AV = zeros(1,Nsim);

for j = 1:Nsim
    Payoff(j) = max(Path_X(j,end) - K, 0); % swaption payoff at maturity
    Payoff_AV(j) = max(Path_X_AV(j,end) - K, 0);
    % Checking the barrier
    if (min(Path_X(j,:)) > L) % if the forward doesn't hit the barrier
        Payoff(j) = 0; 
    end
    if (min(Path_X_AV(j,:)) > L)
        Payoff_AV(j) = 0; 
    end
end

%% Final Price P and Confidence Intervals CI

[P,~,P_CI] = normfit((Payoff + Payoff_AV)/2);
P = P.*mkt.OIS(8); % discount the expected payoff
P_CI = P_CI.*mkt.OIS(8);

end
