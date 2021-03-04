function reconstructed_data = reconstruct(data, tol)
% data shape is sample, channel
% tol should be 0.01 to 0.08
dbstop if error

    reconstructed_data = zeros(size(data));
    
    
    % main loop
    for j = 1:size(data,2)
        prev = data(1, j);
        missing_count = 0;
        
        sample = data(:, j);
        msample = medfilt1(sample,5);
        data(:, j) = msample;
        
        for i = 1:size(data,1)
            error = abs((data(i, j) - prev));

            if error < tol * (missing_count/10 + 1) % increase tol range 
                if missing_count > 0
                    range = data(i, j) - prev;
                    step = range / missing_count;   % missing_count least is 1
                    if step > 0
                        recon_array = prev:step:data(i, j);
                    else
                        recon_array = zeros(missing_count+1,1) + prev;
                    end
                    reconstructed_data(i-missing_count : i, j) = recon_array;
                else
                    reconstructed_data(i, j) = data(i, j);
                end
                prev = data(i, j);
                missing_count = 0;
            else
                missing_count = missing_count + 1;
            end
        end
    end

end