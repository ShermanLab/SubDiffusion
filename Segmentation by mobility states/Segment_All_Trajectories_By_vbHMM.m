function [ All_Segments_X, All_Segments_Y, All_Segments_Frames, All_Segments_Intensity,All_Segments_Sigma, All_Segments_Uncertainty, All_Transition_Matrix, All_Segments_Parent,All_Segments_Cell,mobility] = ...
    Segment_All_Trajectories_By_vbHMM( X, Y, mobility,states_num, min_segment_length, Frames, Intensity, Sigma, Uncertainty, Cells )
% SEGMENT_ALL_TRAJECTORIES_BY_VBHMM segments all the given trajectories in 
% the cell arrays X and Y by the mobility results given by the vbSPT
% algorithm. The Wbest.est2.viterbi variable holds information on the
% mobility state of each time step in the trajectory.
% See Persson et.al. 2013 for further details on vbSPT. 
%
% This function is very similar to the Segment_All_Trajectories function
% which uses the CER method for segmentation.
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

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

% Run over all trajectories in the population
for i=1:numel(X)
    x= X{i}*1e9;
    y= Y{i}*1e9;
    
    % Fill in the first frame which is left out in vbSPT
    mobility{i} = [mobility{i}(1); mobility{i}];
    % Retrieve the segments with different mobilities into new cell arrays
    [Segments_X, Segments_Y, ...
        Segments_Frames, Segments_Intensity, Segments_Sigma, Segments_Uncertainty, ...
        Transition_Matrix] = ...
        Split_Mobility_Multi( x, y, mobility{i} ,Frames{i},Intensity{i},Sigma{i},Uncertainty{i},states_num);
    
    % Keep only the ones with enough frames
    for s = 1:states_num
        if ~isempty(Segments_X{s})
            long_segments = cellfun('length',Segments_X{s})>=min_segment_length;
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
    for i =1:states_num.^2
        All_Transition_Matrix{i} =[All_Transition_Matrix{i} ;Transition_Matrix{i}];
    end
end

end

