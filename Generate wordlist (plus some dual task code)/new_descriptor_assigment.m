%% Setup

nParticipants = 2; % Planned n = 10
nTrials = 10;
nTrials_practice = 2;
nQuestions = 10;
nQuestions_practice = 10;

nSessions = 1;
sessions = {'fullscreen'}; %maybe ,'quadrant'} also if decide to do the other one

nRuns = 1;
nBlocks = 5;
nBlocks_practice = 5;

%% Load 'Data' file 

% Location of image data
data_dir = 'descriptors/';
data_file = 'frequencyMatrix_lessRemoved_proportion04.mat';

% Location to save experiment setup
results_dir = 'descriptor_assignment/';
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end
results_file = ['descriptorAssignment_nParticipants' num2str(nParticipants) '_nSessions', num2str(nSessions) '_nBlocks' num2str(nBlocks) '_nTrials' num2str(nTrials) '_nQuestions' num2str(nQuestions) '.mat'];


%this is for the image ID generation 

data_dir = 'descriptors/';
data_file = 'frequencyMatrix_lessRemoved_proportion04.mat';

load([data_dir data_file]);



%% Generate a Raw Data_file  

%this is a combination of global_specific and 'normal' 

%create the frequency table 

raw_table = readtable('maria_stem_words.csv');

soa_133 = find(raw_table.soa == "133");
soa_267 = find(raw_table.soa == "267");
soa = [soa_133; soa_267];

table_soa = raw_table(soa, ["img_id", "soa", "stem_word", "frequency"]);

img_word_grouped = table_soa(:, ["img_id", "stem_word"]);
[index, table_freq] = findgroups(img_word_grouped);
grp_frequency = splitapply(@sum, table_soa.frequency, index);

table_freq.total_count = grp_frequency;

id_list = unique(table_freq.img_id);

number_cutoff = 20;
frequency_cutoff = 5;
start_position = 1;

for img_id = 1:length(id_list)
    id_number = id_list(img_id);
    unique_id_index = find(table_freq.img_id == id_number);
    unique_id_table = sortrows(table_freq(unique_id_index, ["img_id", "stem_word", "total_count"]), "total_count", 'descend');
    
    unique_id_cell = table2cell(unique_id_table);
    unique_id_cell = unique_id_cell(1:number_cutoff,:); %don't need this if not going to cutoff words 

    idx_freq = find(cell2mat(unique_id_cell(:,3)) >= frequency_cutoff);
    unique_id_cell = unique_id_cell(idx_freq, :);
    
    row_num = size(unique_id_cell);
    
    end_position = start_position + row_num(1) - 1; 
    
    frequency_final_cell(start_position:end_position, :) = unique_id_cell;
    
    start_position = length(frequency_final_cell) + 1;
    
end


%frequency_final_cell is the new wordlist that only has the top 20 most commonly sited
%words and only if they are agreed on by more than 2 people (done on a
%differnt program)


%call these words with these conditions (top 20 descriptors, frequency >2 and SOA = any,) = normal 
normal_string = 'normal';
for row_number = 1:length(frequency_final_cell)
    frequency_final_cell{row_number, 3} = normal_string;
end

%import another table that has the global/specific status assigned to each
%word 
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

global_specific_df = sortrows(global_specific_df, [1 3]) ;%order from highest to lowest slope number within each image_id 

global_specific_df(:,3) = [];%remove the 'slope' coluumn that has a more continuous degree of globalness and specificness

%combine the two lists and sort them by the image_id
combined_raw_globspec_df = [global_specific_df; frequency_final_cell];
combined_raw_globspec_df = sortrows(combined_raw_globspec_df,1);

%% Wordlist to sorted cell array structure (by image id) 

%convert first row of image IDs to matrix because it is easier to work with
%later on 
image_id_mat = cell2mat(combined_raw_globspec_df(1:end, 1));

%get a unique image id's list and store as id_list
id_list = unique(image_id_mat); 

Data_file = cell(1,1);

