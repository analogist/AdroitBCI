%% BCI2000 ECoG <-> Adroit
% w/ Vikash's mj simulation of Adroit arm
% Adroit_sim must be located in the parent of AdroitBCI folder

%% Init
% variables
% clear all

if(~exist('so'))
    rootpath = pwd();
    [adroitpath, port, timeout, read_timeout, synergydims, originpos, protosynergies]...
        = setup_bci(rootpath);
    [model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
        = setup_adroit(adroitpath, originpos);
else
    mjcClose(so);
    [model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
        = setup_adroit(adroitpath, originpos);
end

[hb, ha] = butter(4, 5/(1220/2), 'high');
[hgb, hga] = butter(4, [70 90]/(1220/2));
[hgb2, hga2] = butter(4, [90 110]/(1220/2));
[hgb3, hga3] = butter(4, [110 130]/(1220/2));
[hgb4, hga4] = butter(4, [130 150]/(1220/2));
[bb, ba] = butter(4, [10 30]/(1220/2));

filename = 'buffer://localhost:1972';

% load('movementpredictor');
load('directionpredictor');
% relevantchans = [46:48 54:56 62:64];
relevantchans = [46:47 54:55];
hstate = [];
% hgstate = [];
% hg2state = [];
% bstate = [];

event.type = 'coord';
event.offset = 0;
event.duration = 1;
eventCoord = event;

event.type = 'coord2';
event.offset = 0;
event.duration = 1;
eventCoord2 = event;

disp('Keypress to start')
pause();

coords = [0; 0];
hdr = ft_read_header(filename);
blocksize  = 120;
chanindx   = relevantchans;
prevSample = 0;
counter = uint32(1);

circbuff = nan(15*10, length(relevantchans)*7);

%% Big Loop
terminate = false;
while(~terminate)
    hdr = ft_read_header(filename);

  % see whether new samples are available
    newsamples = (hdr.nSamples*hdr.nTrials-prevSample);

    if (newsamples>=blocksize)
        % determine the samples to process
        begsample  = prevSample+1;
        endsample  = prevSample+blocksize ;

        % remember up to where the data was read
        prevSample  = endsample;
        fprintf('%d ', counter);
        counter = counter+1;

        if newsamples >= blocksize*3
            warning('Behind!')
        end
        
        fprintf('reading from buffer %d to %d\n', begsample, endsample);
        % read data segment from buffer
        dat = ft_read_data(filename, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx)';
        dat = double(dat);
        [dat, hstate] = filter(hb, ha, dat, hstate);
        dat = dat - repmat(mean(dat, 2), [1 length(relevantchans)]);
        [hg] = filter(hgb, hga, dat);
        [hg2] = filter(hgb2, hga2, dat);
        [hg3] = filter(hgb3, hga3, dat);
        [hg4] = filter(hgb4, hga4, dat);
        [beta] = filter(bb, ba, dat);
        
        hgmax = log(max(abs(hilbert(hg)).^2));
        hg2max = log(max(abs(hilbert(hg2)).^2));
        hg = log(mean(abs(hilbert(hg).^2), 1));
        hg2 = log(mean(abs(hilbert(hg2)).^2, 1));
        hg3 = log(mean(abs(hilbert(hg3)).^2, 1));
        hg4 = log(mean(abs(hilbert(hg4)).^2, 1));
        beta = log(mean(abs(hilbert(beta).^2), 1));

        signal = [hg hg2 hg3 hg4 hgmax hg2max beta];
        circbuff = [signal; circbuff(1:end-1, :)];
        zcircbuff = zscore(circbuff(~any(isnan(circbuff), 2), :), [], 1);
        outputs = zcircbuff(1, :);
        
            direction = predict(directionpredictor, outputs);
            fprintf('%d', direction);
            if(direction == 0)
%                 coords = coords.*[.90; .90];
                coords = coords - (coords - [-1.3; -1.3]).*[.04; .04];
            elseif(direction == 1)
                coords(1) = coords(1) + 0.1;
            elseif(direction == 2)
                coords(2) = coords(2) + 0.1;
            end          
            
            if(coords(1) > 1.5)
                coords(1) = 1.5;
            elseif(coords(1) < -1.3)
                coords(1) = -1.3;
            end
            if(coords(2) > 1.5)
                coords(2) = 1.5;
            elseif(coords(2) < -1.3)
                coords(2) = -1.3;
            end
            
            disp(coords);
%         end
        fprintf('\n');
            
        newposition = protosynergies*coords;
        newposition = newposition + originpos;
        mjcPlot(so, newposition);
%         disp(newposition)
        eventCoord.sample = hdr.nSamples*hdr.nTrials;
        eventCoord.value = uint16(round(coords(1)*100)+1000);
        eventCoord2.sample = hdr.nSamples*hdr.nTrials;
        eventCoord2.value = uint16(round(coords(2)*100)+1000);
        ft_write_event(filename, eventCoord);
        ft_write_event(filename, eventCoord2);
    end
%     moveclass = predict(predictor, validationHG);

end
mjcClose(so);
