function [ adroitpath, fieldtrippath, timeout, read_timeout, synergydims, originpos, protosynergies ]...
    = setup_bci( rootpath )
%SETUP_BCI Setup all the AdroitBCI environment
% Sets up the variables and the paths needed for AdroitBCI
adroitpath      = 'C:\Users\jiwu\Dropbox\BCI_Hand\Contribs\Adroit_sim(0.72)\'; % Vikash's Adroit mojoco install
fieldtrippath   = 'C:\Users\jiwu\Dropbox\BCI_Hand\Contribs\fieldtrip-20150305\';
timeout         = 3000; % How long to wait for a BCI2000 connection
read_timeout    = 500/1000; % How long to wait for data lagout during connection
synergydims     = 2;

addpath(rootpath);
addpath([rootpath '/bci_depends/'])
addpath([rootpath '/bci_depends/stoploop/'])
addpath(adroitpath)
addpath([adroitpath 'VizualizerComm/']) % Vikash's network C visualizer
addpath([fieldtrippath 'fileio/'])

originpos = csvread('bci_depends/Toronto_originpos.csv');
protosynergies = csvread('bci_depends/Toronto_synergies.csv');
if(synergydims < size(protosynergies, 2)) % if need to truncate synergies\
    warning(['Warning: Truncating to ' synergydims ' synergies']);
    protosynergies = protosynergies(:, 1:synergydims);
end

end
