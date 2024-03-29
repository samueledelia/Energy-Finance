function [PARAMS,ERROR_PRICES] = calibrate_sigmas_HJM(Name, mkt, sizes, initial, bounds)

% Calibrate HJM two-factor Model
%
% INPUTS:
%   Name     = name displayed in the plots
%   mkt      = market data
%   sizes    = sizes of sigma_1, sigma_2 and beta
%   initial  = initial parameters for sigma_1, sigma_2 and beta
%   bounds   = lower bounds for both sigma_1 and sigma_2, 
%              lower bound for beta, 
%              upper bounds for both sigma_1 and sigma_2,
%              upper bound for beta
%
% OUTPUTS: 
%   PARAMS  = vector containing the sigmas and beta(s) calibrated
%   ERROR_PRICES = Mean Absolute Error between mkt prices and the prices
%                  obtained with the calibrated model
%
%% Get all the data needed 

sz1 = sizes(1); sz2 = sizes(2); szb = sizes(3);

% interpolating to find discounts for the needed dates 
mkt.DF = interpol(mkt.t0,mkt.dates, mkt.OIS,mkt.datesExpiry);

l = length(mkt.strikes); tn = length(mkt.tenors); s = l*tn; 

mkt_vols = mkt.volatilitySurface';
volatility_vector = mkt_vols(:);
strikes = mkt.strikes;

tau_2 = mkt.datesExpiry./252; % divided by 252 so that we work with years
tau_1 = mkt.t0/252;

fwd = mkt.fwd;
DF = mkt.DF;
r = -log(DF)./yearfrac(mkt.t0,tau_2.*252,3);  % zero rate

%% Initial parameters
% lower and upper bounds and starting points for the optimization
LB = cat(1, bounds(1)*ones(sz1+sz2,1), bounds(2)*ones(szb,1));
x0 = cat(1, initial(1)*ones(sz1,1), initial(2)*ones(sz2,1), initial(3)*ones(szb,1));
UB = cat(1, bounds(3)*ones(sz1+sz2,1), bounds(4)*ones(szb,1));

%% Calibration

% we define the 2 following functions to make sure that arrayfun used below 
% will depend only on one iteration variable (i) 

iter = @norm_iter_sz;
    function j = norm_iter_sz (i, sz) 
        % Distribute i iterations in a size sz array.
        % We get the next j after s/sz iterations of i.
        j = round((i-1)/(s/sz) + 0.5); 
    end

repeat = @repeat_iter_sz;
    function j = repeat_iter_sz(i, sz)
        % We restart from j = 1 after sz iterations of i.
        j = rem(i, sz);
        if j == 0
            j = sz;
        end
    end


opts = optimset('display','off'); % used to hide output of the lsqnonlin


% optimization by solving a non linear LS problem, minimizing the
% difference between the market price (computed using blk formula) and the
% model price (obtained with the "swaption_price_2p" function)
PARAMS = ...
    lsqnonlin(@(p) ...
        abs(arrayfun(@(i) ...
        blkprice(...
            fwd, ...
            strikes(repeat(i,l)), ...
            r(iter(i,tn)), ...
            (tau_2(iter(i,tn)) - tau_1), ...
            volatility_vector(i)) ...
        - swaption_price_2p(...
            tau_1, ...
            tau_2(iter(i,tn)), ...
            strikes(repeat(i,l)), ...
            fwd, ...
            r(iter(i,tn)), ...
            p(iter(i,sz1)), ...
            p(iter(i,sz2)+sz1), ...
            p(repeat(i,szb)+sz1+sz2)), ...
        [1:s]')), ...
        x0, LB, UB, opts);

%% Compute the calibrated model's prices and the error
% Now we find the model prices using the parameters just calibrated
model_prices = arrayfun(@(i)...
    swaption_price_2p(...
        tau_1,...
        tau_2(iter(i,tn)),...
        strikes(repeat(i,l)),...
        fwd,...
        r(iter(i,tn)), ...
        PARAMS(iter(i,sz1)), ...
        PARAMS(iter(i,sz2)+sz1), ...
        PARAMS(repeat(i,szb)+sz1+sz2)), ...
        [1:s]');
Model_prices = reshape(model_prices,l,tn);

% computing market prices using black model to get the error
mkt_prices = arrayfun(@(i)...
    blkprice(...
        fwd,...
        strikes(repeat(i,l)),...
        r(iter(i,tn)),...
        (tau_2(iter(i,tn)) - tau_1),...
        volatility_vector(i)), ...
        [1:s]');
Market_prices = reshape(mkt_prices,l,tn);

model_vols = arrayfun(@(i) ...
    blkimpv(...
        fwd, ...
        strikes(repeat(i, l)), ...
        r(iter(i, tn)), ...
        (tau_2(iter(i, tn)) - tau_1), ...
        model_prices(i)), ...
    [1:s]');
Model_vols = reshape(model_vols, l, tn);

% MEAN ABSOLUTE ERROR of the prices
ERROR_PRICES = sqrt(mean(abs(mkt_prices - model_prices).^2));
ERROR_VOLS = sqrt(mean(abs(volatility_vector - model_vols).^2));
%% Plot market prices VS model prices in 2D and 3D

plot_prices_2d(Name, tn, strikes, Market_prices, Model_prices, ERROR_PRICES)
plot_prices_3d(Name, tau_2, tau_1, strikes, Market_prices, Model_prices, ERROR_PRICES)

plot_vol_3d(Name , tau_2, tau_1, strikes, mkt_vols, Model_vols, ERROR_VOLS)
end