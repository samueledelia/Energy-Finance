function tenor = iterate_tenor(i, tenor, t, tau_1, tau_2)

% used to get the right tenor in the for loop inside the MC simulation

if (tenor~=1 && (tau_2(end)-(tau_1+t(i)) > tau_2(tenor-1)))
    tenor = tenor -1;
end