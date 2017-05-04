function [ tracks_long, t_lengths ] = ...
    Track_Lengths(track_results, track_min_max, is_plot)
% Track_Lengths computes the length of each track in the given
% track_results struct. It returns the lengths and a list of all tracks 
% in the range of track_min_max
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com


    % Generate a list of lengths of each track
    [t_lengths,track_ids] = ...
        hist(track_results.track,unique(track_results.track));

    % find all tracks in the range of _track_min_max_
    tracks_long = track_ids((t_lengths >= track_min_max(1)) & (t_lengths <= track_min_max(2)));

    %% Plot a histogram of the lengths of tracks    
    if exist('is_plot') && is_plot        

        % Plot the histogram of the lengths with bins from 1 to the number
        % of frames in each segment
        figure
        hist(t_lengths,1:max(t_lengths))
        
    end
end

