load('ALL_table.mat');

%getting the words that were well done (>3) at each SOA 

ALL_table_sorted_slope = sortrows(ALL_table, {'image_jpg', 'slope'});

well_done_66 = ALL_table_sorted_slope;
well_done_266 = ALL_table_sorted_slope;

well_done_266(well_done_266.mean_response_SOA266 <3, :) = [];
well_done_66(well_done_66.mean_response_SOA66 <3, :) = [];

ALL_table_adjusted = ALL_table_sorted_slope;
ALL_table_adjusted(:,3:7) = []; 

ALL_table_adjusted_1 = outerjoin(ALL_table_adjusted,well_done_266);
ALL_table_adjusted_1(:,[3,5:8]) = [];
ALL_table_adjusted_1.Properties.VariableNames(2) = {'word'};

ALL_table_adjusted_2 = outerjoin(ALL_table_adjusted_1, well_done_66);

ALL_table_adjusted_2(:,[5,7:9,11]) = [];

ALL_table_adjusted_2.Properties.VariableNames([1 2]) = {'image_jpg','word'};

ALL_table_adjusted_2 = sortrows(ALL_table_adjusted_2, 'image_jpg');

globalness_subj_266 = sortrows(ALL_table, {'image_jpg', 'subj_assignment_266masked'}, {'ascend', 'descend'});

globalness_subj_266(:,[1,3,5:7])=[];
globalness_subj_266.Properties.VariableNames(1) = {'globalness_subj_266'};
ALL_table_adjusted_3 = [ALL_table_adjusted_2, globalness_subj_266];


globalness_subj_fullyseen = sortrows(ALL_table, {'image_jpg', 'subj_assignment_fullyseen'}, {'ascend', 'descend'});

globalness_subj_fullyseen(:,[1,3:4,6:7])= [];
globalness_subj_fullyseen.Properties.VariableNames(1) = {'globalness_subj_fullyseen'};
ALL_table_adjusted_4 = [ALL_table_adjusted_3, globalness_subj_fullyseen];

%concate all data that is from SOA experiment together to compare each
%image in part 



