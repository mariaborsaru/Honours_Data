%% raw_table_filtered by absent and present 

load('raw_tables_filtered_with_trialcode.mat');

raw_filtered = tables_SOA66_alltrials;

present_idx = strcmp(raw_filtered.trialcode, 'present_trial');
absent_idx = strcmp(raw_filtered.trialcode, 'absent_trial');

absent_present_idx = or(present_idx, absent_idx);

raw_filtered = raw_filtered(absent_present_idx,:);

%replace all responses with numerical value 
raw_filtered.response = strrep(raw_filtered.response,"yes_4",{'3.5'});
raw_filtered.response = strrep(raw_filtered.response,"yes_3",{'2.5'});
raw_filtered.response = strrep(raw_filtered.response,"yes_2",{'1.5'});
raw_filtered.response = strrep(raw_filtered.response,"yes_1",{'0.5'});
raw_filtered.response = strrep(raw_filtered.response,"no_1",{'-0.5'});
raw_filtered.response = strrep(raw_filtered.response,"no_2",{'-1.5'});
raw_filtered.response = strrep(raw_filtered.response,"no_3",{'-2.5'});
raw_filtered.response = strrep(raw_filtered.response,"no_4",{'-3.5'});

raw_filtered.response = double(raw_filtered.response);

accuracy = zeros(height(raw_filtered),1);

%add accuracy column
for row = 1:height(raw_filtered);
    if raw_filtered.trialcode{row} == "absent_trial" 
        if raw_filtered.response(row) < 0;
            accuracy(row,1) = 1;
        else accuracy(row,1) = 0;
        end
    elseif raw_filtered.trialcode{row} == 'present_trial'
        if raw_filtered.response(row) > 0;
            accuracy(row,1) = 1;
        else accuracy(row,1) = 0;
        end
    end
end

accuracy_table = array2table(accuracy);

raw_filtered = [raw_filtered accuracy_table];

%% collapse by subject mean 

[unique_subj, ~, idx_uniq_subj] = unique(raw_filtered(:,1));

a_counts_subj = accumarray(idx_uniq_subj, 1);

accuracy_mat_subj = [idx_uniq_subj raw_filtered.accuracy];

average_subj = arrayfun(@(i) mean(accuracy_mat_subj(idx_uniq_subj == i, 2)), ...
    unique(idx_uniq_subj), 'UniformOutput', false);

average_subj_table = sortrows([unique_subj array2table(average_subj, 'VariableNames', {'average_subj_accuracy'})], ...
                                    {'subject'});

average_subj_cell = table2cell(average_subj_table);

average_subj_table_transposed = cell2table(average_subj_cell.');

%% %% collapse per all words of image:mean across all words within an image for SOA

[unique_image, ~, idx_uniq_image] = unique(raw_filtered(:,4));

%failsafe to make sure all the unique image word combos have n responses
%each 
a_counts_unique_image = accumarray(idx_uniq_image,1);

accuracy_mat_image = [idx_uniq_image cell2mat({raw_filtered.accuracy})];

average_image = arrayfun(@(i) mean(accuracy_mat_image(idx_uniq_image == i, 2)), unique(idx_uniq_image), 'UniformOutput', false);

average_image_table = [unique_image cell2table(average_image, 'VariableNames', {'average_img'})];

average_img_cell = table2cell(average_image_table);

average_img_table_transposed = cell2table(average_img_cell.');

%% find the mean for each unique image+word combination 

%change number to signify image, word and slope columns (3,4,6 for
%subjective allocations and 3,4,5 for performance experiment)
[unique_img_word_comb, ~, idx_uniq] = unique(raw_filtered(:,[4,5,6]));

%failsafe to make sure all the unique image word combos have n responses each 
a_counts = accumarray(idx_uniq,1);

decision_conf_mat = [idx_uniq raw_filtered.accuracy];

%calculate average response per each word and image combination
average_word_img = arrayfun(@(i) mean(decision_conf_mat(idx_uniq == i, 2)), unique(idx_uniq), 'UniformOutput', false);

average_word_img_table = [unique_img_word_comb array2table(average_word_img, 'VariableNames', {'average_word_img'})];

%% conclusion: 

clearvars -except average_image_table ...
                  average_subj_table...
                  average_word_img_table...
                  average_subj_table_transposed;

