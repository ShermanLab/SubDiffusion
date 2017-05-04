function [ All_Segments_X, All_Segments_Y, All_Segments_Frames, All_Segments_Intensity, All_Segments_Sigma, All_Segments_Uncertainty, All_Transition_Matrix, All_Segments_Parent,All_Segments_Cell, mobility_cell ] = ...
    Segment_All_Trajectories( X, Y, windowsize, d_thresh, min_segment_length, Frames, Intensity, Sigma, Uncertainty, Cells )
% SEGMENT_ALL_TRAJECTORIES segments all the given trajectories in the cell
% arrays X and Y by the criterions given in windowsize and d_thresh and
% returns cell arrays containing the segmented parts of all the
% trajectories. The algorithm used is the Cummulative Escape Radius (CER)
% which tests for each time step if the particle escaped from a given
% distance threshold at a given time window.
%
% Each cell in X and Y contains a list of coordinates of a single particle.
% windowsize and d_thresh are arrays with (s-1) elements where s is the
% number of expected mobility states.
% min_segment_length is the minimal number of time points in a resultant
% segment to be considered as legal. Otherwise the segment is dumped.
%
% The function recieves as an input also all of the raw data correcponding
% to each SMLM localization data: movie frame number, localization
% intensity, localization Gaussian width, localization uncertainty and
% which cell the trajectory belongs to. Currently, this is quite rigid and
% should be changed for easier usage of the function. One can either
% introduce null or otherwise degenerate data, or remove the need for it
% altogether.
%
% The function returns cell arrays with the resulting mobility states, each
% with a different measured parameter. This is somewhat cumbersome and
% could have been written more elegantly, but nontheless works well,
% especially as an ad-hoc purpose.
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

% The number of mobility states
states_num = size(windowsize,1)+1;

% Initialize final cell arrays
All_Segments_X = cell(states_num,1);
All_Segments_Y = cell(states_num,1);
All_Segments_Frames = cell(states_num,1);
All_Segments_Intensity = cell(states_num,1);
All_Segments_Sigma = cell(states_num,1);
All_Segments_Uncertainty = cell(states_num,1);
All_Transition_Matrix = cell(states_num);
All_Segments_Parent = cell(states_num,1);
All_Segments_Cell = cell(states_num,1);
mobility_cell = cell(numel(X),1);

% Run over all trajectories in the population
for i=1:numel(X)
    
    % Translate the coordinates to nm from meters.
    x= X{i}*1e9;
    y= Y{i}*1e9;
    
    % Initialize the mobility array
    mobility = zeros(length(x),states_num-1);
    
    % For each mobility state, populate the mobility array with 0's and 1's
    for s = 1:states_num-1
        mobility(:,s) = Track_Mobility_by_CER(x,y,windowsize(s),d_thresh(s),2);
    end
    
    % Sum up mobility to divide into the different states
    mobility = sum(mobility,2)+1;
    mobility_cell{i} = mobility;
    
    % Retrieve the segments with different mobilities into new cell arrays
    [Segments_X, Segments_Y, Segments_Frames, Segments_Intensity, Segments_Sigma, Segments_Uncertainty, Transition_Matrix] = ...
        Split_Mobility_Multi( x, y, mobility ,Frames{i},Intensity{i},Sigma{i},Uncertainty{i},states_num);
    
    % Keep only the ones with enough frames
    for s = 1:states_num
        if ~isempty(Segments_X{s})
            % Find which segments are long enough
            long_segments = cellfun('length',Segments_X{s})>=min_segment_length;
            
            % Save data of long enough segments
            All_Segments_X{s} = [All_Segments_X{s} , Segments_X{s}(long_segments)];
            All_Segments_Y{s} = [All_Segments_Y{s} , Segments_Y{s}(long_segments)];
            All_Segments_Frames{s} = [All_Segments_Frames{s} , Segments_Frames{s}(long_segments)];            
            All_Segments_Intensity{s} = [All_Segments_Intensity{s} , Segments_Intensity{s}(long_segments)];  
            All_Segments_Sigma{s} = [All_Segments_Sigma{s} , Segments_Sigma{s}(long_segments)];
            All_Segments_Uncertainty{s} = [All_Segments_Uncertainty{s} , Segments_Uncertainty{s}(long_segments)];
            All_Segments_Parent{s} = [All_Segments_Parent{s} , i*ones(1,sum(long_segments>0))];
            All_Segments_Cell{s} = [All_Segments_Cell{s}, Cells(i)*ones(1,sum(long_segments>0))];
        end
    end
    
    % Record data of transitions from one state to another
    for j =1:states_num^2
        All_Transition_Matrix{j} =[All_Transition_Matrix{j} ;Transition_Matrix{j}];
    end
end

end

