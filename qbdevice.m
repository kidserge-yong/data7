classdef qbdevice
    %QBDEVICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        is_useserial;
        
        id;
        serial;
        
        log;
        position;
        current;
    end
    
    methods
        function obj = qbdevice(id, port)
            %QBDEVICE Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 1   % no buffer, port, and id given
                id = 1;
            end
            if nargin < 2   % no buffer and port given
                ports = serialportlist
                select = input("Select serial port: ");
                port = ports(select);
                BAUDRATE = 2000000;
                byteorder = 'little-endian';
                obj.serial = serialport(port, BAUDRATE, 'ByteOrder', byteorder, 'DataBits', 8);
                obj.is_useserial = true;
                buffer = [];
            end
            obj.id = id;
            obj.serial = port;
            obj.log = [];
            
        end
        
        function activate(obj, activate)
            if activate
                command = obj.commandConstructor(128, true, 3);
            else
                command = obj.commandConstructor(128, true, 0);
            end
            obj.sendCommand(command);
        end
        
        function getPosition(obj)
            command = obj.commandConstructor(132);
            obj.sendCommand(command);
        end
        
        function getCurrent(obj)
            command = obj.commandConstructor(133);
            obj.sendCommand(command);
        end
        
        function getPing(obj)
            command = obj.commandConstructor(0);
            obj.sendCommand(command);
        end
        
        function setPosition(obj, position)
            data = [uint8(fix(position / 256)), uint8(mod(position, 256)), uint8(fix(position / 256)), uint8(mod(position, 256))];
            command = obj.commandConstructor(130, true, char(data));
            obj.sendCommand(command);
        end
        
        function setPS(obj, position, stiffness)
            data = [uint8(fix(position / 256)), uint8(mod(position, 256)), uint8(fix(stiffness / 256)), uint8(mod(stiffness, 256))];
            command = obj.commandConstructor(135, true, char(data));
            obj.sendCommand(command);
        end
        
        function calibrate(obj)
            speed = 200;
            repetitions = 10;
            data = [uint8(fix(speed / 256)), uint8(speed), uint8(fix(repetitions / 256)), uint8(repetitions)];
            command = obj.commandConstructor(13, true, char(data));
            obj.sendCommand(command);
        end
        
        function ping(obj)
            command = obj.commandConstructor(0);
            obj.sendCommand(command);
        end
        
        function sendCommand(obj, command)
            %This function send command to the robot via buffer or serial
            %port
            writeline(obj.serial, command);
        end
        
        function message = read(obj)
            count = obj.serial.NumBytesAvailable;
            data = '';
            if count > 0
                data = read(obj.serial, count, "uint8");
            end
            message = char(data);
        end
        
        function command = commandConstructor(obj, command_value, checksum, data)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            % fprintf('%d\n', nargin)
            if nargin < 4 % No data
                com_str = [char(command_value), char(command_value)];
            else
                com_str = [char(command_value), data];
            end
            len_chr = strlength(com_str);
            
            start_str = '::';
            device_id = char(obj.id);
            
            if nargin < 3 % No checksum
                len_chr = char(len_chr);
            else
                len_chr = char(len_chr+1);
            end
            
            command = [start_str, device_id, len_chr, com_str];
            
            if nargin >= 3 % have checksum
                command = [command, obj.checksum(com_str)];
            end
            
        end
        
        function obj = updateData(obj, data)
            % data = '::[device_id][data_length][data][checksum]'
            data = strrep(data, '::', '');
            
            if length(data) < 3    % return in case not enough data
                obj.log = [obj.log; convertCharsToStrings(data)];
                return             
            end
            
            if data(1) ~= char(obj.id)  % return in case id is not match
                obj.log = [obj.log; convertCharsToStrings(data)];
                return
            end
            
            if uint8(obj.checksum(data(3:end))) ~= 0     % return in case checksum is not match
                obj.log = [obj.log; convertCharsToStrings(data)];
                return
            end
            
            if 128 <= data(3) && data(3) <= 146     % return if command is not in command range (128 to 146)
                command = data(3);
            else
                obj.log = [obj.log; convertCharsToStrings(data)];
                return
            end
            
            data_value = data(4:end-1);
            value = typecast(uint8(data_value), 'uint16');
            
            if command == 132
                obj.position = value;
            elseif command == 133
                obj.current = value;
            end
        end
    end
    
    methods ( Access = private )
        function  checknum = checksum(obj, data_buffer, data_length)
            %fprintf( 'Private checksum is running\n' )
            if nargin < 3
                data_length = length(data_buffer);
            end
            
            data = data_buffer;
            
            check = char(0);
            for i = 1:data_length
                check = char(bitxor(double(check), double(data(i))));
                %fprintf('%d, %s\n',double(check), data(i));
            end
            
            checknum = check;
        end
    end
    
end



