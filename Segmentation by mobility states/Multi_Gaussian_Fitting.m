function [ Sigmas, Amplitudes, FitParams ] = Multi_Gaussian_Fitting(Dataset_X, Dataset_Y, GN , Initial_guess)
%MULTI_GAUSSIAN_FITTING fits two or three guassians to multiple data sets.
% All fits share the same sigmas and differ in amplitude only.
% 
% Datasets X and Y are nXm cell array where n is the number of realizations
% in the dataset and m is the number of sub group the initial population
% was segmented into. X and Y are the x and y axes
% For example, if and initial population of step sizes was segmented into 3
% sub groups (low, mid, high) by 10 different segmentation procedures then
% the dataset will be a 10X3 cell array. Each row of the cell array is 1
% realization of a segmentation process.
% 
% GN is the number of gaussians to be fitted to each sub group. 
% Sigmas is a vector the length of GN with the values of the sigmas of the
% gaussians fitted.
% Amplitudes is a (m X GN X n) array where each (m X GN) sheet hold the
% amplitudes of the fitted GN gaussians for each sub group.
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

    %% Initialize parameters
    % Numer of realizations and sub groups
    [n,groups] = size(Dataset_X);    
    
    % Initial guess and lower and upper bounds
    % (Initial guess in input is for the sigmas only. The initial guess fo
    % the amplitudes is 0.5. There are n*groups*(GN-1)) amplitudes for the
    % fit (the amplitude for the last gaussian is 1 minus all the rest so
    % there is one less degree of freedom).
    beta0 = [Initial_guess, 0.5*ones(1,n*groups*(GN-1))];    
    lb = [zeros(1,GN), zeros(1,n*groups*(GN-1))];
    ub = [inf(1,GN), ones(1,n*groups*(GN-1))];
    
    % Define fitting functions and parameters
    for i=1:n
        % Compute the normalization factors - the area under the curves
        for j=1:groups
            % Find the area under the graph for normalization
            curve_area = trapz(Dataset_X{i,j},Dataset_Y{i,j});
            
            % Define the function models
            if GN == 2 
                model{i+n*(j-1)} = @(beta,x)...
                         beta(2+(GN-1)*(i+n*(j-1)))*curve_area/sqrt(2*pi*beta(1)^2)*exp(-x.^2/(2*beta(1)^2))...
                    +(1-beta(2+(GN-1)*(i+n*(j-1))))*curve_area/sqrt(2*pi*beta(2)^2)*exp(-x.^2/(2*beta(2)^2));                        
            elseif GN == 3
                model{i+n*(j-1)} = @(beta,x)...
                         beta(2+(GN-1)*(i+n*(j-1)))*curve_area/sqrt(2*pi*beta(1)^2)*exp(-x.^2/(2*beta(1)^2))...
                     +   beta(3+(GN-1)*(i+n*(j-1)))*curve_area/sqrt(2*pi*beta(2)^2)*exp(-x.^2/(2*beta(2)^2))...
                     +(1-beta(2+(GN-1)*(i+n*(j-1)))-beta(3+(GN-1)*(i+n*(j-1))))*curve_area/sqrt(2*pi*beta(3)^2)*exp(-x.^2/(2*beta(3)^2));                        
            elseif GN == 4
                model{i+n*(j-1)} = @(beta,x)...
                         beta(2+(GN-1)*(i+n*(j-1)))*curve_area/sqrt(2*pi*beta(1)^2)*exp(-x.^2/(2*beta(1)^2))...
                     +   beta(3+(GN-1)*(i+n*(j-1)))*curve_area/sqrt(2*pi*beta(2)^2)*exp(-x.^2/(2*beta(2)^2))...
                     +   beta(4+(GN-1)*(i+n*(j-1)))*curve_area/sqrt(2*pi*beta(3)^2)*exp(-x.^2/(2*beta(3)^2))...
                     +(1-beta(2+(GN-1)*(i+n*(j-1)))-beta(3+(GN-1)*(i+n*(j-1)))-beta(4+(GN-1)*(i+n*(j-1))))*curve_area/sqrt(2*pi*beta(4)^2)*exp(-x.^2/(2*beta(4)^2));                        
            end                
        end
    end

    % Turn off display
    options= optimoptions(@lsqcurvefit,'display','off');

    % Run the multi fitting algorithm
    [beta,FitParams.resnorm,FitParams.residual,FitParams.exitflag,FitParams.output,FitParams.lambda,FitParams.jacobian] = ...
        lsqcurvemultifit(Dataset_X(:)', Dataset_Y(:)', model, beta0,lb,ub,options);

    % Assign sigmas and amplitudes. The sigmas are straight forward. The
    % amplitudes require some readout of the array where reshape is not
    % enough.
    Sigmas = beta(1:GN);
    Amplitudes = nan(groups,GN-1,n);

    for i = 1:n
        for j = 1:GN-1 
            for k = 1:groups
                Amplitudes(k,j,i) = beta(GN+j+(k-1)*n*(GN-1)+(i-1)*(GN-1));
            end
        end
    end
    Amplitudes(:,end+1,:) = 1-sum(Amplitudes,2);


end

