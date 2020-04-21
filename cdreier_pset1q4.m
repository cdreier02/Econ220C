clear;
clc;
N = 500;
T = 10;
nreplic = 1000;
rng(1234);
beta_hat = zeros(nreplic,1);
sigma_hat =  zeros(nreplic,1);
sigma_tilde =  zeros(nreplic,1);

for replic = 1:1:nreplic;
    
    x = randn(T,N);
    u = abs(x).*randn(T,N);
    y = 300*x + u;
    
    
    ydm = y - repmat(mean(y),T,1);
    xdm = x - repmat(mean(x),T,1);
    udm = u - repmat(mean(u),T,1);
    test = repmat(mean(y),T,1);
    
    xdmp = xdm';
    ydmp = ydm';
     
    ydmv = ydmp(:);
    xdmv = xdmp(:);
    udmv = udm(:);
    xpy = xdm'*ydm;
    xpx = xdm'*xdm;  

    
    beta_hat(replic) = xdmv\ydmv;  %fixed effects estimator
    u_hat = ydm - xdm*beta_hat(replic);  % residual from fixed effect regression
                               
  
    sxx = sum(xdm.^2, 'all') ;
    sigma_hat(replic) =sqrt(sxx^(-2)*sum(sum(xdm.*(u_hat)).^2));
    sigma_tilde(replic) = sqrt(sxx^(-2)*sum(sum(xdm.^2.*(u_hat.^2))));
end
mean_hat = mean(sigma_hat);
mean_tilde = mean(sigma_tilde);

%[std(beta_hat) mean(sigma_beta1) mean(sigma_tilde) std(sigma_beta1), std(sigma_tilde)...
   % sqrt((mean(sigma_hat)-std(beta_hat))^2 +std(sigma_hat)^2), sqrt((mean(sigma_tilde)-std(beta_hat))^2 +std(sigma_tilde)^2)   ]

mean_beta_hat = mean(beta_hat);   
std_beta_hat = std(beta_hat);
hat_bias =  mean_hat - std_beta_hat;
hat_std = std(sigma_hat);
hat_rmse = sqrt((mean_hat - std_beta_hat)^2 + hat_std)^2;
tilde_bias = mean_tilde - std_beta_hat;
tilde_std = std(sigma_tilde);
tilde_rmse =  sqrt((mean_tilde-std_beta_hat)^2 +tilde_std^2);

    

