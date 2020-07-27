
%% SLOPE

slope_raw_table = readtable('slope_table_first41.csv');

slope_raw_table.Properties.VariableNames = {'image_ID' 'word' 'slope' 'type'};

%convert image_ID (just number) to whole image_jpg name (to match ID names
%on raw_data table)
image_file_list = cell(length(slope_raw_table.image_ID),1);

for row = 1 : length(image_file_list)
    image_id = slope_raw_table.image_ID(row);
    
    image_id_long = sprintf('%07d', image_id);

    image_id_jpg = ['im' image_id_long '.jpg'];
    
    image_file_list{row} = image_id_jpg;
    
end

%convert cell to table
image_file_list = cell2table(image_file_list,'VariableNames',{'image_jpg'});

%concate to slope_raw_table
slope_raw_table = [slope_raw_table image_file_list]; 

%change words that have '-' to proper words - to match words on raw_data_table 
slope_raw_table.word(110) = {'train-track'};
slope_raw_table.word(114) = {'railway-track'};
slope_raw_table.word(211) = {'shoping-cart'};
slope_raw_table.word(236) = {'open-road'};

clearvars -except slope_raw_table


%% %% MOST_GS experiment: SOA 66 

raw_table = readtable('MOST_GS_ALL_SOA.csv');

%Group by ID number, and return only rows corresponding to groups with more than two samples.
%in the future make the 1122 a variable which calculates the largest number
%of responses from the table

raw_filtered = groupfilter(raw_table,'subject',@(x) numel(x) >= 1122);

%filter by SOA
filtered_66 = groupfilter(raw_filtered,'subject',@(x) all(x == "66ms"),'SOA');
filtered_266 = groupfilter(raw_filtered,'subject',@(x) all(x == "266ms"),'SOA');

%filter by present trial 
present_trial_filter_SOA66 = groupfilter(filtered_66,'subject', @(x) (x == "present_trial"),'trialcode');

%sort by word and imageName 
sort_word_image_SOA66 = sortrows(present_trial_filter_SOA66, {'stimulusitem19', 'values_imageName'});

%delete the unneeded column
sort_word_image_SOA66(:,[2:5, 8:43, 45, 46])= [];

%rename the table titles 
sort_word_image_SOA66.Properties.VariableNames = {'subject' 'response' 'image_jpg' 'word'};

%for ever word and image that is the same in slope_raw_table and sort word
%image - add the slope value in the sort_word_image (call it
%word_slope_response)
merged_tables_SOA66 = outerjoin(sort_word_image_SOA66,slope_raw_table,'MergeKeys',true);
merged_tables_SOA66 = sortrows(merged_tables_SOA66, {'image_jpg', 'word'});

%remove unwanted columns
merged_tables_SOA66(:,[5,7])= [];

%remove all NaN elements 
merged_tables_SOA66=rmmissing(merged_tables_SOA66); 
%because the slope_table comes from another Zhao's original slopes generation for all the images 
%there are some images that don't meet the criteria (3 specific and 3
%global) which were included in the original slope generation and thus
%slope_raw_table but are not in the experiment and thus not in the raw_data
%so must do this step to filter out any such occurences 

