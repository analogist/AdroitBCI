function [] = bci_cleanup( serverbcisocket, bcisocket)
%BCI_CLEANUP Clean up all the sockets

    fprintf('Closing down remaining sockets.\n')
    if(isa(serverbcisocket, 'java.net.ServerSocket'))
        serverbcisocket.close;
    end
    if(isa(bcisocket, 'java.net.Socket'))
        bcisocket.close;
    end
end

