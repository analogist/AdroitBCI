function [ch1, ch2, stim, tstamp] = bci_parse(bciJSON)
%% Read and parse the TCP buffered content
% Parse a complete TCP message into constituent parts

    % Separate States and Channels
    statestart = strfind(bciJSON, '"States":');
    channelstart = strfind(bciJSON, '"Channels":');
    
end
