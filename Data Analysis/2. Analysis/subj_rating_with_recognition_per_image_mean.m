%% Categorise global or specific by subjective allocations and find mean for each image word

load('raw_tables_filtered.mat');
load('per_subject_correction.mat');

%pick the table to run from the above loaded tables
table = merged_tables_subj_fullyseen; 

table.response = double(table.response);

table_img_word_by_subject = sortrows(table, {'subject', 'image_jpg'});

%% find the mean for each unique image+word combination 

%change number to signify image, word and slope columns (3,4,6 for
%subjective allocations and 3,4,5 for performance experiment)
[unique_img_word_comb, ~, idx_uniq] = unique(table(:,[3,4,6]));

%failsafe to make sure all the unique image word combos have n responses each 
a_counts = accumarray(idx_uniq,1);

mean_globalness_mat = [idx_uniq table.response];

%calculate average response per each word and image combination
mean_globalness_word_img = arrayfun(@(i) mean(mean_globalness_mat(idx_uniq == i, 2)), unique(idx_uniq), 'UniformOutput', false);

mean_globalness_word_img_table = [unique_img_word_comb array2table(mean_globalness_word_img, 'VariableNames', {'mean_globalness'})];

%% categorise as specific or global based on mean globalness (>4 global, <4 specific)

% allocate type based on mean_globalness column

type = cell(1,1);

for img = 1:length(mean_globalness_word_img)
    if mean_globalness_word_img{img} < 4.5 
        type(img,1) = {'global'};
    else type(img,1) = {'specific'};
    end
    
end

mean_globalness_word_img_table.type = [type];

%% find the mean for each unique image+word combination in performance table

performance_table = merged_tables_SOA66;

performance_table.response = double(performance_table.response);

[unique_img_word_comb, ~, idx_uniq] = unique(performance_table(:,[3,4,5]));

%failsafe to make sure all the unique image word combos have n responses each 
a_counts = accumarray(idx_uniq,1);

performance_conf_mat = [idx_uniq performance_table.response];

%calculate average response per each word and image combination
average_word_img = arrayfun(@(i) mean(performance_conf_mat(idx_uniq == i, 2)), unique(idx_uniq), 'UniformOutput', false);

average_word_img_table = [unique_img_word_comb array2table(average_word_img, 'VariableNames', {'average_word_img'})];


%% merge subjective global/specific allocations with performance table

merged_subjective_category_performance = outerjoin(mean_globalness_word_img_table,...
    average_word_img_table,'MergeKeys',true);

%% sort by mean image+category/type (subjective allocation) and average_word_img (performance) =~80 points

[unique_img_type, ~, idx_uniq_img_type] = unique(merged_subjective_category_performance(:, [1,5]));

a_counts_unique_img_type = accumarray(idx_uniq_img_type,1);

%get mean of 3 global and 3 specific for each image 
decision_conf_mat_img_type = [idx_uniq_img_type cell2mat(merged_subjective_category_performance.average_word_img)];

average_img_type = arrayfun(@(i) mean(decision_conf_mat_img_type(idx_uniq_img_type == i, 2)), unique(idx_uniq_img_type), 'UniformOutput', false);

%make new table average_img_type_table
average_subjective_img_type_table = [unique_img_type cell2table(average_img_type, 'VariableNames', {'average_img_type'})];

average_subjective_img_type_table = sortrows(average_subjective_img_type_table, {'type', 'image_jpg'});


average_subjective_img_type_cell = table2cell(average_subjective_img_type_table);

average_subjective_img_type_table_transposed = cell2table(average_subjective_img_type_cell.');


%% save

clearvars -except mean_globalness_word_img_table...
                  merged_subjective_category_performance...
                  average_subjective_img_type_table...
                  average_subjective_img_type_table_transposed;
                                     

save 'subjective_categorisation.mat' mean_globalness_word_img_table...
                                     merged_subjective_category_performance...
                                     average_subjective_img_type_table...
                                     average_subjective_img_type_table_transposed;
                                     




