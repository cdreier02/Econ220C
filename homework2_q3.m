%%%%%%%%%%%%%%%%%%%%%
%%% Homework 2 Q3 %%%
%%%%%%%%%%%%%%%%%%%%%

clear;
close all;
N = 100;
T = 3;
nreplic = 1000;
rho0 = 0.5;


NT=N*T;
 

% keep the bias of each estimator
bias_fe=zeros(11,1);
bias_fd=zeros(11,1);
bias_ah2=zeros(11,1);  
bias_pols=zeros(11,1);  


% keep the se of each estimator
se_fe = zeros(11,1);
se_fd = zeros(11,1);
se_ah2 = zeros(11,1);
se_pols = zeros(11,1);

% keep the rmse of each estimator
rmse_fe = zeros(11,1);
rmse_fd = zeros(11,1);
rmse_ah2 = zeros(11,1);
rmse_pols = zeros(11,1);


rho = (0:0.1:1)'; %the values of rho considered

for irho = 1:1:11;  % loop over each value of rho's

  a = [1 -rho(irho)];
  b = 1;  % configure a and b to speed up the data generating

  rho_fe = zeros(nreplic,1);  % keep the fixed effects estimator
  rho_fd = zeros(nreplic,1);
  rho_ah2 = zeros(nreplic,1);
  rho_pols = zeros(nreplic,1);
  
  t_fe = zeros(nreplic,1); % keep the t statistic based on the fe estimator
  t_fd = zeros(nreplic,1);
  t_ah2 = zeros(nreplic,1);
  t_pols = zeros(nreplic,1);
  

% initialize the random number generator

   for replic = 1:1:nreplic; 
    
		alpha = randn(1,N);  
		e = randn(1,N);
		y0 = rho0*alpha+e; 
		
        
		temp = [y0; randn(T,N)+alpha(ones(T,1),:)];
		data  =  filter(b,a, temp);   
		x = data(1:end-1,:);
		y = data(2:end,:);
          
		% data in wide format
          
		clear temp data;
        xx = x(:); % vectorize x' ?    
        yy = y(:); % vectorize y'
        
        %%%%%%%%%%%%% pooled OLS estimate  %%%%%%%%%%%%%%%%%
        rho_pols(replic) = xx\yy;
        
        err_pols = y-x*rho_pols(replic);
        
        avar_pols = sum(err_pols.^2, 'all') ./ (NT - 2);
        
%         
%         
%         for ii=1:1:N; 
%             index = ((ii-1)*T+1: ii*T)';
%             avar_pols = avar_pols + x_fe(index)'*err_pols(index)*err_pols(index)'*x_fe(index);
%         end;
%         
%         avar_fe = inv(x_fe(:)'*x_fe(:))*avar_fe*inv(x_fe(:)'*x_fe(:));

        t_pols(replic) = rho_pols(replic)./sqrt(avar_pols);

      
			
		%%%%%%%%%%%%% FE estimator %%%%%%%%%%%%%%%%%
		x_fe = x-repmat(mean(x),T,1);
		y_fe = y-repmat(mean(y),T,1);
		rho_fe(replic) = x_fe(:)\y_fe(:);
        
        
        err_fe = y_fe(:)-x_fe(:)*rho_fe(replic); % regression error
            
        
        avar_fe = 0;
        
        for ii=1:1:N; 
            index = ((ii-1)*T+1: ii*T)';
            avar_fe = avar_fe + x_fe(index)'*err_fe(index)*err_fe(index)'*x_fe(index);
        end;
        
        avar_fe = inv(x_fe(:)'*x_fe(:))*avar_fe*inv(x_fe(:)'*x_fe(:));
        
        t_fe(replic) = (rho_fe(replic)-rho(irho))/sqrt(avar_fe);
		

		
		%%%%%%%%%%%%% FD estimator %%%%%%%%%%%%%%%%%

        
        x_fd = x(2:end,:)-x(1:end-1,:);
		y_fd = y(2:end,:)-y(1:end-1,:);
        
        
		z = reshape(x(1:end-1,:),[],1);


        rho_fd(replic) = y_fd(:)'/x_fd(:)';
        err_fd = y_fd(:)-x_fd(:)*rho_fd(replic); 
        
        avar_fd = 0;
        
        for ii=1:1:N; 
            index = ((ii-1)*(T-1)+1: ii*(T-1))';
            avar_fd = avar_fd + x_fd(index)'*err_fd(index)*err_fd(index)'*x_fd(index);
        end;
        
        avar_fd = inv(x_fd(:)'*x_fd(:))*avar_fd*inv(x_fd(:)'*x_fd(:));
        
        t_fd(replic) = (rho_fd(replic)-rho(irho))/sqrt(avar_fd);

        		
		%%%%%%%%%%%%% AH2 estimator %%%%%%%%%%%%%%%%%
        
        x_ah2 = x(2:end,:)-x(1:end-1,:);
		y_ah2 = y(2:end,:)-y(1:end-1,:);
        
        z = reshape(x(1:end-1,:),[],1);
        
        
		rho_ah2(replic) = (z'*y_ah2(:))/(z'*x_ah2(:));
        
        err_ah2 = y_ah2(:)-x_ah2(:)*rho_ah2(replic); 
        
        avar_ah2 = 0;
        
        for ii=1:1:N; 
            index = ((ii-1)*(T-2)+1: ii*(T-2))';
            avar_ah2 = avar_ah2 + x_ah2(index)'*err_ah2(index)*err_ah2(index)'*x_ah2(index);
        end;
        
        sigmahat_ah2 = sum(err_ah2.^2, 'all'); 
        
        avar_ah2 = inv(z'*x_ah2(:)*inv(x_ah2(:)'*x_ah2(:))*x_ah2(:)'*z(:));
        
        t_ah2(replic) = (rho_ah2(replic)-rho(irho))/sqrt(avar_ah2);
        
        
   end
