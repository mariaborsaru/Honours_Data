
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

%% analsyis MOST G/S experiment 

raw_table = readtable('MOST_GS_ALL_SOA.csv');

%Group by ID number, and return only rows corresponding to groups with more than two samples.
%in the future make the 1122 a variable which calculates the largest number
%of responses from the table

raw_filtered = groupfilter(raw_table,'subject',@(x) numel(x) >= 1122);

%filter by SOA
filtered_66 = groupfilter(raw_filtered,'subject',@(x) all(x == "66ms"),'SOA');
filtered_266 = groupfilter(raw_filtered,'subject',@(x) all(x == "266ms"),'SOA');

%pick table to use from here on: (in filtered_SOA)- can be changed

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
merged_tables_SOA266 = outerjoin(sort_word_image_SOA266, slope_raw_table,'MergeKeys',true);
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

%need to have 3.5--3.5 for the range correction


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

decision_slope_final_SOA266 = [unique_slope, average_response_per_slope_SOA266];

x_SOA266 = decision_slope_final_SOA266(:,1);
y_SOA266 = decision_slope_final_SOA266(:,2);
sz = 25;
scatter_SOA266 = scatter(x_SOA266,y_SOA266,sz,'filled');

%merge unique_image_word_combo and decision_slope_final
 
%decision_slope_final to table 

decision_slope_final_table = array2table(decision_slope_final_SOA266(:,2), 'VariableNames', {'mean'});

mean_decision_and_all_table = [unique_SOA266, decision_slope_final_table];

%sort by slope and look at the images and words over >3 
sorted_table_all = sortrows(mean_decision_and_all_table, {'mean'});








