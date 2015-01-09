function [] = bci_cleanup( terminate, serverbcisocket, bcisocket, so )
%BCI_CLEANUP Clean up all the sockets

    fprintf('Closing down remaining sockets.\n')
    if(isa(serverbcisocket, 'java.net.ServerSocket'))
        serverbcisocket.close;
    end
    if(isa(bcisocket, 'java.net.Socket'))
        bcisocket.close;
    end

    if(terminate)
        mjcClose(so);
    end
end

