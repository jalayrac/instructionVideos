% This script reproduces the results given in the Figure 3 of the paper:
%  @InProceedings{Alayrac16unsupervised,
%     author      = "Alayrac, Jean-Baptiste and Bojanowski, Piotr and Agrawal, 
%     Nishant and Laptev, Ivan and Sivic, Josef and Lacoste-Julien, Simon",
%     title       = "Unsupervised learning from Narrated Instruction Videos",
%     booktitle   = "Computer Vision and Pattern Recognition (CVPR)",
%     year        = "2016"
% }

% ========================================================================
%   RESULT PATHS
% ========================================================================

pathResults = '../results';
pathData    = '../data';

% ========================================================================
%   PARAMETERS
% ========================================================================

task       = 'changing_tire';
methods    = {'cvpr','uniform','videoOnly','videoBowDobj', '[20]', 'supervised'};
nameMethod = {'Our method', 'Uniform', 'Video only', 'Video + BOW dobj', '[20]',  'Supervised'};
K_tab      = [7, 10, 12, 15];
lambdas    = num2cell([1/(30*15), 1/(30*12), 1/(30*10), 1/(30*7)]);

lambdaFormula = 1./(K_tab*30);
lambdaSel      = zeros(1,numel(K_tab));

for i=1:numel(K_tab)
lambdaSel(i) = find(([lambdas{:}]==lambdaFormula(i)));
end

% Depending on the task, our method sometimes produces less K than asked,
% thus we need to take a bigger \lambda in this case. The following
% selection only deals with this problem.

switch task
    case 'repot'
        lambdaSel(1:3) = 4;
        lambdaSel(4) = 2;
    case 'cpr'
        lambdaSel(3:4) = 3;
    case 'coffee'
        lambdaSel(2:3) = 3;
        lambdaSel(4) = 2;
    case 'jump_car'
        lambdaSel(4) = 2;
end

lambda    = lambdas{lambdaSel};
% Initiate the F1_tab
F1_tab    = zeros(numel(K_tab),numel(methods));
% Initiate the error bars 
errorF1   = zeros(numel(K_tab),numel(methods),2);

for k=1:numel(K_tab)   
    % depending on the method and the task load the results      
    res = get_f1_for_task(task, lambdas{lambdaSel(k)}, K_tab(k), pathData, pathResults); 
    if isempty(res)
        continue;
    end
    F1_tab(k,1)    = res.F1;
    errorF1(k,1,1) = res.F1-res.minF1;
    errorF1(k,1,2) = res.maxF1-res.F1;            
end

% =========================================================================
%   BASELINES RESULTS
% =========================================================================

% Load the results for other method directly (if you need more details on
% the baselines, please send me an email)

baselines = load(fullfile(pathResults, 'VISION', sprintf('baselines_%s.mat', task)));
F1_tab(:,2:end)    = baselines.F1_tab;
errorF1(:,2:end,:) = baselines.errorF1;

% =========================================================================
%   PLOTTING
% =========================================================================

figure('Position', [100, 100, 1049, 895]);
[h, hError] = barwitherr(errorF1, F1_tab);
set(gca,'XTickLabel',num2cell(K_tab));
ylabel('F1 score');
xlabel('K');
set(gca,'FontSize',30);
axis square;
grid on; 
xlim([0,5]);
barWidth = 0.8; % 0.8 par défault
set(h(1), 'FaceColor',[241,88,84]/255,'BarWidth', barWidth);
set(hError, 'Color','black', 'LineWidth', 3);
% legend(nameMethod, 'Location', 'NorthWest', 'FontSize', 35);
