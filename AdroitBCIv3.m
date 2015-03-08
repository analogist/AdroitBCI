%% BCI2000 ECoG <-> Adroit
% w/ Vikash's mj simulation of Adroit arm
% Adroit_sim must be located in the parent of AdroitBCI folder

%% Init
% variables
% clear all
rootpath = pwd();
[adroitpath, port, timeout, read_timeout, synergydims, originpos, protosynergies]...
    = setup_bci(rootpath);
[model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
    = setup_adroit(adroitpath, originpos);

linhilb = design(fdesign.hilbert('N,TW',20,0.1),'equiripple');

filename = 'buffer://localhost:1972';
hdr = ft_read_header(filename);
blocksize  = 0.100*hdr.Fs;
chanindx   = 1:hdr.nChans;
eventsize = 0;
intrial = logical(0);

%% Big Loop
terminate = false;
while(~terminate)
    hdr = read_header(filename, 'cache', true);

  % see whether new samples are available
    newsamples = (hdr.nSamples*hdr.nTrials-prevSample);

    if newsamples>=blocksize

    % determine the samples to process
    begsample  = prevSample+1;
    endsample  = prevSample+blocksize ;

    % remember up to where the data was read
    prevSample  = endsample;
    count       = count + 1;
    fprintf('processing segment %d from sample %d to %d\n', count, begsample, endsample);

    % read data segment from buffer
    dat = read_data(filename, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx);
    
    dat = dat - mean(dat, 2);
    hg = abs(hilbert(dat));
    
end
mjcClose(so);
