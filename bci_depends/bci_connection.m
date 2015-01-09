%% Establishes main connection and test connection once

% Note that BCI2000 always establishes a test connection
% with null data before main connection

% Timeout is 3000 unless specified
% Use inside a loop. It will also autobreak if it receives a
% test connection from BCI2000 (null data).

% When a contentful connection is finally received,
% goodconnection turns true.

function [server_socket, input_socket, input_stream, goodconnection]...
    = bci_connection(port, timeout)
    
    server_socket  = [];
    input_socket  = [];
    input_stream = [];
    goodconnection = false;
    no_data = MException('bci_connection:NoData', ...
    'No data received from the connection');
        % This is for BCI's empty test connections

    if (nargin < 2)
        timeout = 3000; % default timeout
    end
    
	address = java.net.InetAddress.getLocalHost;
	IPaddress = char(address.getHostAddress);
    
    try
        % Set up connection port
        fprintf(1, ['Waiting for BCI2000 - connect to %s' ...
        ':%d (timeout in %gs)\n'], IPaddress, port, timeout/1000);
        server_socket = java.net.ServerSocket(port);
        server_socket.setSoTimeout(timeout);
        
        % If connected
        input_socket = server_socket.accept;
        fprintf(1, '   Received BCI2000 connection on port %d!\n', port);

        % Check for stream validity / if empty test connection
        input_stream   = input_socket.getInputStream;
        pause(0.2);
        bytes_available = input_stream.available;

        if(bytes_available > 0)
            goodconnection = true;
        else
            throw(no_data) % if empty test connection, throw error
        end
        
        % connection is sound, return to bci
        
    catch err % catchall for everything
        % Clean up if sockets have been used
        if ~isempty(server_socket)
            server_socket.close;
        end

        if ~isempty(input_socket)
            input_socket.close;
        end
        
        % Notify if test connection
        if strcmp(err.identifier,'bci_connection:NoData')
            fprintf(1, '   Probable test connection: no data received.\n');
        elseif ~strcmp(err.identifier,'MATLAB:Java:GenericException')
            % Abort if unknown error, because network may be bad
            fprintf(2, err.identifier);
            error('bci_connection.m received an unknown malfunction')
        end
    end
end
