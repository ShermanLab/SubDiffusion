function [ mobile ,maxdist] = ...
    Track_Mobility_by_CER(x, y, windowsize, d_thresh, min_segment_length)
% mobile = Track_Mobility_by_CER(x,y) returns a logical vector indicating 
% the times in which the trajectory is mobile or not. The function uses a 
% sliding window over the trajectory and for each one finds the maximum 
% distance traveled by the particle in the given window time.
% 
% windowsize determines the window size to look at.
% d_thresh is the distance threshold for mobility.
% min_segment_length is the minimal length allowed for a segment
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

    % Assign default values
    if nargin<5
        min_segment_length = 10;
    end
      
    if nargin<4
        % Distance threshold to consider as mobile (nm).
        d_thresh = 125;
    end
    
    if nargin < 3
        % Window size - how many points to check
        windowsize = 8;
    end

    % Construct the sliding window matrix. Using the Hankel function it
    % will look like:
    % 1 2 3 4 5
    % 2 3 4 5 6
    % 3 4 5 6 7
    % ...
    % Where the window size is 5 in this example
    l = length(x);
    m = l-windowsize+1;
    sliding_windows = hankel(1:m,m:l);
    
    % Initialize the stationary array which is 1 for each point designated
    % as stationary and 0 as mobile.
    Stationary = zeros(numel(x),2);
    
    % Run twice - forward and backward
    for i = 1:2
        % take the x and y values corresponding to the sliding windows indices
        xmat = x(sliding_windows);
        ymat = y(sliding_windows);
        
        % Subtract from each point in the trajectory the first point in the
        % corresponding time window. This will give us the distance each
        % point traveled from the begining of the time window.
        xmat = xmat - repmat(xmat(:,1),1,windowsize);
        ymat = ymat - repmat(ymat(:,1),1,windowsize);
        
        % Calculate the distance traveled
        dist = sqrt(xmat.^2 + ymat.^2);
        
        % Find the maximal distance each point traveled in the time window
        maxdist = max(dist,[],2);              
        
        % Mark as stationary if the traveled distance is less than d_thresh.
        Stationary(1:length(maxdist),i) = maxdist<=d_thresh;
        
        % Flip the trajectory in order to start again backwards.
        x = flipud(x);
        y = flipud(y);
    end
    
    % Flip the backward measurement
    Stationary(:,2) = flipud(Stationary(:,2));
    
    % Define as mobile whatever is mobile in both directions
    mobile = and(~Stationary(:,1),~Stationary(:,2));
    
    % Eliminate singular events. 
    mobile = Eliminate_singular_events(mobile, min_segment_length-1);
end

