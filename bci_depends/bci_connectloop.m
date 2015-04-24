function [ headerobj ] = bci_connectloop( )
%BCI_CONNECTLOOP Wraps around bci_connection to keep making connections
%   Uses timeout times and makes bci_connection is repeatedly attempted
    import java.net.ServerSocket
    import java.io.*
    
    goodconnection = false;
    
    tryconnect = stoploop('Press ok to abort attempting connections');
    while(~tryconnect.Stop() && ~goodconnection)
        hdr = ft_read_header(filename);
    end
    
    % Network loop good, passing on...
    if(goodconnection)
        fprintf(1, '   Good connection to BCI2000!\n');
        terminate = false;
        d_bcistream = DataInputStream(bcistream);
        bcistream_reader = DataReader(d_bcistream);
    elseif(tryconnect.Stop()) % only breaks big loop if due to manual click
        terminate = true;
        bcistream_reader = [];
    end
    
    tryconnect.Clear();
    clear tryconnect;

end
