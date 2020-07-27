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

%filter by absent trial
absent_trial_filter_SOA66 = groupfilter(filtered_66,'subject', @(x) (x == "absent_trial"),'trialcode');

%concate the two filtered table 
trial_filter_SOA66 = [present_trial_filter_SOA66; absent_trial_filter_SOA66];

%sort by word and imageName 
sort_word_image_SOA66 = sortrows(trial_filter_SOA66, {'stimulusitem19', 'values_imageName'});

%delete the unneeded column
sort_word_image_SOA66(:,[2, 4, 5, 8:43, 45, 46])= [];

%rename the table titles 
sort_word_image_SOA66.Properties.VariableNames = {'subject' 'trialcode' 'response' 'image_jpg' 'word'};

%for ever word and image that is the same in slope_raw_table and sort word
%image - add the slope value in the sort_word_image (call it
%word_slope_response)
tables_SOA66_alltrials = outerjoin(sort_word_image_SOA66,slope_raw_table,'MergeKeys',true);
tables_SOA66_alltrials = sortrows(tables_SOA66_alltrials, {'image_jpg', 'word'});

%remove unwanted columns
tables_SOA66_alltrials(:,[6 7])= [];

%fill in the absent trial codes with 'absent' type 
tables_SOA66_alltrials.type(strcmp(tables_SOA66_alltrials.type,'')) = {'absent'};

%remove all NaN elements 
tables_SOA66_alltrials=rmmissing(tables_SOA66_alltrials); 
%because the slope_table comes from another Zhao's original slopes generation for all the images 
%there are some images that don't meet the criteria (3 specific and 3
%global) which were included in the original slope generation and thus
%slope_raw_table but are not in the experiment and thus not in the raw_data
%so must do this step to filter out any such occurences 

%replace all responses with numerical value 
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"yes_4",{'3.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"yes_3",{'2.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"yes_2",{'1.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"yes_1",{'0.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"no_1",{'-0.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"no_2",{'-1.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"no_3",{'-2.5'});
tables_SOA66_alltrials.response = strrep(tables_SOA66_alltrials.response,"no_4",{'-3.5'});

%filter absent trials

%have accuracy column - if else statement 

%% %% MOST GS experiment 266

filtered_266 = groupfilter(raw_filtered,'subject',@(x) all(x == "266ms"),'SOA');

%exclude participants not doing the right thing
filtered_266_logical = filtered_266.subject == 867388467; 

filtered_266(filtered_266_logical,:) =[];

%filter by present trial 
present_trial_filter_SOA266 = groupfilter(filtered_266,'subject', @(x) (x == "present_trial"),'trialcode');

%filter by absent trial
absent_trial_filter_SOA266 = groupfilter(filtered_266,'subject', @(x) (x == "absent_trial"),'trialcode');

%concate the two filtered table 
trial_filter_SOA266 = [present_trial_filter_SOA266; absent_trial_filter_SOA266];

%sort by word and imageName 
sort_word_image_SOA266 = sortrows(trial_filter_SOA266, {'stimulusitem19', 'values_imageName'});

%delete the unneeded column
sort_word_image_SOA266(:,[2, 4, 5, 8:43, 45, 46])= [];

%rename the table titles 
sort_word_image_SOA266.Properties.VariableNames = {'subject' 'trialcode' 'response' 'image_jpg' 'word'};

%for ever word and image that is the same in slope_raw_table and sort word
%image - add the slope value in the sort_word_image (call it
%word_slope_response)
tables_SOA266_alltrials = outerjoin(sort_word_image_SOA266,slope_raw_table,'MergeKeys',true);
tables_SOA266_alltrials = sortrows(tables_SOA266_alltrials, {'image_jpg', 'word'});

%remove unwanted columns
tables_SOA266_alltrials(:,[6,7])= [];

%fill in the absent trial codes with 'absent' type 
tables_SOA266_alltrials.type(strcmp(tables_SOA266_alltrials.type,'')) = {'absent'};

%remove all NaN elements 
tables_SOA266_alltrials=rmmissing(tables_SOA266_alltrials); 
%because the slope_table comes from another Zhao's original slopes generation for all the images 
%there are some images that don't meet the criteria (3 specific and 3
%global) which were included in the original slope generation and thus
%slope_raw_table but are not in the experiment and thus not in the raw_data
%so must do this step to filter out any such occurences 

%replace all responses with numerical value 
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"yes_4",{'3.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"yes_3",{'2.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"yes_2",{'1.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"yes_1",{'0.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"no_1",{'-0.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"no_2",{'-1.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"no_3",{'-2.5'});
tables_SOA266_alltrials.response = strrep(tables_SOA266_alltrials.response,"no_4",{'-3.5'});


%% conclusion: 

clearvars -except slope_raw_table ...
                  tables_SOA66_alltrials ...
                  tables_SOA266_alltrials;

save 'raw_tables_filtered_with_trialcode.mat' 'slope_raw_table' ...
                                'tables_SOA66_alltrials' ...
                                'tables_SOA266_alltrials';
                            

