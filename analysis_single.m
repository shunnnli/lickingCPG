% ----------- Trial settings -----------
animal_prompt = 'Enter animal id: ';
animal = input(animal_prompt, 's');
date_prompt = 'Enter the date of the csv file: ';
date = input(date_prompt, 's');
csvfile = strcat(animal, '/', date, '.csv');
iti_prompt = 'Enter iti: ';
iti = input(iti_prompt);
total_trial = 2500000 / iti;

% ---------- Program settings ----------
rp_ON = 1;
prob_combinedON = 1;
prob_combined_num = 3;
max_reward = 2000000000;
bin_size = 500;

% ------------- Parameters -------------
bin_array = zeros(total_trial + 1, (iti/bin_size) + 1);
bin_table = array2table(bin_array);
pp_bin = [];
psth_bin = [];
cur_reward = 0;
lick_count = 0;
duration_total = 0;
lick_rate = 0; % licks/second
max_trial = 0;
color = {'k','b','r','g','y',[.5 .6 .7],[.8 .2 .6]};

% ------------ Generating aligned and binned ------------
disp('Iterating sequence CSV...');
seq = csvread(csvfile, 0, 0);
aligned = align(seq, iti, bin_size);
aligned_sorted = sortrows(aligned,[3 1]);
binned = bin(seq, iti, bin_size, bin_table);

% ------------- Writing aligned csv -------------
disp('Writing aligned CSV...');
aligned_path = strcat(animal, '/', 'Data_tables/', date, '_aligned.csv');
csvwrite(aligned_path, aligned);

% ------------- Plotting Prob plots -------------
pp = figure('Name', 'Probability plot');
cur_bin = -(iti/2);

for cur_row = 1:size(aligned_sorted,1)
    if aligned_sorted(cur_row,3) > cur_bin
        prob = lick_count / size(aligned_sorted,1);
        new_row = [cur_bin prob];
        pp_bin = [pp_bin; new_row];
        cur_bin = cur_bin + bin_size;
        lick_count = 1;
    elseif aligned_sorted(cur_row,3) == cur_bin
        lick_count = lick_count + 1;
    else
        disp('start_aligned smaller than cur_bin!');
    end
end

if prob_combinedON == 0
    disp('Plotting whole-trial prob plots...');
    % plot(pp_bin(:,1), smooth(pp_bin(:,2)));
    plot(pp_bin(:,1), pp_bin(:,2));
    pp_path = strcat(animal, '/', 'Data_plots/', date, '_wholePP');
    saveas(pp, pp_path, 'png');
else
    disp('Plotting sub-trial prob plots...');
    plot(pp_bin(:,1), pp_bin(:,2)); 
    sub_size = total_trial / prob_combined_num;
    for id = 1:3
        cur_bin = -(iti/2);
        subpp_bin = [];
        sub_lick = 0;
        sub_id = id * sub_size;
        for cur_row = 1:size(aligned_sorted,1)
            if aligned_sorted(cur_row,4) < sub_id && aligned_sorted(cur_row,4) >= sub_size * (id - 1)
                sub_lick = sub_lick + 1;
                if aligned_sorted(cur_row,3) > cur_bin
                    new_row = [cur_bin lick_count];
                    subpp_bin = [subpp_bin; new_row];
                    cur_bin = cur_bin + bin_size;
                    lick_count = 1;
                elseif aligned_sorted(cur_row,3) == cur_bin
                    lick_count = lick_count + 1;
                else
                    disp('start_aligned smaller than cur_bin!');
                end
            else
                continue
            end
        end
        if size(subpp_bin,1) > 0
            hold on
            plot(subpp_bin(:,1), (subpp_bin(:,2) / sub_lick));
        end
    end
    
    legend('total', '1', '2', '3')
    xlabel('Time (ms)', 'FontSize', 14);
    ylabel('Probability', 'FontSize', 14);
    title('Probability', 'FontSize', 14);
    
    pp_path = strcat(animal, '/', 'Data_plots/', date, '_subPP');
    saveas(pp, pp_path, 'png');
end

% ------------- Plotting PSTH -------------
disp('Plotting PSTH...');
psth = figure('Name', 'Peri-stimulus Time Histogram');
binned_onesec = binned * (1000/bin_size);
binned_freq = sum(binned_onesec) / size(binned,2);

for id = 1:size(binned,2)
    cur_bin = -(iti/2) + (bin_size * (id-1));
    new_row = [cur_bin binned_freq(1,id)];
    psth_bin = [psth_bin; new_row];
end

plot(psth_bin(:,1), psth_bin(:,2));
xlabel('Time (s)', 'FontSize', 14);
ylabel('Licking rate (licks/s)', 'FontSize', 14);
title('Peri-stimulus Time Histogram', 'FontSize', 14);

psth_path = strcat(animal, '/', 'Data_plots/', date, '_PSTH');
saveas(psth, psth_path, 'png');

% ------------- Writing licking rate csv -------------
disp('Writing licking rate CSV...');
lr_path = strcat(animal, '/', 'Data_tables/', date, '_rate.csv');
csvwrite(lr_path, psth_bin);

% ------------- Plotting raster plot -------------
if rp_ON == 1
    disp('Plotting raster plot...');
    rp = figure('Name', 'Whole trial raster plot');
    
    for cur_row = 1:size(aligned,1)
        cur_reward = aligned(cur_row,4);
        if cur_reward > max_reward
            break
        end
        hold on
        scatter(aligned(cur_row,2), aligned(cur_row,4), 'filled');
    end
    
    ylim([0 total_trial]);
    xlabel('Time (s)', 'FontSize', 14);
    ylabel('Trials', 'FontSize', 14);
    title('Single trial raster plot', 'FontSize', 14);
    
    rp_path = strcat(animal, '/', 'Data_plots/', date, '_singleRP');
    saveas(rp, rp_path, 'png');
end

disp('DONE');