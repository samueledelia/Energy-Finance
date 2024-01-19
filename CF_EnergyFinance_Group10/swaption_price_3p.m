function price = swaption_price_3p(t0,T,K,f,r,sigma_1,sigma_2,beta, tenors, n)

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
tenors = cat(1,0, tenors);
sig_1 = 0;
sig_2 = 0;
if length(sigma_1)==1
    sig_1 = sigma_1^2*(T-t0);
else
for i = 1:n
sig_1 = sig_1 + sigma_1(i)^2*(tenors(i+1)-tenors(i));
end
end

if length(sigma_2)==1
    sig_2 = sigma_2^2*(T-t0);
else
for i = 1:n
sig_2 = sig_2 + sigma_2(i)^2*(tenors(i+1)-tenors(i));
end
end

sigma_hat = sqrt((sig_1+sig_2))*beta;
sigma_t =  sigma_hat;
d2=(log(f/K)-0.5*sigma_t^2)/sigma_t;
d1=d2+sigma_t;

price = exp(-r*(T-t0))*(f*normcdf(d1)-K*normcdf(d2));

end