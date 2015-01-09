function [ terminate, serverbcisocket, bcisocket, bcistream ] = bci_connectloop( port, timeout )
%BCI_CONNECTLOOP Wraps around bci_connection to keep making connections
%   Uses timeout times and makes bci_connection is repeatedly attempted

    goodconnection = false;
    
    tryconnect = stoploop('Press ok to abort attempting connections');
    while(~tryconnect.Stop() && ~goodconnection)
            [serverbcisocket, bcisocket, bcistream, goodconnection]...
                = bci_connection(port, timeout);
    end
    
    % Network loop good, passing on...
    if(goodconnection)
        fprintf(1, '   Good connection to BCI2000!\n');
        terminate = false;
    elseif(tryconnect.Stop()) % only breaks big loop if due to manual click
        terminate = true;
    end
    
    tryconnect.Clear();
    clear tryconnect;

end

