classdef qbrobot
    %QBROBOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        is_updating;
        serial;
        deviceArray;
        
        update_timer;
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
            
            % Set object properties
            obj.serial = serialport(port, BAUDRATE, 'ByteOrder', byteorder, 'DataBits', 8);
            obj.serial.Timeout = 0.5;
            
            obj.deviceArray = {};
            
            obj.deviceArray = [qbdevice(1, obj.serial), qbdevice(2, obj.serial), qbdevice(3, obj.serial)];
            
            obj.is_updating = false;
            
            % Set callback function
            configureCallback(obj.serial, "byte", 200, @comunication_callback)
        end
        
        function obj = start_autoupdate(obj)
            if obj.is_updating
                fprintf('Already updating.\n')
                return
            end
            obj.update_timer = timer('TimerFcn', {@timer_callback, obj.deviceArray},'Period', 0.05, 'ExecutionMode', 'fixedRate');
            start(obj.update_timer);
            obj.is_updating = true;
        end
        
        function obj = stop_autoupdate(obj)
            if ~obj.is_updating
                fprintf('Update loop is not working, please initial start_autoupdate().\n')
                return
            end
            
            stop(obj.update_timer);
            delete(obj.update_timer);
            obj.is_updating = false;
            
            % wait for last update
            pause(0.5);
            obj = obj.updateData();
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
                obj.deviceArray(id).setPS(position, stiffness);
            end
            outputArg = 1;
        end
        
        function obj = updateData(obj)
%             if ~obj.is_updating
%                 fprintf('Update loop is not working, please initial start_autoupdate().\n')
%                 return
%             end
            
            data = read(obj.serial, 100, "uint8");
            data = strsplit(char(data), '::');
            
            for i=2:length(data)
                subdata = cell2mat(data(i));
                target_id = subdata(1);
                obj.deviceArray(target_id) = obj.deviceArray(target_id).updateData(subdata);
            end
        end
        
        function activate(obj, activate)
            for target_id = 1:length(obj.deviceArray)
                obj.deviceArray(target_id).activate(activate)
            end
        end
        

    end
end

function timer_callback(obj, event, deviceArray)
    for i=1:length(deviceArray)
        deviceArray(i).getPosition();
        deviceArray(i).getCurrent();
    end
    %fprintf('timercalled')
end

function comunication_callback(obj, event)
    read(obj, obj.NumBytesAvailable - 100, "uint8");   % Delete half the data
    %fprintf('comcalled')
end
