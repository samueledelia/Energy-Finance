function B_i = interpol(T0,dates, discounts,date_i)
% intepolates the discount for a date_i, given the discounts at previous
% dates.
%
% INPUT:
% T0 = settlement date
% dates, discounts = pairs of discount factor and their date
% date_i = date from whitch we want the discount
%
% OUTPUT:
% B_i = disocunt w.r. to the date_i

delta = yearfrac(T0*ones(length(dates),1),dates,3);
zero_rates = -log(discounts)./delta;

if dates(end) < date_i
    Zero_rate_i = interp1([T0; dates], [0; zero_rates], date_i,'linear', zero_rates(end));
end
if dates(end) >= date_i
    Zero_rate_i = interp1([T0; dates], [0; zero_rates], date_i,'linear');
end

B_i = exp(-Zero_rate_i.*yearfrac(T0, date_i, 3));
end