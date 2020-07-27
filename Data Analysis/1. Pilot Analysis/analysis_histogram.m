
%create histogram of count no_4-yes_4 for present words with no_4-yes_4 for
%absent words 

raw_table = readtable('MOST_GS_ALL_SOA.csv');

%Group by ID number, and return only rows corresponding to groups with more than two samples.
%in the future make the 1122 a variable which calculates the largest number
%of responses from the table

raw_filtered = groupfilter(raw_table,'subject',@(x) numel(x) >= 1122);

%filter by SOA
filtered_66 = groupfilter(raw_filtered,'subject',@(x) all(x == "66ms"),'SOA');
filtered_266 = groupfilter(raw_filtered,'subject',@(x) all(x == "266ms"),'SOA');

%filter by present trial 
present_trial_filter_SOA266 = groupfilter(filtered_266,'subject', @(x) (x == "present_trial"),'trialcode');

%filter by absent trial 
absent_trial_filter_SOA266 = groupfilter(filtered_266, 'subject', @(x) (x =="absent_trial"),'trialcode');

%count column 6 responses (present)

present_responses = categorical(present_trial_filter_SOA266.response, ...
    {'no_4','no_3','no_2', 'no_1', 'yes_1', 'yes_2','yes_3', 'yes_4'},'Ordinal',true);
[n_present, categories_pres] = histcounts(present_responses);

%count column 6 responses (absent) 

absent_responses = categorical(absent_trial_filter_SOA266.response, ...
    {'no_4','no_3','no_2', 'no_1', 'yes_1', 'yes_2','yes_3', 'yes_4'},'Ordinal',true);
[n_absent, categories_abs] = histcounts(absent_responses);

histogram_present = histogram(present_responses);
hold on
histogram_absent = histogram(absent_responses);





