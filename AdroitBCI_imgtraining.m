%% Init
% variables
clear all
rootpath = pwd();
[adroitpath, port, timeout, read_timeout, synergydims, originpos, protosynergies]...
    = setup_bci(rootpath);
[model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
    = setup_adroit(adroitpath, originpos);

filename = 'buffer://localhost:1972';

% read the header for the first time to determine number of channels and sampling rate
hdr = ft_read_header(filename);

blocksize  = 0.100*hdr.Fs;
chanindx   = 1:hdr.nChans;
eventsize = 0;
intrial = logical(0);

while true
  % determine number of samples available in buffer
%   hdr = ft_read_header(filename);
%   disp(hdr.nSamples);

    % read data segment from buffer
    % dat = ft_read_data(filename, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx);
    eventcode = ft_read_event(filename, 'header', hdr);
    currentsize = size({eventcode.value}, 2);
	if(currentsize > eventsize) %% this needs to be a function
        disp('new events!')
        disp([eventcode.type])
        newstim = [eventcode(eventsize+find(strcmp('StimulusCode', {eventcode((eventsize+1):currentsize).type}))).value];
        disp(newstim);
        eventsize = currentsize;
    end
    
    if(newstim > 0 && ~intrial)
        intrial = 1;
        switch(mod(newstim,4))
            case 1
                
            case 2
            case 3
        end
    elseif(newstim == 0 && intrial)
        intrial = 0;
    end
    
%     if(eventcode(1, 3).value) == 1
%         while(eventcode(1, 3).value > 0)
           
end % while true