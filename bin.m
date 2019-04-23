function binned = bin(seq, iti, bin_size, bin_table)

    lick_id = 0;
    last_reward = 0;
    reward_id = 1;
    lick_start = 0;

    % Iterating sequence CSV
    for cur_row = 1:size(seq, 1)
        if seq(cur_row,1) == 0 || seq(cur_row,1) == 1
            continue

        elseif seq(cur_row,1) == 5000
            reward_id = reward_id + 1;
            last_reward = seq(cur_row,2);

        elseif seq(cur_row,1) == 2000	
            lick_start = seq(cur_row,2);

        elseif seq(cur_row,1) == 2001
            if lick_start - last_reward < iti/2
                start_aligned = lick_start - last_reward;
            else	
                start_aligned = lick_start - (last_reward + iti);
            end
           
            start_binned = round(start_aligned / bin_size) * bin_size;
            bin_id = (iti/bin_size) - (((iti/2) - start_binned) / bin_size) + 1;
            
            if abs(start_aligned) < iti/2
                if start_aligned > 0
                    lick_id = lick_id + 1;
                    if reward_id < size(bin_table,1)
                        bin_table{reward_id, bin_id} = bin_table{reward_id, bin_id} + 1;
                    end
                else
                    lick_id = lick_id + 1;
                    if reward_id + 1 < size(bin_table,1)
                        bin_table{reward_id+1, bin_id} = bin_table{reward_id+1, bin_id} + 1;
                    end
                end
            end

        elseif seq(cur_row,1) == 8000
            continue
        end
    end
    
    binned = table2array(bin_table);
end