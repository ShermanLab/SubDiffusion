function [] = Tracks_To_Cells()
% TRACKS_TO_CELLS converts .mat files containing track_results and creates
% a new file with only cell arrays of the long tracks. This is done for
% each .mat file separately and to all of them collectively.
% There is no input and no output - a dialogue is opened for choosing which
% files are wanted. The new files are saved in the same folder as the 
% original ones.

% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

%% Choose desired files and initialize variables
    [matfiles, path_name] = uigetfile('*.mat','multiselect','on');
    % Convert to cell array if only one file was selected
    if ~iscell(matfiles)
        matfiles = {matfiles};
    end
    
    % Initialize the variables for all the tracks together.
    All_X = {};
    All_Y = {};
    All_Sigma = {};
    All_Intensity = {};
    All_Offset = {};
    All_Uncertainty = {};
    All_dt = [];
    All_Cells = [];
    All_Frames = {};
    Cell_Centers = zeros(2,numel(matfiles));
%% Run over all files
    for matfiles_ind = 1:numel(matfiles)
        load([path_name,matfiles{matfiles_ind}])
        % Initialize X and Y
        X = {};
        Y = {};
        Sigma = {};
        Intensity = {};
        Offset = {};
        Uncertainty = {};
        Frames = {};

        % Find the cell center
        Cell_Centers(1,matfiles_ind) = mean(track_results.X);
        Cell_Centers(2,matfiles_ind) = mean(track_results.Y);
        Cell_Center = Cell_Centers(1:2,matfiles_ind);
        % Run over all long tracks
        for j = 1:length(track_results.long_tracks_id)
            track_indices = find(track_results.track == track_results.long_tracks_id(j));
            X{j} = track_results.X(track_indices);
            Y{j} = track_results.Y(track_indices); 
            Sigma{j} = track_results.Sigma(track_indices);
            Intensity{j} = track_results.Intensity(track_indices);
            Offset{j} = track_results.Offset(track_indices);
            Uncertainty{j} = track_results.Uncertainty(track_indices);
            Frames{j} = track_results.frame(track_indices);
        end

        % Correct the X and Y values for vibrations
        [X, Y, Vibration_Statistics] = CorrectXY_Vibrations(X,Y,Frames);
        
        % Add these X and Y's to the big list
        All_X = [All_X, X];
        All_Y = [All_Y, Y];
        All_Sigma = [All_Sigma, Sigma];
        All_Intensity = [All_Intensity, Intensity];
        All_Offset = [All_Offset, Offset];
        All_Uncertainty = [All_Uncertainty, Uncertainty];
        All_dt = [All_dt, ones(1,numel(X))*dt];
        All_Cells = [All_Cells, ones(1,numel(X))*matfiles_ind];
        All_Frames = [All_Frames, Frames];     
        
        % Generate the filename for saving
        LastSlash = strfind(path_name,'\');
        LastSlash = LastSlash(end-1);
        FirstParenthesis = strfind(matfiles{matfiles_ind},'[');
        FirstParenthesis = FirstParenthesis(1);
        newfilename = [path_name(LastSlash+1:end-1),' ',matfiles{matfiles_ind}(1:FirstParenthesis-1), 'XYt'];
        save(newfilename,'X','Y','dt','Sigma','Intensity','Offset','Uncertainty','Frames','Vibration_Statistics','Cell_Center')
    end
    dt = mean(All_dt);
    % Save the large list
    save([path_name(LastSlash+1:end-1),' All XYt'],'All_X','All_Y','All_dt','All_Cells','All_Sigma','All_Intensity','All_Offset','All_Uncertainty','All_Frames','Cell_Centers','dt')

end

