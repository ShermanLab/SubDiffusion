function [ time_vec ] = TimeStamp_From_ND2( varargin )
%TIMESTAMP_FROM_ND2 reads the time stamp data from nd2 files.
% path is optional. Otherwise, an input dialog is opened and a file can be
% chosen. The function make use of the bfGetReader function which is part
% of the Open Microscopy Environment (OME). It can be downloaded from
% http://www.openmicroscopy.org/site
%
% Written by Yonatan Golan 2014-2016 - golanyoni@gmail.com

    % Check if any arguments were given (an argument is supposed to be the
    % path of an nd2 file to read from).
    if isempty(varargin)
        path = '';
    else
        path = varargin{1};    
    end
    
    % Call bfGetReader which reads an nd2 file and converts it to a reader
    % object using Bio-Formats. Download from http://www.openmicroscopy.org/site

    r = bfGetReader(path);

    % Find how many timestamps there are
    T_num = str2num(r.getGlobalMetadata.get('Size'));
    
    % Define the padding length (numbers in the keys are padded with 0's on
    % the left side according to the max number of frames. If for instance
    % there are 2000 frames then all numbers will be written as #0001,
    % #0123 etc. If however there are 500 frames then it will be: #001,
    % #123 etc.)
    zero_pads = floor(log10(T_num))+1;
    
    % Run over all frames and read the time value of each
    for i = 1:T_num
        % Create the padded number
        key_num = sprintf(['%0',num2str(zero_pads),'d'], i);
        
        % Call the get routine to read out the frame i's timestamp.
        time_vec(i) = r.getSeriesMetadata.get(['timestamp #', key_num]);
    end
    
    % Transpose to get a column vector
    time_vec = time_vec';
end

