function [ goodconnection, bciJSON ] = bci_read( bcistream_reader, bcistream, read_timeout )
%BCI_READ Read from the input stream using the Java helper class
% Loops until a good read is achieved, or until timeout occurs.
    
    goodread = false;
    emptycount = tic;
    while( toc(emptycount) < read_timeout )
        bytes_available = bcistream.available;
        if(bytes_available > 0)
            bciJSON = bcistream_reader.readBuffer(bytes_available);
            bciJSON = char(bciJSON');
            goodread = true;
            break;
        end
    end
    if(goodread)
        goodconnection = true;
    else
        bciJSON = '';
        goodconnection = false;
    end
end