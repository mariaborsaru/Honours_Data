%% SLOPE table

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


%% MOST_GS experiment: SOA 66 

raw_table = readtable('MOST_GS_ALL_SOA.csv');

%Group by ID number, and return only rows corresponding to groups with more than two samples.
%in the future make the 1122 a variable which calculates the largest number
%of responses from the table

raw_filtered = groupfilter(raw_table,'subject',@(x) numel(x) >= 1122);

%filter by SOA
filtered_66 = groupfilter(raw_filtered,'subject',@(x) all(x == "66ms"),'SOA');

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

%filter absent trials

%have accuracy column - if else statement 

%% %% MOST GS experiment 266

filtered_266 = groupfilter(raw_filtered,'subject',@(x) all(x == "266ms"),'SOA');

%exclude participants not doing the right thing
filtered_266_logical = filtered_266.subject == 867388467; 

filtered_266(filtered_266_logical,:) =[];

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


%% Subjective allocations - 266 masked 

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
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_4",{'1'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_3",{'2'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_2",{'3'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"yes_1",{'4'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_1",{'5'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_2",{'6'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_3",{'7'});
merged_tables_subj_266masked.response = strrep(merged_tables_subj_266masked.response,"no_4",{'8'});


%% Subjective allocations - fullyseen 

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
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_4",{'1'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_3",{'1'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_2",{'3'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"yes_1",{'4'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_1",{'5'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_2",{'6'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_3",{'7'});
merged_tables_subj_fullyseen.response = strrep(merged_tables_subj_fullyseen.response,"no_4",{'8'});

%% conclusion: 

clearvars -except slope_raw_table ...
                  merged_tables_SOA66 ...
                  merged_tables_SOA266...
                  merged_tables_subj_266masked ...
                  merged_tables_subj_fullyseen

save 'raw_tables_filtered.mat' 'slope_raw_table' ...
                                'merged_tables_SOA66' ...
                                'merged_tables_SOA266' ...
                                'merged_tables_subj_266masked'...
                                'merged_tables_subj_fullyseen';
                            

