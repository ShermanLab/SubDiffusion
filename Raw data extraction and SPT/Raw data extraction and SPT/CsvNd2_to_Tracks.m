function [ ] = CsvNd2_to_Tracks(nd2_path, Expected_D, track_min_max , vibrations_correction)
% CSVND2_TO_TRACKS Takes a .csv molecular list and a .nd2 microscopy file 
% and generates trajectories of particles. The function generates a .mat 
% file containing the resulting trajectories.
% 
%   Usage:
%   CsvNd2_to_Tracks(nd2_path, Expected_D, track_min_max , vibrations_correction)
%    nd2_path: Full path of the .nd2 file. The molecular list .csv file 
%       with the same name should be in the same directory.
%    Expected_D: Expected diffusion coefficient used for estimating the
%       maximal distance a particle can travel between frames.
%    track_min_max: Array with 2 values indicating the minimal and maximal
%       lengths permitted per trajectory. Use [0 inf] for no limits.
%    vibrations_corrections: Boolean flag for choosing whether to correct
%       image vibrations or not.
% 

% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

    %% Initialize parameters
    
    % The expected range of D. This will enable to limit the jump size from
    % frame to frame. Dimensions in m^2.
    if nargin < 2
        Expected_D = 0.5*1e-12; 
    end
    
    % min and max length of a track to be considered.
    if nargin < 3
        track_min_max = [50 inf]; 
    end
    
    % Flag for vibrations correction in case of microscopic vibrations of
    % the sample or camera.
    if nargin < 4
        vibrations_correction = 0;
    end
    
    csv_path = [nd2_path(1:end-3),'csv'];

    %% Retrive the time vector from the ND2 file

    % Run the TimeStamp_From_ND2 function which retrieves the time vector from
    % the ND2 file.
    time_vector = TimeStamp_From_ND2(nd2_path);
    dt = mean(diff(time_vector));

    jump_size = 3*sqrt(4*dt*Expected_D); % max distance in meters that a molecule can jump in a frame.
    
    %% Read molecular list from the ThunderStorm format and compute tracks from it
    mol_list = ReadMolList_ForTracking(csv_path);
    
    % Call the Track_FromMolList function
    track_results = Track_FromMolList(mol_list, jump_size, dt);    
    
    clear mol_list
    
    %% Correct vibrations
    % This module may be of high significance for SMLM data where nm scale
    % vibrations are almost inevitable. If you fo not know or are not sure
    % if vibrations are an issue in your system, you can check the spectrum
    % of frequencies in meanXY and their corresponding amplitudes. Of
    % course, this method is only relevant for cases with a high number of
    % trajectories.
    
    if vibrations_correction    
        % Find which molecules are part of a track at least 5 frames long
        tracks_for_vib = Track_Lengths(track_results, [5 inf]);
        ids_for_vib =  ismember(track_results.track,tracks_for_vib);
        XY_for_vib = [track_results.X(ids_for_vib),track_results.Y(ids_for_vib),track_results.frame(ids_for_vib)];
        
        % Find the mean of all emitters per frame
        meanXY = grpstats(XY_for_vib(:,1:2),XY_for_vib(:,3));
        
        % Correct X and Y locations according to the mean of each frame
        for i=1:max(track_results.frame)
            track_results.X(track_results.frame==i) = track_results.X(track_results.frame==i) - meanXY(i,1);
            track_results.Y(track_results.frame==i) = track_results.Y(track_results.frame==i) - meanXY(i,2);
        end
        clear tracks_for_vib ids_for_vib XY_for_vib
    end
    %% Find the tracks with time steps in the range track_min_max
    % Call the Track_Lengths function which returns the track numbers which are
    % in the range of _track_min_max_
    track_results.long_tracks_id = Track_Lengths(track_results, track_min_max);
    for i = 1:length(track_results.long_tracks_id)
        % Find the index in the array where track number _i_ is
        track_index = find(track_results.track == ...
                           track_results.long_tracks_id(i),1); 

        % Count length of all long tracks
        track_results.long_tracks_lengths(i) = ...
            sum(track_results.track == track_results.long_tracks_id(i));

        % Find the segment in which track 'i' is
        track_results.long_tracks_time(i) = track_results.time(track_index);
    end

    %% Save the results 
    clear i
    save([nd2_path(1:end-4),' [',num2str(track_min_max),'].mat'])
end

