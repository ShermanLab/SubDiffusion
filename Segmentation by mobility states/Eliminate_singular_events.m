function [ mobile ] = Eliminate_singular_events( mobile, event_length )
% ELIMINATE_SINGULAR_EVENTS finds singular events in the mobility vector
% 'mobile' and turns them into the second kind of mobility. For example, a
% mobility vector [1 1 1 1 1 0 0 0 1 1 1 1 1] with the paramter
% event_length set to 3 would return [1 1 1 1 1 1 1 1 1 1 1 1 1].
% The algorithm starts with the shortest events and finishes with the
% longest ones which are event_length long.
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

    % Define the event strings (101, 010, 1001, 0110, etc.)
    event_string = cell(event_length*2,1);
    for i = 1:event_length
        event_string{i} = [1 zeros(1,i) 1];
        event_string{i+event_length} = ~event_string{i};
    end

    % Run over all event strings and for each one repeat until no events of
    % it's length are present
    for i = 1:event_length
        flag_done = 0;
        while ~flag_done
            % Find where each event starts
            event_idx = strfind(mobile',event_string{i});
            % Add the negative events
            event_idx = [event_idx strfind(mobile',event_string{i+event_length})];
            % Add 1 so that event_idx point to the events themselves and
            % not the inital 1's or 0's that frame them
            event_idx = event_idx + 1;
            
            if ~isempty(event_idx)
                % Define the indices that need to be switched
                event_idx = cumsum([event_idx;ones((i-1),numel(event_idx))],1);                                
                % Flip relevant indices
                mobile(event_idx(:)) = ~mobile(event_idx(:));
            else
                flag_done = 1;
            end
        end
        
    end
    
end

