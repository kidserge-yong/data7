classdef smk
    %SMK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        is_start;
        is_newdata;
        
        serial;
        
        iemg;
        emg;
        trigger;
    end
    
    methods
        function obj = smk(port)
            %SMK Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 1   % no port given
                ports = serialportlist
                select = input("Select serial port for SMK EMG array device: ");
                port = ports(select);
            end
            BAUDRATE = 460800;
            byteorder = 'little-endian';
            
            % Set object properties
            obj.serial = serialport(port, BAUDRATE, 'ByteOrder', byteorder, 'DataBits', 8);
            obj.is_start = false;
            obj.is_newdata = false;
            obj.iemg = 0;
            obj.emg = 0;
            obj.trigger = 0;
            
            % Set callback function
            configureCallback(obj.serial, "byte", 69*10, @updatecallback)
            
        end
        
        function obj = startIEMG(obj)
            %"""
            %intial iemg data transmittion from smk array system.
            %return 1 if no problem found
            %"""
            %"AT+IEMGSTRT\r\n"
            
            if obj.serial.NumBytesAvailable > 0
                read(obj.serial, obj.serial.NumBytesAvailable, "uint8");    %Empty memory
            end
            command = string(['AT+IEMGSTRT', char(13), newline]);
            obj.sendCommand(command);
            obj.is_start = true;
            
        end
        
        function obj = startEMG(obj)
            %"""
            %intial emg data transmittion from smk array system.
            %return 1 if no problem found
            %"""
            %"AT+EMGSTRT\r\n"
            
            if obj.serial.NumBytesAvailable > 0
                read(obj.serial, obj.serial.NumBytesAvailable, "uint8");    %Empty memory
            end
            command = string(['AT+EMGSTRT', char(13), newline]);
            obj.sendCommand(command);
            obj.is_start = true;
        end
        
        function obj = stop(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %"AT+STOP\r\n"
            command = string(['AT+STOP', char(13), newline]);
            obj.sendCommand(command);
            obj.is_start = false;
        end
        
        function max_setting(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            %"AT+EMGCONFIG=FFFFFFFF,2000\r\n"
            command = string(['AT+EMGCONFIG=FFFFFFFF,2000', char(13), newline]);
            obj.sendCommand(command);
        end
        
        function obj_setting = check_setting(obj)
            if obj.serial.NumBytesAvailable > 0
                read(obj.serial, obj.serial.NumBytesAvailable, "uint8");    %Empty memory
            end
            
            command = string(['AT+EMGCONFIG?', char(13), newline]);
            obj.sendCommand(command);
            pause(0.5);
            
            if obj.serial.NumBytesAvailable > 0
                obj_setting = char(read(obj.serial, obj.serial.NumBytesAvailable, "uint8"));
            else
                obj_setting = "Setting do not received."
            end
        end
        
        function obj = loaddata(obj)
            if obj.is_start == false
                return
            end
            
            start_byte = 0;
            while start_byte ~= uint8(113) && start_byte ~= uint8(116)  %Loop to find start of emg (116) or iemg (113)
                if obj.serial.NumBytesAvailable > 0
                    start_byte = read(obj.serial, 1, "uint8");
                end
            end
            
            data_byte = read(obj.serial, 68, "uint8");
            % 1 byte -> order 0 to 255
            % 2 to 65 byte -> 2 bytes per data from 1 channel (32 channels)
            % 66 to 68 byte -> 3 bytes for trigger
            if start_byte == uint8(113)
                obj.emg = [];
                obj.iemg = typecast(uint8(data_byte(2:65)), 'uint16');
            elseif start_byte == uint8(116)
                obj.iemg = [];
                obj.emg = typecast(uint8(data_byte(2:65)), 'uint16');
            end
            obj.trigger = data_byte(66:68);
            obj.is_newdata = true;
        end
        
        function [obj, EMG, iEMG] = getEMG(obj)
            if obj.serial.NumBytesAvailable > 0
                obj = obj.loaddata();
            end
            
            EMG = obj.emg;
            iEMG = obj.iemg;
            obj.is_newdata = false;
            
        end
        
        function sendCommand(obj, command)
            %This function send command to the robot via buffer or serial
            %port
            writeline(obj.serial, command);
        end
    end
end

function updatecallback(src, ~)
    read(src, 69*5, "uint8");

end
