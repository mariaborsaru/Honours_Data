%to determine the global and specific words from the data Zhao provided

global_specific_df = readtable('word_generation_slope_by_report_proportion_two_or_more_soa.csv');

global_specific_df = table2cell(global_specific_df); %convert to cell 

global_cell = {'global'};
specific_cell = {'specific'};

for row = 1:length(global_specific_df)
    if global_specific_df{row, 3} >= 0
        global_specific_df{row,4}= specific_cell{1};
    else
        global_specific_df{row,4} = global_cell{1};
    end
    
end

%if we want to arbitrarily cut off at a certain gradient/degree of
%globalness and specificness we can add that code in between here

global_specific_df = sortrows(global_specific_df, [1 3]) ;

image_id_mat = cell2mat(global_specific_df(1:end, 1));
id_list = unique(image_id_mat); 

words_slope = cell(1,4);

start_pos = 1;
end_pos = 6;

for image_num = 1:41
    
    positions_of_descriptors = find(image_id_mat == id_list(image_num));
    
    all_of_image_id = global_specific_df(positions_of_descriptors,:);
    
    %take the first 3 and last 3 and put them into words slope 
    words_slope(start_pos:end_pos, :) = all_of_image_id([1:3 end-2:end],:);
    
    start_pos = start_pos + 6;
    end_pos = end_pos + 6;
    
end

%% conclusion: 
slope_table = cell2table(words_slope(1:end,:));

writetable(slope_table,'slope_table_first41.csv');

clearvars -except slope_table ...
                  global_specific_df;

save 'generate_wordlist_analysis.mat' 'slope_table' ...
                                      'global_specific_df';
                            







    
    
    