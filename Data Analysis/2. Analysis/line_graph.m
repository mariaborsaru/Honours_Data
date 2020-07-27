load('raw_tables_filtered_with_trialcode.mat');

table = tables_SOA66_alltrials; 

unique_subj = unique(table(:,1));

%filter by present trial 
present_trial = groupfilter(table,'subject', @(x) (x == "present_trial"),'trialcode');

%filter by absent trial 
absent_trial = groupfilter(table, 'subject', @(x) (x =="absent_trial"),'trialcode');

subj_num = height(unique_subj);

present_matrix_raw = zeros(subj_num, 8);
present_matrix_percent = zeros(subj_num,8);

%count column 6 responses (present)
for n = 1:subj_num
    subj_filtered = present_trial.subject == unique_subj{n,1};
    subj_filtered = present_trial(subj_filtered,:);
    
    present_responses = categorical(subj_filtered.response, ...
    {'-3.5','-2.5','-1.5', '-0.5', '0.5', '1.5','2.5', '3.5'},'Ordinal',true);
    
    [n_present, ~] = histcounts(present_responses);
    present_matrix_raw(n,:) = n_present; 
    
    sum_present = sum(n_present);
    
    %calculate proportion of present responses for that subject   
        for i = 1:length(n_present)
            present_matrix_percent(n, i) = n_present(i)/sum_present;
        end
end

%mean of absent
m_present = mean(present_matrix_percent,1);

% standard erors
se_present = std(present_matrix_percent,1)/sqrt(subj_num);
    

%do the same for absent
absent_matrix_raw = zeros(subj_num, 8);
absent_matrix_percent = zeros(subj_num,8);

for n = 1:subj_num
    subj_filtered = absent_trial.subject == unique_subj{n,1};
    subj_filtered = absent_trial(subj_filtered,:);
    
    absent_responses = categorical(subj_filtered.response, ...
    {'-3.5','-2.5','-1.5', '-0.5', '0.5', '1.5','2.5', '3.5'},'Ordinal',true);
    
    [n_absent, ~] = histcounts(absent_responses);
    absent_matrix_raw(n,:) = n_absent; 
    
    sum_absent = sum(n_absent);
    
    %calculate proportion of present responses for that subject   
        for i = 1:length(n_absent)
            absent_matrix_percent(n, i) = n_absent(i)/sum_absent;
        end
end

%mean of absent
m_absent = mean(absent_matrix_percent,1);

% standard erors
se_absent = std(absent_matrix_percent,1)/sqrt(subj_num);


%% plot line graph
colours = cbrewer('qual', 'Set1', 8); 
out = figure;
errorbar(1:8,m_present,se_present,'.-','MarkerSize',14,'Color',colours(2,:),'MarkerEdgeColor',colours(2,:),'MarkerFaceColor',colours(2,:),'LineWidth',1);

hold on
errorbar(1:8,m_absent,se_absent,'.-','MarkerSize',14,'Color', colours(3,:),'MarkerEdgeColor',colours(1,:),'MarkerFaceColor',colours(1,:),'Color',colours(1,:),'LineWidth',1);
hold off

set(gca,'XTick',[1:1:8],'XTickLabel',{'no 4','no 3','no 2','no 1','yes 1','yes 2','yes 3','yes 4'},'FontSize', 12,'FontName','Arial','Box','off');
ylim([0 0.6]);
xlim([0.5 8.5]);
xlabel('Decision x Confidence','FontSize',20);
ylabel('Mean Proportion of Responses','FontSize',20);
legend({'= present','= absent'},'Location','northeast')