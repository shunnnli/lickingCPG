% ----------- Session settings -----------
animal_prompt = 'Enter animal id: ';
animal = input(animal_prompt, 's');
iti_prompt = 'Enter iti: ';
iti = input(iti_prompt);
total_trial = 1500000 / iti;
bin_size = 500;

% ------------- Reading _aligned.csv -------------
afiles_path = strcat(animal, '/', 'Data_tables/', '*', '_aligned.csv');
afiles = dir(afiles_path);
afile_num = length(afiles);

% ------------- Reading _rate.csv -------------
rfiles_path = strcat(animal, '/', 'Data_tables/', '*', '_rate.csv');
rfiles = dir(rfiles_path);
rfile_num = length(rfiles);

% ------------- Generating licks/day vs time -------------
disp('Generating licks/day vs time...');
lpd = figure('Name', 'Changes in licks per day');
total_lick = [];

for i = 1:afile_num
    csv_path = strcat(animal, '/', 'Data_tables/', afiles(i).name);
    aligned = csvread(csv_path);
    new_row = [i aligned(size(aligned,1),1)];
    total_lick = [total_lick; new_row];
end

plot(total_lick(:,1), total_lick(:,2));
xlabel('Session day', 'FontSize', 14);
ylabel('Total licks', 'FontSize', 14);
title('Total licks', 'FontSize', 14);
lpd_path = strcat(animal, '/', 'Total/', animal, '_LPD');
saveas(lpd, lpd_path, 'jpeg');

% ------------- Generating licking rate histogram -------------
disp('Generating licking rate histogram...');
lrh = figure('Name', 'Licking rate histogram');
lrh_mat = [];

for i = 1:rfile_num
    csv_path = strcat(animal, '/', 'Data_tables/', rfiles(i).name);
    rate = csvread(csv_path);
    lrh_mat = [lrh_mat vec2mat(rate(:,2), size(rate,1))];
end

% sum = rfile_num * (iti/bin_size);
histogram(lrh_mat, 'BinWidth', 0.1);
xlim([1, 10]);
xlabel('Licking rate (licks/s)', 'FontSize', 14);
ylabel('Counts', 'FontSize', 14);
title('Licking rate', 'FontSize', 14);

lrh_path = strcat(animal, '/', 'Total/', animal, '_LR');
saveas(lrh, lrh_path, 'jpeg');

% ------------- Generating interlick interval histogram -------------
disp('Generating interlick interval histogram...');
ilih = figure('Name', 'Interlick interval histogram');
ilih_mat = [];

for i = 1:afile_num
    csv_path = strcat(animal, '/', 'Data_tables/', afiles(i).name);
    aligned = csvread(csv_path);
    ilih_mat = [ilih_mat vec2mat(aligned(:,6), size(aligned,1))];
end

% lick_sum = sum(total_lick(:,2));
% sum = (lick_sum-afile_num) * 1000;
histogram(ilih_mat/1000, 'BinWidth', 0.001);
xlim([0, 1]);
xlabel('Time (s)', 'FontSize', 14);
ylabel('Counts', 'FontSize', 14);
title('Interlick interval', 'FontSize', 14);

ilih_path = strcat(animal, '/', 'Total/', animal, '_ILI');
saveas(ilih, ilih_path, 'jpeg');

disp('DONE');