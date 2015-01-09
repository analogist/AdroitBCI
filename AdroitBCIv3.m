%% BCI2000 ECoG <-> Adroit
% w/ Vikash's mj simulation of Adroit arm
% Adroit_sim must be located in the parent of AdroitBCI folder

%% Init
% variables
clear all
rootpath = pwd();
[adroitpath, port, timeout, read_timeout, synergydims, originpos, protosynergies]...
    = setup_bci(rootpath);
[model, act, gain_A, gain_W, gain_F, vizIP, vizDir, so, m, gainP, gainD]...
    = setup_adroit(adroitpath, originpos);

%% Big Loop
terminate = false;
while(~terminate)
    [terminate, goodconnection, serverbcisocket, bcisocket, bcistream, bcistream_reader]...
        = bci_connectloop(port, timeout);
    
    iter = uint32(1);
    while(goodconnection)
        [goodconnection, bciJSON] = bci_read(bcistream_reader, bcistream, read_timeout);
%         bciJSON = bci_parse(bciJSON);
        disp(bciJSON);
        iter = iter+1;
    end
    
    bci_cleanup(serverbcisocket, bcisocket);
end
bci_cleanup(serverbcisocket, bcisocket);
mjcClose(so);