%replace all responses with numerical value 
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"yes_4",{'3.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"yes_3",{'2.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"yes_2",{'1.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"yes_1",{'0.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"no_1",{'-0.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"no_2",{'-1.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"no_3",{'-2.5'});
merged_tables_SOA66.response = strrep(merged_tables_SOA66.response,"no_4",{'-3.5'});

%find the mean for each unique image+word combination 

%modified_table = merged_tables_sorted(:,[3:5]);
[unique_SOA66, ~, idx_idx_uniq_SOA66] = unique(merged_tables_SOA66(:,3:5));

%failsafe to make sure all the unique image word combos have 11 responses
%each 
a_counts = accumarray(idx_idx_uniq_SOA66,1);

%ADD A CODE IN HERE THAT SAYS IF A_COUNT ISN'T ALL THE SAME THEN SHOW ERROR 

%make the response column into a matrix array to be able to modulate the
%parameters
decision_mat_SOA66 = table2array(merged_tables_SOA66(:,2));

decision_conf_mat_SOA66 = double(cat(2,idx_idx_uniq_SOA66, decision_mat_SOA66));

idx_SOA66 = decision_conf_mat_SOA66(:,1);
average_response_per_slope_SOA66 = arrayfun(@(i) mean(decision_conf_mat_SOA66(idx_SOA66 == i, 2)), unique(idx_SOA66), 'UniformOutput', false);
average_response_per_slope_SOA66 = cell2mat(average_response_per_slope_SOA66);


unique_slope = unique_SOA66.slope;

%% MOST GS experiment 266

filtered_266 = groupfilter(raw_filtered,'subject',@(x) all(x == "266ms"),'SOA');

%filter by present trial 
present_trial_filter_SOA266 = groupfilter(filtered_266,'subject', @(x) (x == "present_trial"),'trialcode');

%sort by word and imageName 
sort_word_image_SOA266 = sortrows(present_trial_filter_SOA266, {'stimulusitem19', 'values_imageName'});

%delete the unneeded column
sort_word_image_SOA266(:,[2:5, 8:43, 45, 46])= [];

%rename the table titles 
sort_word_image_SOA266.Properties.VariableNames = {'subject' 'response' 'image_jpg' 'word'};


%for ever word and image that is the same in slope_raw_table and sort word
%image - add the slope value in the sort_word_image (call it
%word_slope_response)
merged_tables_SOA266 = outerjoin(sort_word_image_SOA266,slope_raw_table,'MergeKeys',true);
merged_tables_SOA266 = sortrows(merged_tables_SOA266, {'image_jpg', 'word'});

%remove unwanted columns
merged_tables_SOA266(:,[5,7])= [];

%remove all NaN elements 
merged_tables_SOA266=rmmissing(merged_tables_SOA266); 
%because the slope_table comes from another Zhao's original slopes generation for all the images 
%there are some images that don't meet the criteria (3 specific and 3
%global) which were included in the original slope generation and thus
%slope_raw_table but are not in the experiment and thus not in the raw_data
%so must do this step to filter out any such occurences 

%replace all responses with numerical value 
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"yes_4",{'3.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"yes_3",{'2.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"yes_2",{'1.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"yes_1",{'0.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"no_1",{'-0.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"no_2",{'-1.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"no_3",{'-2.5'});
merged_tables_SOA266.response = strrep(merged_tables_SOA266.response,"no_4",{'-3.5'});

%find the mean for each unique image+word combination 

%modified_table = merged_tables_sorted(:,[3:5]);
[unique_SOA266, ~, idx_idx_uniq_SOA266] = unique(merged_tables_SOA266(:,3:5));


%failsafe to make sure all the unique image word combos have 11 responses
%each 
a_counts_SOA266 = accumarray(idx_idx_uniq_SOA266,1);

%ADD A CODE IN HERE THAT SAYS IF A_COUNT ISN'T ALL THE SAME THEN SHOW ERROR 

%make the response column into a matrix array to be able to modulate the
%parameters
decision_mat_SOA266 = table2array(merged_tables_SOA266(:,2));

decision_conf_mat_SOA266 = double(cat(2,idx_idx_uniq_SOA266,decision_mat_SOA266));

idx_SOA266 = decision_conf_mat_SOA266(:,1);
average_response_per_slope_SOA266 = arrayfun(@(i) mean(decision_conf_mat_SOA266(idx_SOA266 == i, 2)), unique(idx_SOA266), 'UniformOutput', false);
average_response_per_slope_SOA266 = cell2mat(average_response_per_slope_SOA266);


unique_slope = unique_SOA266.slope;

%% Filter raw table of: Subjective Global Speciifc Allocations - 266 masked 

raw_table_subj_gs = readtable('dt_subjective_gs_MASTER_raw.csv');

%Group by ID number, and return only rows corresponding to groups with more than two samples.
%in the future make the 1122 a variable which calculates the largest number
%of responses from the table

raw_filtered = groupfilter(raw_table_subj_gs,'subject',@(x) numel(x) >= 606);

%filter by SOA
filtered_266masked = groupfilter(raw_filtered,'subject',@(x) all(x == "266 masked"),'type');

%filter by present trial 
present_trial_filter_266masked = groupfilter(filtered_266masked,'subject', @(x) (x == "present_trial"),'trialcode');

%sort by word and imageName 
sort_word_image_subj_266masked = sortrows(present_trial_filter_266masked, {'stimulusitem17', 'values_imageName'});

%delete the unneeded column
sort_word_image_subj_266masked(:,[2:5, 8:39,42])= [];

%rename the table titles 
sort_word_image_subj_266masked.Properties.VariableNames = {'subject' 'response' 'image_jpg' 'word' 'gl_sp_identifyer'};

%for ever word and image that is the same in slope_raw_table and sort word
%image - add the slope value in the sort_word_image (call it
%word_slope_response)
merged_tables_subj_266masked = outerjoin(sort_word_image_subj_266masked,slope_raw_table,'MergeKeys',true);
merged_tables_subj_266masked = sortrows(merged_tables_subj_266masked, {'image_jpg', 'word'});

merged_tables_subj_266masked(:,[6])= [];

merged_tables_subj_266masked=rmmissing(merged_tables_subj_266masked); 


%replace all responses with numerical value 
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_4",{'8'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_3",{'7'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_2",{'6'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_1",{'5'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_1",{'4'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_2",{'3'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_3",{'2'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_4",{'1'});


%% Find mean for each unique image word combination (subjective allocation masked 266)

%find the mean for each unique image+word combination 

%modified_table = merged_tables_sorted(:,[3:5]);
[unique_subj_266masked, ~, idx_idx_uniq_subj_266masked] = unique(merged_tables_subj_266masked(:,[3,4,6]));

%failsafe to make sure all the unique image word combos have n responses
%each 
a_counts_subj_266masked = accumarray(idx_idx_uniq_subj_266masked,1);


%make the response column into a matrix array to be able to modulate the
%parameters
decision_mat_subj_266masked = table2array(merged_tables_subj_266masked(:,2));

decision_conf_mat_subj_266masked = double(cat(2,idx_idx_uniq_subj_266masked,decision_mat_subj_266masked));

idx_subj_266masked = decision_conf_mat_subj_266masked(:,1);
average_subj_assignment_266masked = arrayfun(@(i) mean(decision_conf_mat_subj_266masked(idx_subj_266masked == i, 2)), unique(idx_subj_266masked), 'UniformOutput', false);
average_subj_assignment_266masked = cell2mat(average_subj_assignment_266masked);

unique_slope = unique_subj_266masked.slope;

%add mean subjective_assignment to all table
ALL_table = [unique_subj_266masked table(average_subj_assignment_266masked, 'VariableNames', {'subj_assignment_266masked'})];

%plot on scatterplot
decision_slope_final_subj_266masked = [unique_slope, average_subj_assignment_266masked];

x_266masked = decision_slope_final_subj_266masked(:,1);
y_266masked = decision_slope_final_subj_266masked(:,2);
sz = 25;
scatter_subj_266masked = scatter(x_266masked,y_266masked,sz,'filled');

%% Subjective Global Speciifc allocations - fullyseen 


filtered_fullyseen = groupfilter(raw_filtered,'subject',@(x) all(x == "Fullyseen"),'type');

%filter by present trial 
present_trial_filter_fullyseen = groupfilter(filtered_fullyseen,'subject', @(x) (x == "present_trial"),'trialcode');

%sort by word and imageName 
sort_word_image_subj_fullyseen = sortrows(present_trial_filter_fullyseen, {'stimulusitem17', 'values_imageName'});

%delete the unneeded column
sort_word_image_subj_fullyseen(:,[2:5, 8:39,42])= [];

%rename the table titles 
sort_word_image_subj_fullyseen.Properties.VariableNames = {'subject' 'response' 'image_jpg' 'word' 'gl_sp_identifyer'};

%insert and change the slope_raw table (probably won't need this)- can just
%insert the outcome from the other analysis ??? 


%for ever word and image that is the same in slope_raw_table and sort word
%image - add the slope value in the sort_word_image (call it
%word_slope_response)
merged_tables_subj_fullyseen = outerjoin(sort_word_image_subj_fullyseen,slope_raw_table,'MergeKeys',true);
merged_tables_subj_fullyseen = sortrows(merged_tables_subj_fullyseen, {'image_jpg', 'word'});

merged_tables_subj_fullyseen(:,[6])= [];

merged_tables_subj_fullyseen=rmmissing(merged_tables_subj_fullyseen); 

%replace all responses with numerical value 
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_4",{'8'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_3",{'7'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_2",{'6'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_1",{'5'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_1",{'4'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_2",{'3'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_3",{'2'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_4",{'1'});

%find the mean for each unique image+word combination 

%modified_table = merged_tables_sorted(:,[3:5]);
[unique_subj_fullyseen, ~, idx_idx_uniq_subj_fullyseen] = unique(merged_tables_subj_fullyseen(:,[3,4,6]));

%failsafe to make sure all the unique image word combos have n responses
%each 
a_counts_subj_fullyseen = accumarray(idx_idx_uniq_subj_fullyseen,1);

%make the response column into a matrix array to be able to modulate the
%parameters
decision_mat_subj_fullyseen = table2array(merged_tables_subj_fullyseen(:,2));

decision_conf_mat_subj_fullyseen = double(cat(2,idx_idx_uniq_subj_fullyseen,decision_mat_subj_fullyseen));

idx_subj_fullyseen = decision_conf_mat_subj_fullyseen(:,1);
average_subj_assignment_fullyseen = arrayfun(@(i) mean(decision_conf_mat_subj_fullyseen(idx_subj_fullyseen == i, 2)), unique(idx_subj_fullyseen), 'UniformOutput', false);
average_subj_assignment_fullyseen = cell2mat(average_subj_assignment_fullyseen);

unique_slope = unique_subj_fullyseen.slope;

%add mean subjective_assignment to All table 
ALL_table = [ALL_table table(average_subj_assignment_fullyseen, 'VariableNames', {'subj_assignment_fullyseen'})];

decision_slope_final_subj_fullyseen = [unique_slope, average_subj_assignment_fullyseen];

x_fullyseen = decision_slope_final_subj_fullyseen(:,1);
y_fullyseen = decision_slope_final_subj_fullyseen(:,2);
sz = 25;
scatter_subj_fullyseen = scatter(x_fullyseen,y_fullyseen,sz,'filled');


%% Add to all table

%add mean subjective_assignment to All table 
ALL_table = [ALL_table table(average_response_per_slope_SOA66, 'VariableNames', {'mean_response_SOA66'})];

decision_slope_final = [unique_slope, average_response_per_slope_SOA66];

x_SOA66 = decision_slope_final(:,1);
y_SOA66 = decision_slope_final(:,2);
sz = 25;
scatter_SOA66 = scatter(x_SOA66,y_SOA66,sz,'filled');

%merge unique_image_word_combo and decision_slope_final
 
%decision_slope_final to table 

%decision_slope_final_table = array2table(decision_slope_final(:,2), 'VariableNames', {'mean'});

%mean_decision_and_all_table = [unique_SOA66, decision_slope_final_table];

%sort by slope and look at the images and words over >3 
%sorted_table_all = sortrows(mean_decision_and_all_table, {'mean'});

%add mean subjective_assignment to All table 
ALL_table = [ALL_table table(average_response_per_slope_SOA266, 'VariableNames', {'mean_response_SOA266'})];

%mean response vs. mean subjective allocation 
masked = table2array(ALL_table(:,4));
fullyseen = table2array(ALL_table(:,5));
SOA66 = table2array(ALL_table(:,6));
SOA266 = table2array(ALL_table(:,7));

sz = 25;

%mean response fully seen vs. mean subjective allocation SOA66

scatter_SOA66_fullyseen = scatter(fullyseen,SOA66,sz,'filled');

%mean response fully seen vs. mean subjective allocation SOA266

scatter_SOA266_fullyseen = scatter(fullyseen,SOA266,sz,'filled');

%mean response 266 masked vs. mean subjective allocation SOA66

scatter_SOA66_masked = scatter(masked,SOA66,sz,'filled');

%mean response 266 masked vs. mean subjective allocation SOA266

scatter_SOA266_masked = scatter(masked,SOA266,sz,'filled');

%globalness fully seen to globalness masked 

scatter_fullyseen_masked = scatter(masked,fullyseen,sz,'filled');

%performance on SOA266 vs SOA66

scatter_SOA66_SOA266 = scatter(SOA266,SOA66,sz,'filled');

colour_scatter = gscatter(SOA266,SOA66,ALL_table.image_jpg);

ALL_table_sorted_gs = sortrows(ALL_table, {'image_jpg', 'slope'});

%% Mean across all words within an image (collapsed into 40 images] 

[unique_image, ~, idx_idx_uniq_image] = unique(ALL_table(:,[1]));

%failsafe to make sure all the unique image word combos have n responses
%each 
a_counts_unique_image = accumarray(idx_idx_uniq_image,1);


%make the response column into a matrix array to be able to modulate the
%parameters
subj_ass_266masked = 4; 
subj_ass_fullyseen = 5;
response_SOA66 = 6;
response_SOA266 = 7;

%mean across all words within an image for SOA66
decision_mat_image_SOA66 = table2array(ALL_table(:,response_SOA66));

decision_conf_mat_image_SOA66 = double(cat(2,idx_idx_uniq_image, decision_mat_image_SOA66));

idx_image = decision_conf_mat_image_SOA66(:,1);
average_image_SOA66 = arrayfun(@(i) mean(decision_conf_mat_image_SOA66(idx_image == i, 2)), unique(idx_image), 'UniformOutput', false);
average_image_SOA66 = cell2mat(average_image_SOA66);

%mean across all words within an image for SOA266
decision_mat_image_SOA266 = table2array(ALL_table(:,response_SOA266));

decision_conf_mat_image_SOA266 = double(cat(2,idx_idx_uniq_image, decision_mat_image_SOA266));

idx_image = decision_conf_mat_image_SOA266(:,1);
average_image_SOA266 = arrayfun(@(i) mean(decision_conf_mat_image_SOA266(idx_image == i, 2)), unique(idx_image), 'UniformOutput', false);
average_image_SOA266 = cell2mat(average_image_SOA266);


%mean across all words within an image for masked 266
decision_mat_image_masked = table2array(ALL_table(:,subj_ass_266masked));

decision_conf_mat_image_masked = double(cat(2,idx_idx_uniq_image, decision_mat_image_masked));

idx_image = decision_conf_mat_image_masked(:,1);
average_image_masked = arrayfun(@(i) mean(decision_conf_mat_image_masked(idx_image == i, 2)), unique(idx_image), 'UniformOutput', false);
average_image_masked = cell2mat(average_image_masked);


%mean across all words within an image for masked 266
decision_mat_image_fullyseen = table2array(ALL_table(:,subj_ass_fullyseen));

decision_conf_mat_image_fullyseen = double(cat(2,idx_idx_uniq_image, decision_mat_image_fullyseen));

idx_image = decision_conf_mat_image_fullyseen(:,1);
average_image_fullyseen = arrayfun(@(i) mean(decision_conf_mat_image_fullyseen(idx_image == i, 2)), unique(idx_image), 'UniformOutput', false);
average_image_fullyseen = cell2mat(average_image_fullyseen);


%% save

clearvars -except ALL_table...
                  ALL_table_sorted_gs...
                  colour_scatter;
                                     

save 'ALL_table.mat' ALL_table...
                                     ALL_table_sorted_gs...
                                     colour_scatter;








