function aligned = align(seq, iti, bin_size)

    aligned = [];
    lick_id = 0;
    last_reward = 0;
    last_rid = 0;
    reward_id = 1;
    lick_start = 0;
    lick_end = 0;
    lick_interval = 0;
    
    for cur_row = 1:size(seq, 1)
        if seq(cur_row,1) == 0 || seq(cur_row,1) == 1
            continue

        elseif seq(cur_row,1) == 5000
            reward_id = reward_id + 1;
            last_reward = seq(cur_row,2);

        elseif seq(cur_row,1) == 2000	
            lick_start = seq(cur_row,2);
            lick_interval = lick_start - lick_end;

        elseif seq(cur_row,1) == 2001	
            lick_end = seq(cur_row,2);
            lick_duration = lick_end - lick_start;
            if lick_start - last_reward < iti/2
                start_aligned = lick_start - last_reward;
            else	
                start_aligned = lick_start - (last_reward + iti);
            end
           
            start_binned = round(start_aligned / bin_size) * bin_size;
            
            if abs(start_aligned) < iti/2
                if start_aligned > 0
                    if last_rid < reward_id
                        last_rid = reward_id;
                    end
                    lick_id = lick_id + 1;
                    output_aligned = [lick_id start_aligned start_binned reward_id lick_duration lick_interval last_reward];
                else
                    if last_rid < reward_id + 1
                        last_rid = reward_id + 1;
                    end
                    lick_id = lick_id + 1;
                    output_aligned = [lick_id start_aligned start_binned reward_id+1 lick_duration lick_interval last_reward];
                end
                aligned = [aligned; output_aligned];
            end

        elseif seq(cur_row,1) == 8000
            continue
        end
    end
end