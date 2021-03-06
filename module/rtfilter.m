classdef rtfilter
    %RTFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        b, a
        z
        ch_num
    end
    
    methods
        function obj = rtfilter(channel_number, cutoff_frequency)
            %RTFILTER Construct an instance of this class
            % channel_number is the number of channel 
            % cutoff_frequency is cutoff frequency in Hz
            %% Condition check
            assert(channel_number > 0, "The size of channel need to be more than zero")
            assert(cutoff_frequency > 0, "The cutoff frequency need to be more than zero in Hz")
            
            order = 2;
            %cutoff_frequency = 5; % 5 Hz
            sampling_frequency = 250;
            
            radpsam = cutoff_frequency/(sampling_frequency/2);
            [b, a] = butter(order, radpsam);
            z = zeros(channel_number, max(length(a),length(b))-1);
            
            obj.a = a;
            obj.b = b;
            obj.z = z;
            obj.ch_num = channel_number;
        end
        
        function filtered_signal = filtered_chunk(obj, signal)
            %METHOD1 Summary of this method goes here
            % signal is time, channel
            % Detailed explanation goes here
            
            %% Condition check
            assert(size(signal, 2) == obj.ch_num, "The number of channel need to be the same input channel on initialize")
            
            %% Main algorithm
            sample_num = size(signal, 1);
            realt_signal = NaN(size(signal));
            for ch_i = 1:obj.ch_num
                for sample_i = 1:sample_num
                    [realt_signal(sample_i, ch_i), obj.z(ch_i, :)] = filter(obj.b, obj.a, signal(sample_i, ch_i), obj.z(ch_i, :));
                end
            end
            filtered_signal = realt_signal;
        end
        
        function [filtered_signal, obj] = filtered_sample(obj, signal)
            %METHOD1 Summary of this method goes here
            % signal is 1, channel
            % Detailed explanation goes here
            %% Condition check
            assert(size(signal, 2) == obj.ch_num, "The number of channel need to be the same input channel on initialize")
              
            %% Main algorithm
            realt_signal = NaN(1, obj.ch_num);
            sample_i = 1;
            for ch_i = 1:obj.ch_num
               [realt_signal(sample_i, ch_i), obj.z(ch_i, :)] = filter(obj.b, obj.a, signal(sample_i, ch_i), obj.z(ch_i, :));
            end
            filtered_signal = realt_signal;
        end
        
        function obj = resetz(obj)
            %METHOD1 Summary of this method goes here
            % signal is 1, channel
            % Detailed explanation goes here
            %%
            %% Main algorithm
            obj.z = zeros(size(obj.z));
        end
    end
end

