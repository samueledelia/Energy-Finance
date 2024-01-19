function ninput = plot_volatilities(Name, tau_2, tau_1, strikes, varargin)

% Input varargin as -> surf1, surf2, ... , name1, name2

ninput = (nargin-4)/2;
colors = jet(3+ninput);
Legend = cell(ninput,1);

figure
set(gcf, 'Color', 'w', 'Name', Name, 'NumberTitle', 'off')
for i=1:ninput
    surf(tau_2-tau_1,strikes,varargin{i}','FaceAlpha', 0.8, ...
        'FaceColor',colors(1+i,:))
    Legend{i}=varargin{i+ninput};
    hold on
end

legend(Legend, 'Location', 'northeast')

xlabel('Time to Maturity')
ylabel('Strike : K')
zlabel('Volatility')
title('Volatility Surface')
view(90,0)
rotate3d on;

x0=400;
y0=100;
width=800;
height=600;
set(gcf,'position',[x0,y0,width,height])

end