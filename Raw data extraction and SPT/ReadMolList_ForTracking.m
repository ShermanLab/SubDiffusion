function [mol_list, file_name, file_path] = ReadMolList_ForTracking(full_path)
% ReadMolList_ForTracking reads a molecular list from a .csv file and
% arranges it in a way to fit the track.m tracking algorithm.
% The function uses the ReadMolList function which which reads a molecular 
% list produced in ThunderStorm. 
% The corrections made to the molecular list are:
% 1. Flip Y coordinates so that the values correspond to the initial view.
% 2. Convert units to meters instead of nm.
% 3. Fill in frames where no molecules are found so that the tracking
%    algorithm doesn't neglect them as invalid frames.
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com


    % Check if full_path was given and if not create it empty so that the
    % ReadMolList function is satisfied.
    if ~exist(full_path)
        full_path = [];
    end
        
    % Call ReadMolList which reads a molecular list produced by
    % ThunderStorm. The columns [3,4,5,6,7,8,9,10,2] are [X,Y,sigma,intensity, offset, bkgstd, chi2, uncertainty,frame] 
    % of each molecule.
    [mol_list, file_name, file_path]=ReadMolList([3,4,5,6,7,8,9,10,2],full_path);

    % Perform corrections for each molecular list
    for i = 1:length(mol_list)
    
        % Flip the order of the y axis so it corresponds with the view
        % given by ThunderStorm (or any other program) where the
        % coordinates start from the upper left corner and not the lower
        % left one.
        mol_list{i}(:,2) = max(mol_list{i}(:,2)) - mol_list{i}(:,2);
    
        % Convert X and Y to meters
        mol_list{i}(:,1) = mol_list{i}(:,1) * 1e-9;
        mol_list{i}(:,2) = mol_list{i}(:,2) * 1e-9;

        % fill in missing frames - missing frames where no molecules were
        % detected cause a bug in the track.m file. Therefore, I create an
        % imaginary molecule at (0,0) in each frame that has no molecules.
        % Find which frames are missing:
        missing_frames = setdiff(1:max(mol_list{i}(:,9)),mol_list{i}(:,9));
        % add the missing frames
        mol_list{i}(end+1:end+length(missing_frames),9) = missing_frames';
        % Sort the list
        mol_list{i} = sortrows(mol_list{i},9);
    end
    
    if length(mol_list)==1
        mol_list = mol_list{1};
    end
end

