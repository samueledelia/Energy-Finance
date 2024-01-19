function price = swaption_price_2p(t0,T,K,f,r,sigma_1,sigma_2,beta)

% Compute the price of a swaption (call version) with HJM model 
% INPUTS: 
%   t0 = Initial date
%   T = End date
%   K = Strike
%   f = Forward in t0
%   r = risk free rate
%   sigma_1, sigma_2 and beta = HJM model parameters
% OUTPUTS:
%   price = SWAPTION PRICE
%
sigma_hat = sqrt((sigma_1^2+sigma_2^2))*beta;
sigma_t =  sigma_hat*sqrt(T-t0);
d2=(log(f/K)-0.5*sigma_t^2)/sigma_t;
d1=d2+sigma_t;

price = exp(-r*(T-t0))*(f*normcdf(d1)-K*normcdf(d2));

end