%% Read and parse the TCP buffered content
% Given good stream, with attached DataReader.class, read all the
% data in the buffer.
% Needs to be scalable to multiple channels. Right now 1 channel.

function [ch1, ch2, stim, tstamp] = bci_readparse(inputstream_reader, readbytes)
    bciJSON = inputstream_reader.readBuffer(readbytes);
    bciJSON = char(bciJSON');
    
%      disp(bciJSON);

    % Channel 1 parse
    ch1prestring = '"Channels":{"0":['; % search for this string
    ch1pos = strfind(bciJSON, ch1prestring); % find position(s)
    foundit = false;
    if(ch1pos)
        for i = length(ch1pos):-1:1 % there may be many positions
                                    % count down from the last one found
            if(ch1pos(i)+length(ch1prestring)+11 <= length(bciJSON))
                ch1segment = bciJSON((ch1pos(i)+length(ch1prestring))...
                    :(ch1pos(i)+length(ch1prestring)+11));
                                    % make sure it isn't truncated
                                    % generally, 11 digits will ensure this
                commapos = strfind(ch1segment, ',');
                ch1 = str2double(ch1segment(1:commapos));
                if(isnan(ch1))      % just in case it's truncated anyway
                    ch1 = 0;
                end
                foundit = true;     % if it's found, exit the loop
                break;
                
                % otherwise, go check the next-to-last position
            end
        end
        if ~foundit
            ch1 = 0;
        end
    else
        ch1 = 0;
    end
    
    % Channel 2 parse
    ch2prestring = '],"1":['; % search for this string
    ch2pos = strfind(bciJSON, ch2prestring); % find position(s)
    foundit = false;
    if(ch2pos)
        for i = length(ch2pos):-1:1 % there may be many positions
                                    % count down from the last one found
            if(ch2pos(i)+length(ch2prestring)+11 <= length(bciJSON))
                ch2segment = bciJSON((ch2pos(i)+length(ch2prestring))...
                    :(ch2pos(i)+length(ch2prestring)+11));
                                    % make sure it isn't truncated
                                    % generally, 11 digits will ensure this
                commapos = strfind(ch2segment, ',');
                ch2 = str2double(ch2segment(1:commapos));
                if(isnan(ch2))      % just in case it's truncated anyway
                    ch2 = 0;
                end
                foundit = true;     % if it's found, exit the loop
                break;
                
                % otherwise, go check the next-to-last position
            end
        end
        if ~foundit
            ch2 = 0;
        end
    else
        ch2 = 0;
    end
    
    
        % StimulusCode parse: BTW IF NOT FOUND, DEFAULT TO 9
    stimprestring = '"StimulusCode":"'; % search for this string
    stimpos = strfind(bciJSON, stimprestring); % find position(s)
    foundit = false;
    if(stimpos)
        for i = length(stimpos):-1:1 % there may be many positions
                                    % count down from the last one found
            if(stimpos(i)+length(stimprestring)+3 <= length(bciJSON))
                stimsegment = bciJSON((stimpos(i)+length(stimprestring))...
                    :(stimpos(i)+length(stimprestring)+3));
                                    % make sure it isn't truncated
                                    % generally, 11 digits will ensure this
                stim = str2double(stimsegment(1));
                if(isnan(stim))      % just in case it's truncated anyway
                    ch2 = 9;
                end
                foundit = true;     % if it's found, exit the loop
                break;
                
                % otherwise, go check the next-to-last position
            end
        end
        if ~foundit
            stim = 9;
        end
    else
        stim = 9;
    end
    
    
    % Timestamp parse
    tstampprestring = '"SourceTime":"'; % search for this string
    tstamppos = strfind(bciJSON, tstampprestring); % find position(s)
    foundit = false;
    if(tstamppos)
        for i = length(tstamppos):-1:1 % there may be many positions
                                    % count down from the last one found
            if(tstamppos(i)+length(tstampprestring)+11 <= length(bciJSON))
                tstampsegment = bciJSON((tstamppos(i)+length(tstampprestring))...
                    :(tstamppos(i)+length(tstampprestring)+11));
                                    % make sure it isn't truncated
                                    % generally, 11 digits will ensure this
                commapos = strfind(tstampsegment, '",');
                tstamp = str2double(tstampsegment(1:commapos-1));
                if(isnan(tstamp))      % just in case it's truncated anyway
                    tstamp = 0;
                end
                foundit = true;     % if it's found, exit the loop
                break;
                
                % otherwise, go check the next-to-last position
            end
        end
        if ~foundit
            tstamp = 0;
        end
    else
        tstamp = 0;
    end
end