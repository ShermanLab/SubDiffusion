function [beta,resnorm,residual,exitflag,output,lambda,jacobian] = ...
    lsqcurvemultifit(x_cell, y_cell, mdl_cell, X0, lb, ub, options)
% LSQCURVEMULTIFIT solves non-linear least squares problems for multiple
% data sets
%   A wrapper function for lsqcurvefit which allows simulatenous fitting of
%	multiple data sets with shared fitting parameters.
%   
%   Based on Chen Avinadav's function nlinmultifit which uses the nlinfit 
%   method. This function uses the lsqcurvefit method which allows
%   constraints on the fitted parameters.
%
%	INPUT:
% 		x_cell,y_cell: Cell arrays containing the x,y vectors of the fitted
%					   data sets.
% 		mdl_cell: Cell array containing model functions for each data set.
% 		X0: Vector containing initial guess of the fitted parameters.
% 		options: Structure containing control parameters for lsqcurvefit. 
%       (see help file on lsqcurvefit for more details).
%       lb, ub: Arrays of lower and upper bounds for the fitted parameters.
%       Defaults are -inf and inf.
%       
%	OUTPUT:
%		beta,resnorm,residual,exitflag,output,lambda,jacobian: Direct output 
%       from lsqcurvefit.
%

% Author: Yonatan Golan 2016, Based on Chen Avinadav's function nlinmultifit.

    % Initialize lower bounds and upper bounds
    if ~exist('lb')
        lb = -inf*ones(size(X0));
    end
    if ~exist('ub')
        ub = inf*ones(size(X0));
    end

    % Check validity of input data
	num_curves = length(x_cell);
	if length(y_cell) ~= num_curves || length(mdl_cell) ~= num_curves
		error('Invalid input to lsqcurvemultifit');
    end
	
    % Initialize x and y vectors which will contain all of the x's and y's
    % concatenated
	x_vec = [];
	y_vec = [];
    % Initialize model vector
	mdl_vec = '@(beta,x) [';
	mdl_ind1 = 1;
	mdl_ind2 = 0;
    
    % Go over all curves in the x and y cells
	for ii = 1:num_curves
		if length(x_cell{ii}) ~= length(y_cell{ii})
			error('Invalid input to lsqcurvemultifit');
		end
		if size(x_cell{ii},2) == 1
			x_cell{ii} = x_cell{ii}';
		end
		if size(y_cell{ii},2) == 1
			y_cell{ii} = y_cell{ii}';
        end
        
        % Concatenate x's and y's
		x_vec = [x_vec, x_cell{ii}];
		y_vec = [y_vec, y_cell{ii}];
        
        % Concatenate model vector
		mdl_ind2 = mdl_ind2 + length(x_cell{ii});
		mdl_vec = [mdl_vec, sprintf('mdl_cell{%d}(beta,x(%d:%d)), ', ii, mdl_ind1, mdl_ind2)];
		mdl_ind1 = mdl_ind1 + length(x_cell{ii});
	end
	mdl_vec = [mdl_vec(1:end-2), '];'];
	mdl_vec = eval(mdl_vec);

    % Perform least square curve fitting for the whole concatenated vectors
    if nargin < 7
        [beta,resnorm,residual,exitflag,output,lambda,jacobian] = ...
            lsqcurvefit(mdl_vec,X0,x_vec,y_vec,lb,ub);
	else
		[beta,resnorm,residual,exitflag,output,lambda,jacobian] = ...
            lsqcurvefit(mdl_vec,X0,x_vec,y_vec,lb,ub,options);
    end
end
