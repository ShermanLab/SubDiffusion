function [ track_results ] = Track_FromMolList(mol_list, jump_size, dt)
% Track_FromMolList is a wrapper for the track.m function written by 
% DanielB and EricD which computes the tracks from a molecular list. 
%
% The function returns a struct containing the desired parameters for each
% particle.
%
% The input arguments are:
% mol_list - The molecular list. It should be ordered: X Y frame
% jump_size - the maximal distance in nanometers which a molecule can jump
%   between consecutive frames.
% dt - The time between 2 frames
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com


%% Check for input arguments and assign defaults
    % Assign by default a jump of 500nm
    if ~exist('jump_size')
        jump_size = 500e-9;
    end
      
    % Assign time difference to leave time as frames (dt=1).
    if ~exist('dt')
        dt = 1;
    end
    
    % Set parameters for no memory, no verbose, 2 dimensions and collect
    % all trejectory lengths
    params.mem = 0;
    params.quiet = 1;
    params.dim = 2;
    params.good = 0;
    
%% Compute tracks
    % Call "track" which computes tracks from a molecular list. The
    % function recieves as input the molecular list in order [X,Y,frame]
    temp_track_results = track(mol_list,jump_size,params);
    
    % Once the track function is finished we can clean up all the imaginary
    % molecules at (0,0) which were planted there to overpass a bug in the
    % track function.
    % Do this by finding all the rows where the sum of the first two
    % columns is 0 and negate them.
    temp_track_results(sum(temp_track_results(:,1:2),2)==0,:) = [];

    % The output track_results is ordered: [X,Y,sigma,intensity,frame,track_number]
    % Convert it to a structure for easier readability
    track_results.X = temp_track_results(:,1);
    track_results.Y = temp_track_results(:,2);
    track_results.Sigma = temp_track_results(:,3);
    track_results.Intensity = temp_track_results(:,4);
    track_results.Offset = temp_track_results(:,5);
    track_results.Bkgstd = temp_track_results(:,6);
    track_results.Chi2 = temp_track_results(:,7);
    track_results.Uncertainty = temp_track_results(:,8);
    track_results.frame = temp_track_results(:,9);
    track_results.track = temp_track_results(:,10);
    track_results.time = track_results.frame*dt;

end

