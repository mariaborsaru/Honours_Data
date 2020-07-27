
load('raw_tables_filtered.mat')

%pick the variable to evaluate 
table = merged_tables_SOA66;

%make response column double (numbers) and replace
table.response = double(table.response); 

%single out the subject and response 
mean_calc = table(:,[1,2]);

%calculate mean of responses for each subject
means_table = varfun(@mean,mean_calc,'GroupingVariables','subject');

%calculate the standard deviation for each subject
std_table = varfun(@std,mean_calc,'GroupingVariables', 'subject');

%merge standard deviation and mean table to make it easier later to merge
means_std_table = outerjoin(means_table, std_table,'MergeKeys',true); 

%take out the 'count' column
means_std_table.GroupCount = [];

%insert mean response subject for each subject in original table using
%outerjoin and sort by image and word (like previous)
table_corrected_subj = sortrows(...
    outerjoin(table,means_std_table,'MergeKeys',true)...
    ,{'image_jpg', 'word'});

table_corrected_subj.dxc = table_corrected_subj.response - table_corrected_subj.mean_response;

%this is the formula used for z-score normalisation 
table_corrected_subj.z_score = (table_corrected_subj.response - table_corrected_subj.mean_response)...
    ./table_corrected_subj.std_response;

clearvars -except 'table' 'table_corrected_subj';

save 'per_subject_correction.mat' 'table' 'table_corrected_subj';

%figure out how to name depending on the name of thing chosen 
