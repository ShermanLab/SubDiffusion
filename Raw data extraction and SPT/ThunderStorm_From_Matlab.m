function [] = ThunderStorm_From_Matlab(nd2_path,filter_text,drift_correction)
% ThunderStorm_From_Matlab Run the ImageJ plugin ThunderSTORM from within
% matlab.
% The function runs an instance for ImageJ and executes the ThunderSTORM
% plugin according to given parameters. The result is a molecular list .csv
% file which is placed in the same folder as the .nd2 file.
%
% Usage:
%   ThunderStorm_From_Matlab(nd2_path,filter_text,drift_correction)
%   nd2_path: full path of an .nd2 file
%   filter_text: filter out emitters according to the TS syntax
%   drift_correction: boolean choice whether to perform drift correction 
%   according to the TS algorithm 
%
%   Dependencies:
%   1. ImageJ: https://imagej.nih.gov/ij/
%   2. ThunderSTORM plugin: https://github.com/zitmen/thunderstorm/wiki/Downloads
%   3. Bio-Formats plugin: http://imagej.net/Bio-Formats
%   4. Windows wmic command line scripting. See "wmic /?" in the command 
%      line for more information. If you do not have the package or are 
%      running on linux or mac you can work around it's usage by using 
%      appropriate pauses or finding another system command procedure. 
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

%% Initialize variables
    macro_path = 'C:\Users\Owner\Documents\MATLAB\ThunderStorm_From_Matlab.ijm';
    
    % Replace all \ with \\ in the nd2 file so that it confirms with the
    % ImageJ macro syntax
    nd2_path = strrep(nd2_path,'\','\\');    
    % Create the csv path which is the result export path. It's name is the
    % same as the nd2 file
    csv_path = strrep(nd2_path,'nd2','csv');
    
    FilterFormula = ['action=filter formula=[(' filter_text ')]'];
%% Construct macro lines
    % Read the ND2 file using the Bio-Formats plugin    
    BioFormats_Import = ['run("Bio-Formats Importer", "open=[',nd2_path,'] color_mode=Default view=[Standard ImageJ] stack_order=Default use_virtual_stack");'];

    % Run ThunderStorm with default parameters
    TS_Analysis = 'run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 method=[Least squares] full_image_fitting=false fitradius=3 mfaenabled=false renderer=[Averaged shifted histograms] magnification=5.0 colorizez=false shifts=2 repaint=50 threed=false");';
    
    % Filter particles according to the filtering formula
    TS_Filter = ['run("Show results table","' FilterFormula ,'");'];
    
    % Perform drift correction if desired
    if exist('drift_correction','var') && drift_correction
        TS_drift = 'run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] save=false steps=5 showcorrelations=false");';
    else
        TS_drift = [];
    end

    % Save the results to a csv file
    TS_Export_2CSV = ['run("Export results", "id=true frame=true sigma=true filepath=[' csv_path '] bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true fileformat=[CSV (comma separated)]");'];
    
%% Construct the macro file
    % Create the file
    
    fid_macro = fopen(macro_path,'w');
    
    fwrite(fid_macro,BioFormats_Import);
    fwrite(fid_macro,TS_Analysis);
    fwrite(fid_macro,TS_Filter);
    fwrite(fid_macro,TS_drift);
    fwrite(fid_macro,TS_Export_2CSV);
    
    fwrite(fid_macro,'run("Quit");');
    
    % Close the file
    fclose(fid_macro);

%% Execution of ImageJ and ThunderStorm commands
    % Execute ImageJ with all the desired calls. Return the process ID so we
    % can monitor when it is finished and continue
    [~,pid_string] = system(['wmic process call create '... % Use the wmic tool to run ImageJ. See wmic /? in the cmd for more information
                             '"C:\progra~1\ImageJ\ImageJ.exe '... % Run ImageJ
                             ' -macro ', macro_path,' '... % Run the macro specified
                             ' | find "ProcessId"']); % Return the process ID of ImageJ
                             
    % Get the number out of the string which looks like: "ProcessId = 123;" 
    process_id = pid_string(find(pid_string=='=')+2:find(pid_string==';')-1);

    % Run a loop which checks every 0.5s if the process is still running. 
    still_running = 1;
    while still_running
        pause(.5)
        % Check the task list for the desired process ID
        [~,pid_result] = system(['tasklist /fi "pid eq ',process_id,'"']);
        % Once the process ID is gone we will get a message "INFO: No tasks
        % are running which match the specified criteria.", So we check if
        % this is what we get by the first word.
        still_running = ~strcmp(pid_result(1:4),'INFO');
    end
    
    %Delete the macro file
    delete(macro_path)

end    