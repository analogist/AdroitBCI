filename = 'buffer://localhost:1972';

% read the header for the first time to determine number of channels and sampling rate
hdr = ft_read_header(filename);

blocksize  = 0.100*hdr.Fs;
chanindx   = 1:hdr.nChans;
eventsize = 0;
intrial = 0;

while true
  % determine number of samples available in buffer
%   hdr = ft_read_header(filename);
%   disp(hdr.nSamples);

    % read data segment from buffer
    % dat = ft_read_data(filename, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx);
    eventcode = ft_read_event(filename, 'header', hdr);
    currentsize = size({eventcode.value}, 2);
	if(currentsize > eventsize)
        disp('new events!')
        disp([eventcode.type])
        newstim = [eventcode(eventsize+find(strcmp('StimulusCode', {eventcode((eventsize+1):currentsize).type}))).value];
        disp(newstim);
        eventsize = currentsize;
    end
    
%     if(newstim > 0)
%         intrial = 1;
%         switch(newstim)
    
%     if(eventcode(1, 3).value) == 1
%         while(eventcode(1, 3).value > 0)
           
end % while true