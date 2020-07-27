%% Categorise global or specific by subjective allocations and find mean for each subject 

load('raw_tables_filtered.mat');
load('per_subject_correction.mat');

%% find the mean for each unique image+word combination for that selected subjective experiemnt 

%select the subjective categorisation experiment
table = merged_tables_subj_fullyseen; 

table.response = double(table.response);

table_img_word_by_subject = sortrows(table, {'subject', 'image_jpg'});

[unique_img_word_comb, ~, idx_uniq] = unique(table(:,[3,4,6]));

%failsafe to make sure all the unique image word combos have n responses each 
a_counts = accumarray(idx_uniq,1);

mean_globalness_mat = [idx_uniq table.response];

%calculate average response per each word and image combination
mean_globalness_word_img = arrayfun(@(i) mean(mean_globalness_mat(idx_uniq == i, 2)), unique(idx_uniq), 'UniformOutput', false);

mean_globalness_word_img_table = [unique_img_word_comb array2table(mean_globalness_word_img, 'VariableNames', {'mean_globalness'})];

%categorise as specific or global based on mean globalness (<4 global, >4 specific)

% allocate type based on mean_globalness column

type = cell(1,1);

for img = 1:length(mean_globalness_word_img)
    if mean_globalness_word_img{img} < 4.5 
        type(img,1) = {'global'};
    else type(img,1) = {'specific'};
    end
    
end

mean_globalness_word_img_table.type = [type];


%% merge raw tables 

%choose raw performance table to use 
raw_table_performance = merged_tables_SOA266;

raw_table_performance.response = double(raw_table_performance.response);

%merge the two tables (make sure the right mean_globalness table is
%selected in previous script)
table_img_word = outerjoin(raw_table_performance, mean_globalness_word_img_table, 'MergeKeys', true);


%% collapse per subject mean per each type

%need to change the number to be to subject and type columns
[unique_subj_type, ~, idx_uniq_subj_type] = unique(table_img_word(:,[1,7]));

a_counts_subj_type = accumarray(idx_uniq_subj_type, 1);

decision_conf_mat_subj_type = [idx_uniq_subj_type table_img_word.response];

average_subj_type = arrayfun(@(i) mean(decision_conf_mat_subj_type(idx_uniq_subj_type == i, 2)), ...
    unique(idx_uniq_subj_type), 'UniformOutput', false);

average_subj_type_table = sortrows([unique_subj_type array2table(average_subj_type, 'VariableNames', {'average_subj_type'})], ...
                                    {'type' 'subject'});

average_subj_type_cell = table2cell(average_subj_type_table);

average_subj_type_table_transposed = cell2table(average_subj_type_cell.');

%% save

clearvars -except mean_globalness_word_img_table average_subj_type_table average_subj_type_table_transposed;

save 'finding_mean_subj.mat' 'mean_globalness_word_img_table' 'average_subj_type_table' 'average_subj_type_table_transposed';



