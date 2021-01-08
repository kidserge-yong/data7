classdef qbrobot
    %QBROBOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serial;
        deviceArray;
    end
    
    methods
        function obj = qbrobot(port)
            %QBROBOT Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 1   % no port given
                ports = serialportlist
                select = input("Select serial port for softhand robot: ");
                port = ports(select);
            end
            BAUDRATE = 2000000;
            byteorder = 'little-endian';
            obj.serial = serialport(port, BAUDRATE, 'ByteOrder', byteorder, 'DataBits', 8);
            
            obj.deviceArray = {};
            
            obj.deviceArray = [qbdevice(1, obj.serial), qbdevice(2, obj.serial), qbdevice(3, obj.serial)];
        end
        
        function outputArg = setPS(obj, id, position, stiffness)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if (0 >= id) || (id >= length(obj.deviceArray))
                fprintf('id: %d out of range, Please enter id between 0 to %d', id, length(obj.deviceArray))
                outputArg = 0;
                return
            end
            
            if obj.deviceArray(id).id == 1
                obj.deviceArray(id).setPosition(position);
            else
                obj.deviceArray(id).setPosition(position, stiffness);
            end
            outputArg = 1;
        end
    end
end

