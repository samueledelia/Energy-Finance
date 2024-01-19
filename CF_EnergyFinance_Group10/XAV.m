function [X,X_AV] = XAV(Nsim, T, Ndates, fwd, tau_1, tau_2, sigma_1, sigma_2, beta)

% Simulates the dynamics of the underlying forward price.
% Correlation between the pairs of paths = -2 < 0 for AV.
%
% INPUT:
%
% Nsim = Number of simulations
% T = TTM
% Ndates = Number of monitoring dates
% fwd = Forward in t0
% tau_1 = initial date
% tau_2 = vector with all the tenors
% sigma_1, sigma_2, beta = HJM parameters
% 
% OUTPUT: 
% X, X_AV : matrices with the MC paths simulated
dt = T/Ndates;

X = zeros(Nsim, Ndates+1);
X_AV = zeros(Nsim, Ndates+1);
X(:,1) = fwd; 
X_AV(:,1) = fwd;
t = linspace(0, T, Ndates+1);

for j = 1:Nsim
    tenor_1 = size(sigma_1,1); % useful to start from the last sigma
    tenor_2 = size(sigma_2,1);
    for i = 1:Ndates
        tenor_1 = iterate_tenor(i, tenor_1, t, tau_1, tau_2);
        tenor_2 = iterate_tenor(i, tenor_2, t, tau_1, tau_2);
        % sampling two normal gaussians
        Z_1 = randn;            
        Z_2 = randn;
        X(j,i+1) = X(j,i) ...
                   + (sqrt(dt)*sigma_1(tenor_1)*Z_1 ... 
                   + sqrt(dt)*sigma_2(tenor_2)*Z_2)*beta *X(j,i);
        X_AV(j,i+1) = X_AV(j,i) ...
                   - (sqrt(dt)*sigma_1(tenor_1)*Z_1 ... 
                   - sqrt(dt)*sigma_2(tenor_2)*Z_2) *beta*X_AV(j,i);
    end
end

end