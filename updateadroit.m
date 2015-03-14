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
    
    [dat, hstate] = filter(hb, ha, dat, hstate);
    dat = dat - repmat(mean(dat, 2), [1 64]);
    [hg, hgstate] = filter(hgb, hga, dat, hgstate);
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

% update
udownstates = binevery(ustate.StimulusCode, 240, 'mode');


%% 

coord = zeros(1835, 1);
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

movemask = finaltargets~=0;

finaltargets = finaltargets(movemask);
hgupdate = hgupdate(movemask,: );
directionpredictor = ClassificationDiscriminant.fit(hgupdate, finaltargets);