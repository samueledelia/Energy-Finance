function plot_vol_3d( Name , tau_2, tau_1, strikes, mkt_vols, Model_vols, ERROR_VOLS)
% Plots Model and Market Prices in a 3d plane

figure
set(gcf, 'Color', 'w', 'Name', Name, 'NumberTitle', 'off')
surf(tau_2-tau_1,strikes,mkt_vols,'FaceColor',[0 0.4470 0.7410], 'FaceAlpha', 0.8)
colormap sky

hold on
surf(tau_2-tau_1,strikes,Model_vols,'FaceColor',[0.8500 0.3250 0.0980], 'FaceAlpha', 0.5)
colormap sky;

t = text(0.4, strikes(2), 2.5, ['\bf Total Error : ', num2str(ERROR_VOLS)]);      
t.FontSize = 13;

legend('Market vols', 'Calibrated HJM vols', 'Location', 'northeast')
xlabel('Time to Maturity')
ylabel('Strike : K')
zlabel('volatility')
title('Market Vol VS Model Vol')
view(90,0)
rotate3d on;

x0=400;
y0=100;
width=800;
height=600;
set(gcf,'position',[x0,y0,width,height])

end