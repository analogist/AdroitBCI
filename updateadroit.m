setupAll('hodgkin');
% [olddata, oldstate] = load_bcidatUI;
[updatedata, ustate] = load_bcidatUI;
[hb, ha] = butter(4, 5/(1220/2), 'high');
[hgb, hga] = butter(4, [70 100]/(1220/2));
[bb, ba] = butter(4, [10 30]/(1220/2));
hstate = [];
hgstate = [];
bstate = [];
%% iterative filter
hstate = [];
hgstate = [];
bstate = [];
startpoints = 1:240:size(updatedata);
i = 1;
% signal = zeros(5000, 128);
signal = zeros(5000, 64);
istate = zeros(5000, 1);
for(start = startpoints(1:end-1))
    dat = updatedata(start:start+239, :);
    
    [dat] = filter(hb, ha, dat);
    dat = dat - repmat(mean(dat, 2), [1 64]);
    [hg] = filter(hgb, hga, dat);
%     [dat, hstate] = filter(hb, ha, dat, hstate);
%     dat = dat - repmat(mean(dat, 2), [1 64]);
%     [hg, hgstate] = filter(hgb, hga, dat, hgstate);
%     [beta, bstate] = filter(bb, ba, dat, bstate);

    hg = mean(log(abs(hilbert(hg)).^2), 1);
%     beta = mean(log(abs(hilbert(beta)).^2), 1);
% 
%     signal(i, :) = [hg beta];
    signal(i, :) = hg;
%     istate(i) = mode(state.StimulusCode(start:start+239))
    i = i+1;
end

hgupdate = signal(1:i-1, :);
hglength = i;
% update
udownstates = binevery(ustate.StimulusCode, 240, 'mode');


%% 
[predictfile, predictpath] = uigetfile;
load([predictpath predictfile])
actualmovedir = predict(directionpredictor, hgupdate);
coord = zeros(hglength, 1);
for(i = 2:length(actualmovedir))
    coord(i)=coord(i-1)+actualmovedir(i)*0.25;
    if(coord(i)) > 1.5
        coord(i) = 1.5;
    elseif(coord(i) < -1.5)
        coord(i) = -1.5;
    end
end
coord = coord(2:end);

%% 
tempdown = double(udownstates);
tempdown = tempdown(1:end-1)
tempdown(tempdown == 1) = -1.5;
tempdown(tempdown == 2) = 0;
tempdown(tempdown == 3) = 1.5;


%%
maskforsqueeze = (tempdown - coord > 0.5);
maskforrest = (abs(tempdown-coord)<0.5);
maskforrelax = (coord-tempdown > 0.5);
finaltargets = (maskforsqueeze*1 + maskforrest*0 + maskforrelax*-1);
movemask = finaltargets~=0;
%%
finaltargets = finaltargets(movemask);
hgupdate = hgupdate(movemask,: );
finaltargets1 = finaltargets;
hgupdate1 = hgupdate;

%%
% [olddata, oldstate] = load_bcidatUI;
[update2data, u2state] = load_bcidatUI;
[hb, ha] = butter(4, 5/(1220/2), 'high');
[hgb, hga] = butter(4, [70 100]/(1220/2));
[bb, ba] = butter(4, [10 30]/(1220/2));
hstate = [];
hgstate = [];
bstate = [];
%% iterative filter
hstate = [];
hgstate = [];
bstate = [];
startpoints = 1:240:size(update2data);
i = 1;
% signal = zeros(5000, 128);
signal = zeros(5000, 64);
istate = zeros(5000, 1);
for(start = startpoints(1:end-1))
    dat = update2data(start:start+239, :);
    
%     [dat, hstate] = filter(hb, ha, dat, hstate);
%     dat = dat - repmat(mean(dat, 2), [1 64]);
%     [hg, hgstate] = filter(hgb, hga, dat, hgstate);
   [dat] = filter(hb, ha, dat);
    dat = dat - repmat(mean(dat, 2), [1 64]);
    [hg] = filter(hgb, hga, dat);
%     [beta, bstate] = filter(bb, ba, dat, bstate);

    hg = mean(log(abs(hilbert(hg)).^2), 1);
%     beta = mean(log(abs(hilbert(beta)).^2), 1);
% 
%     signal(i, :) = [hg beta];
    signal(i, :) = hg;
%     istate(i) = mode(state.StimulusCode(start:start+239))
    i = i+1;
end

hgupdate = signal(1:i-1, :);
hglength = i;
% update
udownstates = binevery(u2state.StimulusCode, 240, 'mode');


%% 
[predictfile, predictpath] = uigetfile;
load([predictpath predictfile])
actualmovedir = predict(directionpredictor, hgupdate);
coord = zeros(hglength, 1);
for(i = 2:length(actualmovedir))
    coord(i)=coord(i-1)+actualmovedir(i)*0.25;
    if(coord(i)) > 1.5
        coord(i) = 1.5;
    elseif(coord(i) < -1.5)
        coord(i) = -1.5;
    end
end
coord = coord(2:end);

%% 
tempdown = double(udownstates);
tempdown(tempdown == 1) = -1.5;
tempdown(tempdown == 2) = 0;
tempdown(tempdown == 3) = 1.5;


%%
maskforsqueeze = (tempdown - coord > 0.5);
maskforrest = (abs(tempdown-coord)<0.5);
maskforrelax = (coord-tempdown > 0.5);
finaltargets = (maskforsqueeze*1 + maskforrest*0 + maskforrelax*-1);
movemask = finaltargets~=0;
%%
finaltargets = finaltargets(movemask);
hgupdate = hgupdate(movemask,: );

directionpredictor = ClassificationDiscriminant.fit([hgupdate1; hgupdate], [finaltargets1; finaltargets]);