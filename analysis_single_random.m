% ----------- Trial settings -----------
animal_prompt = 'Enter animal id: ';
animal = input(animal_prompt, 's');
date_prompt = 'Enter the date of the csv file: ';
date = input(date_prompt, 's');
csvfile = strcat(animal, '/', date, '.csv');
duration_prompt = 'Enter the duration of the trial: ';
duration = input(duration_prompt, 's');
chunk = duration/10;

time_limit = 1000;
% time_limit = str2num(duration);

% ------------- Parameters -------------
seq = csvread(csvfile, 0, 0);
start_time = 0;
total_trial = 0;
total_lick = 0;
adj_time = 0; % time since the start of the session in sec
adj_y = 0;  % which 10s chunk does the lick belongs to
adj_x = 0;  % sec in the 10s chunk
cur_reward = 0;
last_reward = 0;
lick_latency = 0;
iti = 0;
sum_latency = 0;
avg_lf = 0;

% ------------ Generating raster plots ------------

disp('Plotting raster plot...');
rp = figure('Name', 'Whole trial raster plot');


for cur = 1:size(seq,1)
    if cur == 1
        start_time = seq(cur,2);
    end
    
    adj_time = (seq(cur,2) - start_time)/1000;
    if adj_time > time_limit
        break;
    end
    
    adj_y = floor(adj_time/10);
    adj_x = rem(adj_time,10);
    
    hold on
    if seq(cur,1) == 5000
        scatter(adj_x * 10, adj_y, 'x','black');
        total_trial = total_trial + 1;
        disp(total_trial);
        
    elseif seq(cur,1) == 2000 
        scatter(adj_x * 10, adj_y, 'filled'); 
        total_lick = total_lick + 1;
    else
        continue
    end
end

ymax = time_limit / 10;
avg_lf = total_lick / time_limit; 
ylim([0 ymax]);
xlabel('Time (s)', 'FontSize', 14);
ylabel('Time (s)', 'FontSize', 14);
title('Single trial raster plot', 'FontSize', 14);

if time_limit == str2num(duration)
    rp_path = strcat(animal, '/', 'Data_plots/', date, '_RP');
else
    rp_path = strcat(animal, '/', 'Data_plots/', date, '_partialRP');
end
saveas(rp, rp_path, 'png');


% ------------ Calculating first lick latency ------------------

fll = figure('Name', 'First lick latency');
total_trial = 0;
for cur = 1:size(seq,1)
    if seq(cur,1) == 5000     
        last_reward = cur_reward;
        cur_reward = seq(cur,2)/1000;
        iti = cur_reward - last_reward;
        total_trial = total_trial + 1;
        
        if cur+1 < size(seq,1) 
            if seq(cur+1,1) == 2000
                lick_latency = seq(cur+1,2)/1000 - cur_reward;
                sum_latency = sum_latency + lick_latency;
                
                hold on
                scatter(iti, lick_latency, 'x');
            else
                continue
            end
        end
    end       
end

avg_latency = sum_latency / total_trial;

xlim([2 10]);
xlabel('ITI (s)', 'FontSize', 14);
ylabel('First lick latency (s)', 'FontSize', 14);
title('ITI vs. First lick latency', 'FontSize', 14);

fll_path = strcat(animal, '/', 'Data_plots/', date, '_fll');
saveas(fll, fll_path, 'png');

disp(total_trial);
disp(total_lick);
disp(avg_latency);
disp(avg_lf);
disp('DONE');