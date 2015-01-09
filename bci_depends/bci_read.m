function [ message ] = bci_read( inputstream_reader, readbytes )
%BCI_READ Summary of this function goes here
%   Detailed explanation goes here
    bciJSON = inputstream_reader.readBuffer(readbytes);
    bciJSON = char(bciJSON');

end

