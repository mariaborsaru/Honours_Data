load('raw_tables_filtered_with_trialcode.mat');

table = tables_SOA266_alltrials; 

unique_subj = unique(table(:,1));

%filter by global trial 
global_trial = groupfilter(table,'subject', @(x) (x == "global"),'type');

%filter by specific trial 
specific_trial = groupfilter(table,'subject', @(x) (x == "specific"),'type');

%filter by absent trial 
absent_trial = groupfilter(table, 'subject', @(x) (x =="absent"),'type');

subj_num = height(unique_subj);

%% Global 

global_matrix_raw = zeros(subj_num, 8);
global_matrix_percent = zeros(subj_num,8);

%count responses (global)
for n = 1:subj_num
    subj_filtered = global_trial.subject == unique_subj{n,1};
    subj_filtered = global_trial(subj_filtered,:);
    
    global_responses = categorical(subj_filtered.response, ...
    {'-3.5','-2.5','-1.5', '-0.5', '0.5', '1.5','2.5', '3.5'},'Ordinal',true);
    
    [n_global, ~] = histcounts(global_responses);
    specifc_matrix_raw(n,:) = n_global; 
    
    sum_global = sum(n_global);
    
    %calculate proportion of present responses for that subject   
        for i = 1:length(n_global)
            global_matrix_percent(n, i) = n_global(i)/sum_global;
        end
end

%mean of absent
m_global = mean(global_matrix_percent,1);

% standard errors
se_global = std(global_matrix_percent,1)/sqrt(subj_num);
%% Specific

%do the same for specific 
specifc_matrix_raw = zeros(subj_num, 8);
specific_matrix_percent = zeros(subj_num,8);

%count responses (specific)
for n = 1:subj_num
    subj_filtered = specific_trial.subject == unique_subj{n,1};
    subj_filtered = specific_trial(subj_filtered,:);
    
    specific_responses = categorical(subj_filtered.response, ...
    {'-3.5','-2.5','-1.5', '-0.5', '0.5', '1.5','2.5', '3.5'},'Ordinal',true);
    
    [n_specific, ~] = histcounts(specific_responses);
    specifc_matrix_raw(n,:) = n_specific; 
    
    sum_specific = sum(n_specific);
    
    %calculate proportion of present responses for that subject   
        for i = 1:length(n_specific)
            specific_matrix_percent(n, i) = n_specific(i)/sum_specific;
        end
end

%mean of absent
m_specific = mean(specific_matrix_percent,1);

% standard erors
se_specific = std(specific_matrix_percent,1)/sqrt(subj_num);
%% Absent

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
errorbar(1:8,m_global,se_global,'.-','MarkerSize',12,'Color',colours(2,:),'MarkerEdgeColor',colours(2,:),'MarkerFaceColor',colours(2,:),'LineWidth',1);

hold on
errorbar(1:8,m_specific,se_specific,'.-','MarkerSize',12,'Color', colours(3,:),'MarkerEdgeColor',colours(3,:),'MarkerFaceColor',colours(3,:),'Color',colours(3,:),'LineWidth',1);
hold off

hold on
errorbar(1:8,m_absent,se_absent,'.-','MarkerSize',12,'Color', colours(1,:),'MarkerEdgeColor',colours(1,:),'MarkerFaceColor',colours(1,:),'Color',colours(1,:),'LineWidth',1);
hold off

set(gca,'XTick',[1:1:8],'XTickLabel',{'no 4','no 3','no 2','no 1','yes 1','yes 2','yes 3','yes 4'},'FontSize', 12,'FontName','Arial','Box','off');
ylim([0 0.6]);
xlim([0.5 8.5]);
xlabel('Decision x Confidence','FontSize',14);
ylabel('Proportion','FontSize',14);
legend({'= global','= specifc','= absent'},'Location','eastoutside')