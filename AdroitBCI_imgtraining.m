%% Init
% variables
clear all
rootpath = pwd();
[adroitpath, fieldtrippath, timeout, read_timeout, synergydims, originpos, protosynergies]...
    = setup_bci(rootpath);
[model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
    = setup_adroit(adroitpath, originpos);

openseq = [linspace(0, 1.5, 50) linspace(1.5, 0, 50)];
closeseq = [linspace(0, -1.5, 50) linspace(-1.5, 0, 50)];

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
        disp({eventcode((eventsize+1):currentsize).type})
        newstim = [eventcode(eventsize+find(strcmp('StimulusCode', {eventcode((eventsize+1):currentsize).type}))).value];
        stoprunning = [eventcode(eventsize+find(strcmp('Running', {eventcode((eventsize+1):currentsize).type}))).value];
        disp(newstim);
        eventsize = currentsize;
    end
    
    if(~isempty(stoprunning))
        if(stoprunning == 0)
            mjcClose(so);
            return
        end
    end
    
    if(~isempty(newstim))
        if(newstim > 0 && ~intrial)
            intrial = 1;
            poses = zeros(size(protosynergies, 2), 100);
            switch(mod(newstim,5))
                case 1
                    poses(1, :) = openseq;
                    poses = poses';
                case 2
                    poses(1, :) = closeseq;
                    poses = poses';
                case 3
                    poses(2, :) = openseq;
                    poses = poses';
                case 4
                    poses(2, :) = closeseq;
                    poses = poses';
            end
            for i=1:size(poses, 1)
                newposition = protosynergies*poses(i, :)';
                newposition = newposition + originpos;
                mjcPlot(so, newposition);
                pause(0.04);
            end
        elseif(newstim == 0 && intrial)
            intrial = 0;
        end
    end     
end