function mkt = import_data(print)

% Import data from the excel file given for the project
% INPUT:
% print: if true a summary of the struct will be displayed
% OUTPUT:
% mkt:                  struct composed by the following Field:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mkt.dates:            dates for the discounts factors
% mkt.OIS:              discounts factors
% mkt.strikes:          strikes for the options on the 4Q24 swaps
% mkt.tenors:           tenors for the options on the 4Q24 swpas
% mkt.F0:               Foward Price at time 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

formatData='dd/mm/yyyy';
mkt.t0 = datenum('04/11/2023', formatData); % energy market is open on saturday?? 

dates_cell = readcell('DataDEEEX.xlsx','Sheet','ois','Range','A1:T1');
dates = zeros(1,length(dates_cell));
for i=1:length(dates_cell)
    dates(i) = datenum(dates_cell{1,i});
end
mkt.dates = dates';
mkt.OIS = readmatrix('DataDEEEX.xlsx','Sheet','ois','Range','A2:T2')';
mkt.volatilitySurface = readmatrix('DataDEEEX.xlsx','Sheet','OptionsOnQ42024','Range','B2:V9');

mkt.strikes = readmatrix('DataDEEEX.xlsx','Sheet','OptionsOnQ42024','Range','B1:V1');
mkt.tenors = readmatrix('DataDEEEX.xlsx','Sheet','OptionsOnQ42024','Range','A2:A9');
mkt.fwd = readmatrix('DataDEEEX.xlsx', 'Sheet', 'F', 'Range', 'C8');
if (print == true)
    mkt.fwd = mkt.fwd(end) 
else
    mkt.fwd = mkt.fwd(end); 
end

mkt.datesStart = zeros(length(mkt.tenors),1);
mkt.datesStart = mkt.t0;
mkt.datesExpiry = mkt.t0 + round(252*mkt.tenors);

end
