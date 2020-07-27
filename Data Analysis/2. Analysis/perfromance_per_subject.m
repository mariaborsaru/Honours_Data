load('raw_tables_filtered.mat');

%pick the table to run from the above loaded tables
table_img_word = merged_tables_SOA66; 

table_img_word.response = double(table_img_word.response);

table_img_word_by_subject = sortrows(table_img_word, {'subject', 'image_jpg'});

unique_subjects = unique(table_img_word_by_subject.subject); 

new_table = zeros(241,length(unique_subjects));

for subj= 1:length(unique_subjects) 
    new_table(1,subj) = unique_subjects(subj); %first column is subject id
    
    index = table_img_word_by_subject.subject == unique_subjects(subj);
    new_table([2:end],subj) = table_img_word_by_subject.response(index,:);
end

