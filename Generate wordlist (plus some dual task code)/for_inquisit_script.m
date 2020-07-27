% new script to put matlab stuff into inquisit 

load('convert_to_inquisit.mat');

 inq_picture = cell(1,1);
 inq_word_set = cell(1,1); %delete this for easier printing ?? 
 inq_words_absent = cell(1,1);
 inq_text = cell(1,1);
 inq_text_abs = cell(1,1);
 inq_list_absent = cell(1,1);
 inq_list_present = cell(1,1);
 
 col = 1;
   
 word_set_counter = 1;
    
 absent_opening = 1;
 num_absent = 10;
    
 text_counter = 1;
 text_abs_counter = 1;
    
 %parts of the 'text' as variable 
 text_3_select = '/ select = noreplace';
 text_4_vposition = '/ vposition = values.textPosition';
 text_5_fontstyle = '/ fontstyle = ("Avenir next", values.MYfontsize, true, false, false, false, 5, 0)';
 text_6_end = '</text>'; 

 
%should probabrly have a reference data file where everything is stored 
%(eg. word_set_(number) + text number + allocated image number + image
%number as on the inquisit)
    
 for image_num = 1:length(df_sg) %image_num is the number it comes up in the list 1-400     
     
     
     %getting the picture_id in 'inq_picture' cell
     %image_id is the number at the end of the 0000 eg. 3, 9, 14, 41
     
        inq_picture{image_num, col} = sprintf('/ %d = "im%07d.jpg"', image_num, df_sg(image_num).image_id);
     
        
     %getting the present words into 'inq_word_set' 
     %3 global words and 3 specific words (will only use 5 in the inquisit
     %experiment) 
        %specific_rand = df_sg(image_num).specific(randperm(length(df_sg(image_num).specific))); %randomise the specific words for an image
        %global_rand = df_sg(image_num).global(randperm(length(df_sg(image_num).global))); %randomnise global words for an image
        specific_ordered = df_sg(image_num).specific;
        global_ordered = df_sg(image_num).global;
        
        last = length(specific_ordered);
        
        specific_1 = specific_ordered{last}; %pick the first 3 specific words 
        specific_2 = specific_ordered{last-1};
        specific_3 = specific_ordered{last-2};
        global_1 = global_ordered{1}; %pick the first 3 global words
        global_2 = global_ordered{2};
        global_3 = global_ordered{3};
        
     %insert the image number next to word_set_(image_number)in the
     %order that they appear in the data file 
        inq_word_set{word_set_counter, col} = sprintf('<item word_set_%d>',image_num);
        inq_word_set{word_set_counter + 1, col} = sprintf('/ 1 = "%s"', specific_1);
        inq_word_set{word_set_counter + 2, col} = sprintf('/ 2 = "%s"', specific_2);
        inq_word_set{word_set_counter + 3, col} = sprintf('/ 3 = "%s"', specific_3);
        inq_word_set{word_set_counter + 4, col} = sprintf('/ 4 = "%s"', global_1);
        inq_word_set{word_set_counter + 5, col} = sprintf('/ 5 = "%s"', global_2);
        inq_word_set{word_set_counter + 6, col} = sprintf('/ 6 = "%s"', global_3);
        inq_word_set{word_set_counter + 7, col} = '</item>';

        word_set_counter = word_set_counter + 8;
        
        
     %create the absent word_set (like the present word set) from absent words   
        
        absent_words = cell(1,1);%for every loop clear the cell
        %get the words (from wordlist) using index positions in word_positions_absent 
        absent_words = word_list(df_sg(image_num).word_positions_absent); 
        absent_words_limited = absent_words(randsample(length(absent_words),num_absent));%take a random 10 of them
        
        inq_words_absent{absent_opening, col} = sprintf('<item word_absent_%d>',image_num); %print opening 
        for absent_num = 1:length(absent_words_limited) %loop for the next 10 absent words
            inq_words_absent{absent_opening + absent_num, col} = sprintf('/ %d = "%s"', absent_num, absent_words_limited{absent_num});
        end
        inq_words_absent{absent_opening + length(absent_words_limited) + 1, col} = '</item>'; %print ending 
        
        absent_opening = absent_opening + length(absent_words_limited) + 2;%calculate new counter value
     
        
     %create text items (for present word_set) to join word_set items into the text 
        inq_text{text_counter, col} = sprintf('<text p%d>',image_num);
        inq_text{text_counter + 1, col} = sprintf('/ items = word_set_%d',image_num);
        inq_text{text_counter + 2, col} = text_3_select;
        inq_text{text_counter + 3, col} = text_4_vposition;
        inq_text{text_counter + 4, col} = text_5_fontstyle;
        inq_text{text_counter + 5, col} = text_6_end;
        
        text_counter = text_counter + 6;
        
      %create text items (for words_absent) 
        inq_text_abs{text_abs_counter, col} = sprintf('<text a%d>',image_num);
        inq_text_abs{text_abs_counter + 1, col} = sprintf('/ items = word_absent_%d',image_num);
        inq_text_abs{text_abs_counter + 2, col} = text_3_select;
        inq_text_abs{text_abs_counter + 3, col} = text_4_vposition;
        inq_text_abs{text_abs_counter + 4, col} = text_5_fontstyle;
        inq_text_abs{text_abs_counter + 5, col} = text_6_end;
        
        text_abs_counter = text_abs_counter + 6;
        
      %create the list stuff
        inq_list_present{image_num} = sprintf('text.p%d', image_num);
        inq_list_absent{image_num} = sprintf('text.a%d', image_num);
        
 end

 writecell(inq_list_absent)
 writecell(inq_list_present)
 

 
 
