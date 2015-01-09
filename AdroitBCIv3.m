%% BCI2000 ECoG <-> Adroit
% w/ Vikash's mj simulation of Adroit arm
% Adroit_sim must be located in the parent of AdroitBCI folder

%% Init
% variables
clear all
rootpath        = pwd();
adroitpath      = [fileparts(rootpath) 'Adroit_sim(0.72)/']; % Vikash's Adroit mojoco install
port            = 15998;
timeout         = 3000; % How long to wait for a BCI2000 connection
read_timeout    = 500; % How long to wait for data lagout during connection
synergydims     = 2;

% dependencies
addpath(rootpath);
addpath([rootpath 'bci_depends/'])
addpath(adroitpath)
addpath([adroitpath 'VizualizerComm/']) % Vikash's network C visualizer
javaaddpath([rootpath 'bci_depends/tcp_ip_socket_comms_java/']) % fast entire-buffer reader
import java.net.ServerSocket
import java.io.*

