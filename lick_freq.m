% ----------- Session settings -----------
freqON = 0
animal_prompt = 'Enter animal id: ';
animal = input(animal_prompt, 's');
if freqON == 1
    duration_prompt = 'Enter duration: ';
    duration = input(duration_prompt);
else
    duration = 1;
end

% ------------- Reading csv -------------
afiles_path = strcat(animal, '/', '*', '.csv');
afiles = dir(afiles_path);
afile_num = length(afiles);

% ------------- Generating licks/day vs time -------------
disp('Generating licks/day vs time...');
total_lick = 0;
rate = 0;
lf_mat = [];

for i = 1:afile_num
    csv_path = strcat(animal, '/', afiles(i).name);
    seq = csvread(csv_path);
    date = str2num(strtok(afiles(i).name, '.'));
    
    for cur = 1:size(seq,1)
        if seq(cur,1) == 2000
            total_lick = total_lick + 1;
        else
            continue
        end
    end
    rate = total_lick / duration;
%     disp(total_lick);
%     disp(rate);
    
    new_row = [date duration total_lick rate];
    lf_mat = [lf_mat; new_row];
    total_lick = 0;
end

lf_name = strcat(animal, '-lf.csv');
lf_path = strcat(animal, '/', lf_name);
csvwrite(lf_path, lf_mat);
