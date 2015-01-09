%% BCI2000 ECoG <-> Adroit
% w/ Vikash's mj simulation of Adroit arm
% Adroit_sim must be located in the parent of AdroitBCI folder

%% Init
% variables
clear all
import java.net.ServerSocket
import java.io.*
rootpath = pwd();
[adroitpath, port, timeout, read_timeout, synergydims, originpos, protosynergies]...
    = setup_bci(rootpath);
[model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
    = setup_adroit(adroitpath, originpos);

%% Big Loop
terminate = false;
while(~terminate)
    [terminate, serverbcisocket, bcisocket, bcistream, bcistream_reader]...
        = bci_connectloop(port, timeout);
    
    if(~terminate) % good connection
        
    end
end

bci_cleanup(terminate, serverbcisocket, bcisocket, so);