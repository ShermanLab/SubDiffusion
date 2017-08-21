function [ Segments_X, Segments_Y, Segments_Frames, Segments_Intensity, Segments_Sigma, Segments_Uncertainty,Transition_Matrix] = ...
    Split_Mobility_Multi( x, y, mobile ,frames,intensity,sigma,uncertainty,states_num)
% Split_Mobility_Multi returns segments of a given trajectory by their
% mobility states as defined by the mobility vector 'mobile'. 'mobile' is
% an array defining the mobility state at each point. The values are
% integers from 1 to N where N is the number of possible states.
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

    % Initialize outputs    
    Segments_X = cell(states_num,1);
    Segments_Y = cell(states_num,1);
    Segments_Frames = cell(states_num,1);
    Segments_Intensity = cell(states_num,1);
    Segments_Sigma = cell(states_num,1);
    Segments_Uncertainty = cell(states_num,1);
    Transition_Matrix = cell(states_num);

    % Find the location of each state
    state_idx = [0 ;find(diff(mobile)~=0)]+1;
    
    % Find the lengths of each part with a persistive type of motion
    segment_lengths = diff([state_idx-1;length(mobile)]);
     
    % Find the mobility state at each segment
    states = mobile(cumsum(segment_lengths));
    
    % run over all states and collect the data
    for i=1:numel(states)
        Segments_X{states(i)}{end+1} = x(state_idx(i):state_idx(i)+segment_lengths(i)-1);
        Segments_Y{states(i)}{end+1} = y(state_idx(i):state_idx(i)+segment_lengths(i)-1);
        Segments_Frames{states(i)}{end+1} = frames(state_idx(i):state_idx(i)+segment_lengths(i)-1);
        Segments_Intensity{states(i)}{end+1} = intensity(state_idx(i):state_idx(i)+segment_lengths(i)-1);
        Segments_Sigma{states(i)}{end+1} = sigma(state_idx(i):state_idx(i)+segment_lengths(i)-1);            
        Segments_Uncertainty{states(i)}{end+1} = uncertainty(state_idx(i):state_idx(i)+segment_lengths(i)-1);            
    end 
    
    % Compute transitions
    % Same state
    for i=1:states_num
        Transition_Matrix{i,i} = segment_lengths(states==i)-1;
    end
    
    % Between states (Only if states_num is 3)
    if states_num == 3
        state_transitions = diff(states.^2);
        state_matrix = [0 -3 -8;
                        3  0 -5;
                        8  5  0];
        for i =  [find(~eye(states_num))]'
            Transition_Matrix{i} = sum(state_transitions==state_matrix(i));    
        end
    end
end