%%
bias_fe(irho)  =  mean(rho_fe)-rho(irho);
bias_fd(irho)  =  mean(rho_fd)-rho(irho);
bias_ah2(irho)  =  mean(rho_ah2)-rho(irho);
bias_pols(irho)  =  mean(rho_pols)-rho(irho);


se_fe(irho)  =  std(rho_fe);
se_fd(irho)  =  std(rho_fd);
se_ah2(irho)  =  std(rho_ah2);
se_pols(irho)  =  std(rho_pols);

rmse_fe(irho)  =  sqrt(se_fe(irho)^2+bias_fe(irho)^2);
rmse_fd(irho)  =  sqrt(se_fd(irho)^2+bias_fd(irho)^2);
rmse_ah2(irho)  =  sqrt(se_ah2(irho)^2+bias_ah2(irho)^2);
rmse_pols(irho)  =  sqrt(se_pols(irho)^2+bias_pols(irho)^2);
	
	if rho(irho) == 0.7;
		figure(1);
        histfit(rho_fe);
		%[freq, bins]= hist(rho_fe);
        %bar(bins, freq/sum(freq));
        %hold on;
        %x=(-2.5:0.1:2.5)';
        %plot(x, normpdf(x,0,1));
		title({'Histogram of the \rho_{FE} estimator'; ['\rho = ' num2str(0.7) ', N = ' num2str(N) ', T = ' num2str(T)]});
   
        orient landscape;
        print('-depsc2', ['histogram' '_N_' num2str(N) '_T_' num2str(T) '.eps'])
        saveas(gcf, 'FE3.png')
        %hold off;
        
        
        figure(2);
       
        histfit(rho_fd);
		%[freq, bins]= hist(rho_fd);
        %bar(bins, freq/sum(freq));
        %hold on;
        %x=(-2.5:0.1:2.5)';
        %plot(x, normpdf(x,0,1));
		title({'Histogram of the \rho_{FD} estimator'; ['\rho = ' num2str(0.7) ', N = ' num2str(N) ', T = ' num2str(T)]});
   
        orient landscape;
        print('-depsc2', ['histogram' '_N_' num2str(N) '_T_' num2str(T) '.eps'])
        saveas(gcf, 'FD3.png')
        %hold off;
        
       
        figure(3);
        histfit(rho_ah2);
		%[freq, bins]= hist(rho_ah2);
        %bar(bins, freq/sum(freq));
        %hold on;
        %x=(-2.5:0.1:2.5)';
        %plot(x, normpdf(x,0,1));
		title({'Histogram of the \rho_{ah2} estimator'; ['\rho = ' num2str(0.7) ', N = ' num2str(N) ', T = ' num2str(T)]});
   
        orient landscape;
        print('-depsc2', ['histogram' '_N_' num2str(N) '_T_' num2str(T) '.eps'])
        %hold off;
        saveas(gcf, 'AH3.png')
        
        figure(4);
        histfit(rho_pols);
		%[freq, bins]= hist(rho_pols);
        %bar(bins, freq/sum(freq));
        %hold on;
        %x=(-2.5:0.1:2.5)';
        %plot(x, normpdf(x,0,1));
		title({'Histogram of the \rho_{pols} estimator'; ['\rho = ' num2str(0.7) ', N = ' num2str(N) ', T = ' num2str(T)]});
   
        orient landscape;
        print('-depsc2', ['histogram' '_N_' num2str(N) '_T_' num2str(T) '.eps'])
        %hold off;
        saveas(gcf, 'POLS3.png')

        
    end;
     

end;

figure(100)

H1 = plot(rho, bias_fe, 'k+:',...
     rho, bias_fd,  'bo-',...
     rho, bias_ah2,  'rs-.',...
     rho, bias_pols, 'go-');
H2= legend('fe','fd','ah2', 'pols', 'location', 'Southwest');
title(['Bias of Different Estimators,' ' N = ' num2str(N) ', T = ' num2str(T)]);
xlabel ('\rho'); 
ylabel ('bias');
set(H1, 'linewidth', 2,'markersize', 4);
set(H2, 'fontsize', 12)
saveas(gcf, 'bias3.png')

orient landscape;
print('-depsc2', ['bias_se_rmse' '_N_' num2str(N) '_T_' num2str(T) '.eps'])

        %'Need to draw the graphs for other estimators'
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %                                                       %
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
      
