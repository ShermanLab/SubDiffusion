function [molecular_list, file_name, file_path] = ...
    ReadMolList(desired_columns, full_path)
% ReadMolList  Read a molecular list from a text file.
%  molecular_list = ReadMolList opens a dialog for choosing a text file
%  containing a molecular list and then enables choosing which columns to
%  import. The molecular list is one created with the NIS elements program
%  or with ThunderStorm (or any other tab delimited text file with a
%  headings row. Note that the function at this point also neglects the
%  first column since in the molecular list it is text that represent the
%  name of the collecting channel.
% 
% molecular_list = ReadMolList(desired_columns, full_path) reads the
% desired columns given in a vector format from the given file. This option
% bypasses the dialogs used for reading the file and choosing columns.
%  
% [molecular_list, file_name, file_path] = ReadMolList(desired_columns,
% full_path)  also returns the file name and path.

% The function first gets the file to be read, imports it, reads the
% headings row and the either creates a gui based on the headings so the
% user can select which columns are wanted or uses _desired_cols_ for that
% purpose. Then an array with only the desired columns is created.
% 
% Written by Yonatan Golan, August 2014
% Added the calling with _desired_cols_ as an input and the option to call
% the file name upon calling the function - December 2014

%% Choose file and read headings

    % Check if _full_path_ was given as input and that it is not empty.
    % If not run the interactive get file function
    
    if ~exist('full_path') | isempty(full_path)        
        % Allow user to choose the file interactively. Multiple files are
        % allowed as long as their structure is the same.
        [file_name, file_path] = uigetfile(...
            {'*.txt; *.csv','Text files';'*.*','All files'}...
            ,'multiselect','on');
        
        % If a single file was chosen then change it to a cell
        if ~iscell(file_name) 
            file_name = {file_name};
        end
        
        % Construct the full path
        for i=1:length(file_name)
            full_path{i} = [file_path,file_name{i}];
        end
        
    else
        % Else, if full path was given then:
        % set the file name
        
        % find the file name in the full path
        fname_index = find(full_path == '\',1,'last');
        % adjust it in the case that only the file name was given
        if isempty(fname_index)
            fname_index = 0;
        end
        % set the file name and path
        file_name = {full_path(fname_index+1:end)};
        file_path = full_path(1:fname_index);
        
        % change the full path to a cell array
        full_path = {full_path};
    end

    for i=1:length(full_path)
        % Read file using importdata
        file_data{i} = importdata(full_path{i});
    end
        
    % Read headings from first file only, assuming all files have the same
    % structure.
    HeadingLine = file_data{1}.textdata(1,:);
    
    % Get number of columns
    col_num = length(HeadingLine);

    % Decide if to create a GUI or continue to reading the desired columns.
    % This is possible if desired_cols was specified upon calling the
    % function.
    if nargin == 0 
%% Create GUI for choosing which columns are desired
    % Figure position and dimensions. The distance from the left and
    % bottom sides of the screen are arbitrary. The width is defined so
    % long enough column names can be visualized and the height is the
    % number of columns times 20 (which is the defined check box height)
    % plus 40 which is the height of the push button.
    f_left = 500; f_bottom = 300;
    f_width = 200; f_height = col_num*20+40;

    % Create figure with all it's properties
    fig_handle = figure('name','File reading options',...
        'position',[f_left,f_bottom,f_width,f_height],...
        'toolbar','none','menubar','none','numbertitle','off');
    
    % Create defaults for checkboxes. If a default file exists read it and
    % use it. Otherwise all checkboxes will be unchecked.
    chkbox_def = zeros(1,col_num);
    fid=fopen('ReadMolList_Defaults.txt');
    if fid ~= -1
        % Read the top row which should be a list of numbers
        def = fscanf(fid,'%d');
        
        % Assign a '1' for each of the desired columns 
        chkbox_def(def) = 1;
        
        % Close the file
        fclose(fid);
    end
    
    % Add checkboxes for each of the columns
    for i = 1:col_num
        chkbox_handles(i) = uicontrol(fig_handle,'style','checkbox',...
            'string',HeadingLine{i},...
            'value',chkbox_def(i),...
            'position',[0,f_height-20*i,200,20]);
    end
    
    % Add push button for submitting
    pbtn_handle = uicontrol(fig_handle,'style','pushbutton',...
        'string','OK','position',[0,0,f_width,40],...
        'callback','uiresume(gcf)');
    
    % Wait for user to press the push button
    uiwait(gcf)
    
    % Once the button is pressed we can see which columns were selected and
    % produce the desired matrix
    % Read checkboxes values
    desired_columns = find(cell2mat(get(chkbox_handles,'value')));
    
    % Close the gui
    close(gcf)

    end %The end of "if nargin == 0"

%% Produce output    
    for i=1:length(file_data)
        % Retrieve from file_data only the desired columns and the column
        % names
        molecular_list{i} = file_data{i}.data(:,desired_columns);
        %headings = HeadingLine(desired_cols); % This is commented out
        %because for now it is unnecessary. In the future, if the columns
        %are desired they can be read out as output.
    end
    
%     % If there is only one file convert it to a single matrix instead of a
%     % cell array
%     if length(file_data) == 1
%         molecular_list = molecular_list{1};
%     end
    
end
    
    