%adding the unique image id in the column of the New_data cell array
for index_id = 1:length(id_list)
    
    %add the unique image id's into the new_data cell array
    Data_file{index_id, 1} = id_list(index_id);
    
    
    %find the positions where the image_id is used in the original list
    %(combined list) and get the unique words to be recorded into the 3rd
    %column of new_data 
    positions_of_descriptors = find(image_id_mat == id_list(index_id)); 
    
    %descriptor words variable AND type/label of word variable 
    desc_words = combined_raw_globspec_df(positions_of_descriptors, 2); 
    label_words = combined_raw_globspec_df(positions_of_descriptors, 3);
    
    %all unique descriptor words in 3rd column of Data_file (cell array)
    Data_file{index_id, 2} = unique(desc_words);
    
    %get all the words that are labled specific from the combined list and
    %add them to the 4th column
    idx_positions_specific = find(strcmp(label_words, 'specific'));
    Data_file{index_id,3} = desc_words(idx_positions_specific);
    
    
    %get all the words that are labled global and add them to  column 5 new_data
    idx_positions_global = find(strcmp(label_words, 'global'));
    Data_file{index_id,4} = desc_words(idx_positions_global);
    
    
    %get all the words labled normal and add them to column 6 new_data
    idx_positions_normal_all = find(strcmp(label_words, 'normal'));
    all_normal = desc_words(idx_positions_normal_all); %the words that are 'normal'
    Data_file{index_id,5} = all_normal;
    
    
    %get the words that are only normal (not also in specific or global
    %category) and put them in the 7th column.
    same_words_array = [];
    
    for word = 1:length(all_normal)
        same_words = find(strcmp(desc_words, string(all_normal(word))));
        
        %make sure only the words that do not have a pair (which ==
        %[1,1] are written in the data file
        if numel(same_words) == 1 %meaning that there is no double for the word
            tmp = unique(desc_words(same_words));
            same_words_array{1,word} = tmp{1};
        else same_words_array{1,word} = [];
        end
        
        emptys = cellfun(@isempty,same_words_array);
        same_words_cell = same_words_array(~emptys);
    end
    
    %put the cells that all have separate strings into one
    Data_file{index_id, 6} = same_words_cell;
end

%wordlist_final = cell array with 4 columns: 
%1 = image id, 
%2 = all present words no doubles 
%3 = all specific words for that image
%4 = all global words for that image, 
%5 = all words that are 'normal' - from the frequency data only
%6 = words that are only normal and not specific or global

all_unique_col = 2;
specific_col = 3;
global_col = 4;
normal_col = 5;
only_normal_col = 6;

%% Cell array to Structure 

df_struct = cell2struct(Data_file, {'image_id' ...
                                            'all_present'... 
                                            'specific'...
                                            'global'...
                                            'normal'...
                                            'normal_only'}...
                                            , 2);


%% Wordlist in alphabetical order - just words

%create a wordlist of the words in alphabetical order - and get them to be
%put into wordlist_small and wordlist_unique in the next colum as indicies
%to the wordlist - so you don't have a word twice 


wordlist = df_struct;
word_list = cell(1,1);

word_list_position_counter = 1;

for image_idx = 1:length(wordlist)
    cell_of_words = wordlist(image_idx).all_present;
    
        for counter = 1:length(cell_of_words)
            word = cell_of_words(counter);
            
            if ~any(strcmp(word_list, word)) 
            word_list(word_list_position_counter, 1) = word;
            word_list_position_counter = word_list_position_counter + 1;
            end
            
        end
end

% Sort words in alphabetical order
word_list = sort(word_list);

%% 

%column 8 = word_positions_present
%column 9 = word_positions_absent 

%for all using unique column 

%need to find each word in the word_list and jot down it's position -
%using find 

%in wordlist_final: column 8 = words present index from word_list, 
                   %column 9 = words absent index from word_list.   

for row = 1:length(df_struct);
    unique_column = df_struct(row).all_present;
    all_possible_absent = [1:length(word_list)];
    
    for word_num = 1:numel(unique_column)
        word = unique_column{word_num};
        idx = find(strcmp(word_list, word));
        index_list(word_num) = idx;
    end
    
    df_struct(row).word_positions_present = index_list;
    words_absent_list = setdiff(all_possible_absent, index_list);
    df_struct(row).word_positions_absent = words_absent_list;
    index_list(1,:) = [];
    
end

%get a global/specific word_positions_present (with only 6 words)

%for row = 1:length(df_struct);
 %   inquisit_present = df_struct(row).specific;
 %   inquisit_absent = [random_index];
  %  
  %  for word_num = 1:numel(inquisit_present)
  %      word = inquisit_present{word_num};
  %      idx = find(strcmp(word_list, word));
   %     index_list(word_num) = idx;
    %end
    %
%    df_struct(row).positions_present_inquisit = index_list;
 %   inquisit_absent_list = setdiff(inquisit_absent, index_list);
  %  df_struct(row).word_positions_absent = words_absent_list;
   % index_list(1,:) = [];
    
%end

%% Make the image file list 

conditioned_Data_file = Data_file; %can insert conditions for creating the conditioned_Data_file

image_file_list = cell(length(conditioned_Data_file), 2);

for picture = 1 : length(conditioned_Data_file)
    image_id = conditioned_Data_file(picture,1);
    image_file_list(picture, 1) = image_id;
    
    image_id_long = sprintf('%07d', image_id{1});

    image_id_jpg = ['im' image_id_long '.jpg'];
    image_file_list{picture, 2} = image_id_jpg;
    
end

mask_list = {'mask1.jpg'};
mask_list(2,1) = {'mask2.jpg'};
mask_list(3,1) = {'mask3.jpg'};
mask_list(4,1) = {'mask4.jpg'};
mask_list(5,1) = {'mask5.jpg'};



%% Analysing the number of images with certain conditions 

%parameters that are being analysed = number of words in specific, global,
%normal and normal_only

%analysing how many image_id have >x unique words (eg. in column 3)

present_unique = 5;

position = 1;

for row = 1:length(Data_file)
   
    unique_words = Data_file(row, all_unique_col) ;
    
    if numel(unique_words{1}) >= present_unique
        unique_images(position, :) = Data_file(row);
        position = position + 1;
    end
end

[~, Data_file_idx] = intersect(cell2mat(Data_file(:,1)), cell2mat(unique_images));

df_unique = df_struct(Data_file_idx);

image_file_list_unique = image_file_list(Data_file_idx, :);


% analysing how many & which image_id have >=x global and >=xspecific, and >=1 'only normal' 
%(do not use for now)

%[[present_specific = 2;
%present_global = 2;
%present_normal = 1;

%position_2 = 1; 

%for row = 1:length(Data_file)
   
 %   specific_words = Data_file(row,specific_col) ;
  %  global_words = Data_file(row,global_col); 
   % normal_words = Data_file(row,only_normal_col);
    
    %if numel(specific_words{1}) >= present_specific && ...
     %       numel(global_words{1}) >= present_global && ...
      %      numel(normal_words{1}) >= present_normal 
       % sgn_images(position_2,:) = Data_file(row,1);
        %position_2 = position_2 + 1;
    %end
%end

%[~, Data_file_idx_2] = intersect(cell2mat(Data_file(:,1)), cell2mat(sgn_images));

%df_sgn = df_struct(Data_file_idx_2);

%image_file_list_sgn = image_file_list(Data_file_idx_2);]]

%analysing how many & which images have >=2 global and specific and >=5 unique 
%= which means the other unique can be anything but have at least 5 present words. 

position_3 = 1; 

present_specific = 3;
present_global = 3;

for row = 1:length(Data_file)
   
    specific_words = Data_file(row,specific_col) ;
    global_words = Data_file(row,global_col); 
    unique_words = Data_file(row, all_unique_col) ;
    
    if numel(specific_words{1}) >= present_specific && ...
            numel(global_words{1}) >= present_global
        
        sg_images(position_3,:) = Data_file(row,1);
        position_3 = position_3 + 1;
    end
end

[~, Data_file_idx_3] = intersect(cell2mat(Data_file(:,1)), cell2mat(sg_images));

df_sg = df_struct(Data_file_idx_3);

image_file_list_sg = image_file_list(Data_file_idx_3);


%can use these list to referance if we want to separate certain elements of
%the list of images we use. 

%% Pick final df  and image file list to use 

df_final = df_sg;

%also make image_file_list the same as the choice of data file 

image_file_list = image_file_list_unique; 

%% Take some images for practice blocks 

% Split take some images for practice blocks (which should not be used for real blocks)
% For now will take the first (n practice blocks * n practice trials) images
nImages_practice = nTrials_practice * nBlocks_practice;
Data_practice = df_final(1 : nImages_practice);
image_file_list_practice = image_file_list(1 : nImages_practice, :);
df_final = df_final(nImages_practice+1 : end);
image_file_list = image_file_list(nImages_practice+1 : end, :);

% Assignment data structure
assignments = cell(nParticipants, 1);
for participant = 1 : nParticipants
    assignments{participant} = cell(nSessions, 1);
    for session = 1 : nSessions
        assignments{participant}{session} = struct();
        assignments{participant}{session}.practice = struct();
        assignments{participant}{session}.runs = cell(nRuns, 1);
        for run = 1 : nRuns
            assignments{participant}{session}.runs{run} = cell(nBlocks, 1);
        end
    end
end

%% Assign session order % can get rid of most of this - just keep session 1 - and type of session that we choose
% Session order should be balanced

for participant = 1 : nParticipants
    assignments{participant}{1}.session_type = sessions;
end

%% Assign images and words for each block
% For each participant, we need to:
%   Randomise picture order (and select descriptor to present)
%   Assign pictures to blocks (50% of trials have present descriptors)

for participant = 1 : nParticipants
    for session = 1 : nSessions
        
        % Randomise order of pictures
        picture_order = randperm(length(df_final));
        pictures = df_final(picture_order);
        image_files = image_file_list(picture_order, :); %image_files is the list of images in a random order
        
        % Split pictures into sets for each run/block and for practice
        picture = 1; % Static picture counter across runs/blocks/practice ensures that no picture is used twice within the session
        for run = 1 : nRuns
            for block = 1 : nBlocks
                
                block_setup = struct();
                block_setup.pictures = image_files(picture : picture+nTrials-1, :); % Get pictures
                block_setup.descriptors = zeros(nTrials, nQuestions);
                block_setup.answers = repmat({'a'}, nTrials, nQuestions); %have the original string of answers all 'a' 20x40.
                
                % Specify number of 1's in each row.
                num_present = 5;
                
                % Go down row by row finding positions for numOnes 1's and assign them
                for trials = 1 : nTrials
                    oneLocations = randperm(nQuestions, num_present); % Get locations in this row.
                    locations = [1:nQuestions];
                    notoneLocations = locations(~ismember(locations, oneLocations));
                    
                    present = pictures(picture).word_positions_present;
                    absent = pictures(picture).word_positions_absent;

                    block_setup.descriptors(trials, oneLocations) = randsample(present,num_present);
                    block_setup.descriptors(trials, notoneLocations) = randsample(absent, nQuestions-num_present);
                    
                    block_setup.answers(trials, oneLocations) = {'p'}; %replace the a's with p's at the oneLocations
                    
                    picture = (picture + 1);
                end
                
                assignments{participant}{session}.runs{run}{block} = block_setup;
                
            end
        end
    end
end

%% Create practice blocks
% Practice blocks are identical across sessions (maybe it's ok if words are different?), and among participants

% Create template practice
% Practice setup (essentially a repeat of setting up blocks - can be turned into a function)
practice = cell(nBlocks_practice, 1);
image_files = image_file_list_practice;
pictures = Data_practice;
picture = 1;
for practice_block = 1 : nBlocks_practice
    block_setup = struct();
    block_setup.pictures = image_files(picture : picture+nTrials_practice-1, :); % Get pictures
    block_setup.descriptors = zeros(nTrials_practice, nQuestions_practice);
    block_setup.answers = repmat({'a'}, nTrials_practice, nQuestions_practice);
    
    % Specify number of 1's in each row.
                num_present_practice = 5;
                
                % Go down row by row finding positions for numOnes 1's and assign them
                for trials = 1 : nTrials_practice
                    oneLocations_practice = randperm(nQuestions_practice, num_present_practice); % Get locations in this row.
                    locations_practice = [1:nQuestions_practice];
                    notoneLocations_practice = locations_practice(~ismember(locations_practice, oneLocations_practice));
                    
                    present_practice = pictures(picture).word_positions_present;
                    absent_practice = pictures(picture).word_positions_absent;

                    block_setup.descriptors(trials, oneLocations_practice) = randsample(present_practice,num_present_practice);
                    block_setup.descriptors(trials, notoneLocations_practice) = randsample(absent_practice, nQuestions_practice-num_present_practice);
                    
                    block_setup.answers(trials, oneLocations_practice) = {'p'}; %replace the a's with p's at the oneLocations
                   
                    picture = (picture + 1);
                end
    practice{practice_block} = block_setup;
    assignments{participant}{session}.runs{run}{block} = block_setup;


end

% Assign template practice to all participants
for participant = 1 : nParticipants
    for session = 1 : nSessions
        assignments{participant}{session}.practice = practice;
    end
end

%% conclusion (for script that writes this into inquisit format)

save 'convert_to_inquisit.mat' 'df_sg' 'word_list';

%% Save assignment (only need this for for dual task)
save([results_dir results_file], 'assignments', 'word_list', 'image_file_list', 'mask_list', 'df_sg');

