%% load
params = setupAll('TDT');
subjis = params.subjects{1};
[bcidata, state] = load_bcidat(subjis);
bcidata = double(bcidata);
bcidata = bcidata(:, 1:64);
samples = 240;

[hb, ha] = butter(4, 5/(1220/2), 'high');
[hgb, hga] = butter(4, [70 90]/(1220/2));
[hgb2, hga2] = butter(4, [90 110]/(1220/2));
[hgb3, hga3] = butter(4, [110 130]/(1220/2));
[hgb4, hga4] = butter(4, [130 150]/(1220/2));
[bb, ba] = butter(4, [10 30]/(1220/2));
hstate = [];
% hgstate = [];
% hg2state = [];
% hg3state = [];
% hg4state = [];
% bstate = [];

relevantchans = [1:64];
% relevantchans = [46:47 54:55];
bcidata = bcidata(:, relevantchans);
%% iterative filter

startpoints = 1:samples:size(bcidata);
i = 1;
% signal = zeros(5000, 128);
signal = zeros(8000, length(relevantchans)*7);
circbuff = nan(5*10, length(relevantchans)*7);
outputs = zeros(8000, length(relevantchans)*7);
for(start = startpoints(1:end-1))
    dat = bcidata(start:start+samples-1, :);
    
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

% 
%     signal(i, :) = [hg beta];
    signal(i, :) = [hg hg2 hg3 hg4 hgmax hg2max beta];
    circbuff = [signal(i, :); circbuff(1:end-1, :)];
    zcircbuff = zscore(circbuff(~any(isnan(circbuff), 2), :), [], 1);
    outputs(i, :) = zcircbuff(1, :);
    i = i+1;
end

hgorig = outputs(1:i-1, :);

%%
% welchsig = zeros(5000, length(relevantchans)*43);
% startpoints = 1:samples:size(bcidata);
% i = 1;
% 
% for(start = startpoints(1:end-1))
%     for(j = 1:length(relevantchans))    
%         dat = bcidata(start:start+samples-1, :);
%         [Pxx, F] = pwelch(dat, [], [], [], 1221);
%         welchsig(i, 43*(j-1)+1:43*(j-1)+43) = Pxx(1:43)';
%     end
%     i = i+1;
% end
% 
% welchorig = welchsig(1:i-1, :);

%% load glove
glove1 = loadCalibratedGlove(subjis)';
[~, glovepca] = pca(glove1);
glovepcadown = binevery(glovepca, samples);
glovediff = [zeros(1, size(glovepcadown,2)); diff(glovepcadown)];
glovediff = glovediff(:, 1:2);
%% method 1, not working
% syn1 = abs(glovediff(:, 1)) > 0.03 & abs(glovediff(:, 2)) < 0.03;
% syn2 = abs(glovediff(:, 2)) > 0.03 & abs(glovediff(:, 1)) < 0.03;
% syn12 = abs(glovediff(:, 1)) > 0.03 & abs(glovediff(:, 2)) > 0.03;
% syn0 = abs(glovediff(:, 1)) < 0.03 & abs(glovediff(:, 2)) < 0.03;
% classmask = (syn1*1 + syn2*2 + syn12*12);
%% method 2
glovediffnorm = glovediff ./ repmat(max(glovediff), [size(glovediff, 1) 1]);
syn0 = abs(glovediff(:, 1)) < 0.03 & abs(glovediff(:, 2)) < 0.03;

syn1 = abs(glovediff(:, 1)) > 0.03 & abs(glovediffnorm(:, 1)) > abs(glovediffnorm(:, 2));
syn2 = abs(glovediff(:, 2)) > 0.03 & abs(glovediffnorm(:, 2)) > abs(glovediffnorm(:, 1));

syn1n = abs(glovediff(:, 1)) > 0.03 & (glovediffnorm(:, 1) - glovediffnorm(:, 2)) > 0.15;
syn2n = abs(glovediff(:, 1)) > 0.03 & (glovediffnorm(:, 2) - glovediffnorm(:, 1)) > 0.15;

syn1orig = hgorig(syn1n, :);
syn2orig = hgorig(syn2n, :);
syn0orig = hgorig(syn0, :);
syn0orig = syn0orig(randperm(size(syn0orig, 1)), :);
syn0orig = syn0orig(1:round((sum(syn1n)+sum(syn2n))/2), :);
%%
classmask = (syn1n*1 + syn2n*2);
% directionpredictor = ClassificationDiscriminant.fit(hgorig, classmask);
%%
directionpredictor = ClassificationDiscriminant.fit([syn1orig; syn2orig; syn0orig], [ones(size(syn1orig, 1), 1); ones(size(syn2orig, 1), 1)*2; zeros(size(syn0orig, 1), 1)]);
%%
save('directionpredictor.mat', 'directionpredictor');