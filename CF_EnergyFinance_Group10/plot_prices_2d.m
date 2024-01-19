function plot_prices_2d(Name, tn, strikes, Market_prices, Model_prices, ERROR_PRICES)

% Plots Model and Market Prices in a 2d plane

figure
set(gcf, 'Color', 'w', 'Name', Name, 'NumberTitle', 'off')

for j=1:tn
    hold on
    p(j) = plot(strikes, Market_prices(:,j), 'color', 'b', 'Linewidth', 1);
end
for j=1:tn
    hold on
    p(j+tn) = plot(strikes, Model_prices(:,j), 'color', 'r', 'Linewidth', 1);
end

% display absolute errors on graph
t = text(strikes(2), 180, ['\bf Total Error : ', num2str(ERROR_PRICES)]);             % total error
t.FontSize = 13;

legend([p(1), p(tn+1)], 'Market Prices', 'Calibrated HJM Prices')
xlabel('Strike : K')
ylabel('Prices')
title('Market Prices VS Model Prices')

x0=400;
y0=100;
width=800;
height=600;
set(gcf,'position',[x0,y0,width,height])

end