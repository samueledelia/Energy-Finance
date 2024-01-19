function plot_prices_3d(Name, tau_2, tau_1, strikes, Market_prices, Model_prices, ERROR_PRICES)

% Plots Model and Market Prices in a 3d plane

figure
set(gcf, 'Color', 'w', 'Name', Name, 'NumberTitle', 'off')
surf(tau_2-tau_1,strikes,Market_prices,'FaceColor','b', 'FaceAlpha', 0.8)
colormap summer

hold on
surf(tau_2-tau_1,strikes,Model_prices,'FaceColor','r', 'FaceAlpha', 0.5)
colormap winter;

t = text(0.4, strikes(2), 180, ['\bf Total Error : ', num2str(ERROR_PRICES)]);             % total error
t.FontSize = 13;

legend('Market Prices', 'Calibrated HJM Prices', 'Location', 'northeast')
xlabel('Time to Maturity')
ylabel('Strike : K')
zlabel('Prices')
title('Market Prices VS Model Prices')
view(90,0) % overlap the initial view with the 2D graph
rotate3d on;

x0=400;
y0=100;
width=800;
height=600;
set(gcf,'position',[x0,y0,width,height])

end