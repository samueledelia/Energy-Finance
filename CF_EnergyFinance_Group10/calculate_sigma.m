function Sigma_hat = calculate_sigma(sigma_1, sigma_2, beta)

% function used to compute the sigma_hat of HJM model, starting from 
% sigma1 and sigma2 ( HJM model parameters) and with the addition of the 
% beta we added in point 6.

    maturities = size(sigma_1,1); 
    tn = maturities;
    strikes = size(beta,1); 
    l = strikes;
    Sigma_hat = zeros(tn,l,size(sigma_1,2));
    for i = 1:size(sigma_1,2)
        j = nnz(sigma_1(:,i)); k = nnz(sigma_2(:,i)); s = nnz(beta(:,i));
        Sigma_hat(:,:,i) = sqrt( ...
            repelem(sigma_1(1:j,i),tn/j,1).^2 + ...
            repelem(sigma_2(1:k,i),tn/k,1).^2 ) ...
            *repelem(beta(1:s,i),l/s,1)';
    end
end