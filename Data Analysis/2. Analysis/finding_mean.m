
load('raw_tables_filtered.mat');
load('per_subject_correction.mat');

%pick the table to run from the above loaded tables
table_img_word = merged_tables_SOA266; 

table_img_word.response = double(table_img_word.response);

table_img_word_by_subject = sortrows(table_img_word, {'subject', 'image_jpg'});

%tag the type of word global or specific

type = cell(1,1);

for img = 1:height(table_img_word)
    if table_img_word.slope(img) > 0 
        type(img,1) = {'specific'};
    else type(img,1) = {'global'};
    end
    
end

table_img_word.type = [type];
%% collapse per subject mean 

[unique_subj, ~, idx_uniq_subj] = unique(table_img_word(:,[1]));

a_counts_subj = accumarray(idx_uniq_subj, 1);

decision_conf_mat_subj = [idx_uniq_subj table_img_word.response];

average_subj = arrayfun(@(i) mean(decision_conf_mat_subj(idx_uniq_subj == i, 2)), ...
    unique(idx_uniq_subj), 'UniformOutput', false);

average_subj_table = sortrows([unique_subj array2table(average_subj, 'VariableNames', {'average_subj'})], ...
                                    {'subject'});

average_subj_cell = table2cell(average_subj_table);

average_subj_table_transposed = cell2table(average_subj_cell.');

%% collapse per subject mean per each type

%need to change the end number to 7 if subjective allocation, to 6 if
%performance experiment
[unique_subj_type, ~, idx_uniq_subj_type] = unique(table_img_word(:,[1,6]));

a_counts_subj_type = accumarray(idx_uniq_subj_type, 1);

decision_conf_mat_subj_type = [idx_uniq_subj_type table_img_word.response];

average_subj_type = arrayfun(@(i) mean(decision_conf_mat_subj_type(idx_uniq_subj_type == i, 2)), ...
    unique(idx_uniq_subj_type), 'UniformOutput', false);

average_subj_type_table = sortrows([unique_subj_type array2table(average_subj_type, 'VariableNames', {'average_subj_type'})], ...
                                    {'type' 'subject'});

average_subj_type_cell = table2cell(average_subj_type_table);

average_subj_type_table_transposed = cell2table(average_subj_type_cell.');

%% find the mean for each unique image+word combination 

%change number to signify image, word and slope columns (3,4,6 for
%subjective allocations and 3,4,5 for performance experiment)
[unique_img_word_comb, ~, idx_uniq] = unique(table_img_word(:,[3,4,5]));

%failsafe to make sure all the unique image word combos have n responses each 
a_counts = accumarray(idx_uniq,1);

decision_conf_mat = [idx_uniq table_img_word.response];

%calculate average response per each word and image combination
average_word_img = arrayfun(@(i) mean(decision_conf_mat(idx_uniq == i, 2)), unique(idx_uniq), 'UniformOutput', false);

average_word_img_table = [unique_img_word_comb array2table(average_word_img, 'VariableNames', {'average_word_img'})];

%% collapse per global/specific of image -find mean of global and specific per image 

%find unique image and type 
%change last number to correspond to type column (=6 in performance and =7
%in subjective allocations)
[unique_img_type, ~, idx_uniq_img_type] = unique(table_img_word(:, [3,6]));

a_counts_unique_img_type = accumarray(idx_uniq_img_type,1);

%get mean of 3 global and 3 specific for each image 
decision_conf_mat_img_type = [idx_uniq_img_type table_img_word.response];

average_img_type = arrayfun(@(i) mean(decision_conf_mat_img_type(idx_uniq_img_type == i, 2)), unique(idx_uniq_img_type), 'UniformOutput', false);

%make new table average_img_type_table
average_img_type_table = [unique_img_type cell2table(average_img_type, 'VariableNames', {'average_img_type'})];

average_img_type_table = sortrows(average_img_type_table, {'type', 'image_jpg'});

%% collapse per all words of image:mean across all words within an image for SOA

[unique_image, ~, idx_uniq_image] = unique(average_word_img_table(:,[1]));

%failsafe to make sure all the unique image word combos have n responses
%each 
a_counts_unique_image = accumarray(idx_uniq_image,1);

decision_conf_mat_image = [idx_uniq_image cell2mat(average_word_img_table.average_word_img)];

average_image = arrayfun(@(i) mean(decision_conf_mat_image(idx_uniq_image == i, 2)), unique(idx_uniq_image), 'UniformOutput', false);

average_image_table = [unique_image cell2table(average_image, 'VariableNames', {'average_img'})];

average_img_type_cell = table2cell(average_img_type_table);

average_img_type_table_transposed = cell2table(average_img_type_cell.');

%% save

clearvars -except average_subj_type_table average_subj_type_table_transposed... 
                  average_word_img_table average_img_type_table average_image_table ... 
                  average_img_type_table_transposed...
                  table_img_word_by_subject...
                  average_subj_table;

save 'finding_mean.mat' 'average_subj_type_table' 'average_subj_type_table_transposed'...
                        'average_word_img_table' ...
                        'average_img_type_table' 'average_image_table'... 
                        'average_img_type_table_transposed'...
                        'table_img_word_by_subject'...
                        'average_subj_table';




