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

[hb, ha] = butter(4, 5/(1220/2), 'high');
[hgb, hga] = butter(4, [70 90]/(1220/2));
[hgb2, hga2] = butter(4, [90 110]/(1220/2));
[bb, ba] = butter(4, [10 30]/(1220/2));

filename = 'buffer://localhost:1972';

% load('movementpredictor');
load('directionpredictor');
relevantchans = [46:48 54:56 62:64];
hstate = [];
hgstate = [];
hg2state = [];
bstate = [];

event.type = 'coord';
event.offset = 0;
event.duration = 1;
eventCoord = event;

disp('Keypress to start')
pause();

coords = [0; 0];
hdr = ft_read_header(filename);
blocksize  = 240;
chanindx   = relevantchans;
prevSample = 0;
counter = uint32(1);

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
        if(mod(counter, 15) == 0)
            fprintf('\n');
        end

        if newsamples >= blocksize*3
            warning('Behind!')
        end
        
        fprintf('reading from buffer %d to %d\n', begsample, endsample);
        % read data segment from buffer
        dat = ft_read_data(filename, 'header', hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx)';
        [dat, hstate] = filter(hb, ha, dat, hstate);
        dat = dat - repmat(mean(dat, 2), [1 length(relevantchans)]);
        [hg, hgstate] = filter(hgb, hga, dat, hgstate);
        [hg2, hg2state] = filter(hgb2, hga2, dat, hg2state);
%         [beta, bstate] = filter(bb, ba, dat, bstate);
        
%         hg = mean(log(abs(hilbert(hg)).^2), 1);
%         hg2 = mean(log(abs(hilbert(hg2)).^2), 1);
%         
        hg = zscore(log(mean(abs(hilbert(hg).^2), 1)));
        hg2 = zscore(log(mean(abs(hilbert(hg2).^2), 1)));

% %         beta = mean(log(abs(hilbert(beta)).^2), 1);
%         
%         signal = [hg beta];
        signal = [hg hg2];
%         gonogo = predict(movementpredictor, signal);
%         fprintf('%d       ', gonogo);
%         if(gonogo > 0)
            direction = predict(directionpredictor, signal);
            fprintf('%d', direction);
            direction = double(direction);
            coords(1) = coords(1) + 0.25*direction;
            if(coords(1) > 1.5)
                coords(1) = 1.5;
            elseif(coords(1) < -1.5)
                coords(1) = -1.5;
            end
%         end
        fprintf('\n');
            
        newposition = protosynergies*coords;
        newposition = newposition + originpos;
        mjcPlot(so, newposition);
%         disp(newposition)
        eventCoord = event;
        eventCoord.sample = hdr.nSamples*hdr.nTrials;
        eventCoord.value = uint16(round(coords(1)*100));
        ft_write_event(filename, eventCoord);
    end
%     moveclass = predict(predictor, validationHG);

end
mjcClose(so);
