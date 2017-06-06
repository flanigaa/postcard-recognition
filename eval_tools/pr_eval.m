% Script to evaluate the PR (precision-recall) curve of only tested
% pictures within a directory instead of the entire directory.
%
% Alec Flanigan 2017
%
% The script is a slightly modified version of the widerface wider_eval
% script in order to use the other modified functions to evaluate.
%
% The prediction directory must be formatted to hold a folder for
% each event (i.e. 0--Parade), and inside must have a .txt file formatted
% with the first line containing the partial directory of the event/picture
% -title with the ending being .jpg or such. The second line must contain
% the number of bounding boxes that the model found. The following lines
% then contain each bounding each on its own line. Each bounding box
% consists of a starting x, starting y, ending x, ending y, and confidence
% score.
%
% If the prediction or ground truth directory are different than defined,
% change them as neccessary.
addpath pr_plot_tools;

pred_name = 'pr-color';
pred_dir = '../results/new_model/widerface_res';
gt_dir = '../tiny-face/eval_tools/ground_truth/wider_face_val.mat';

[ pred_list, evt_idx ] = pr_read_pred( pred_dir, gt_dir );
norm_pred_list = pr_norm_score( pred_list, evt_idx );

%evaluate on different settings
setting_name_list = {'easy_val';'medium_val';'hard_val'};
setting_class = 'setting_int';

legend_name = pred_name; 
for i = 1:size(setting_name_list,1)
    fprintf('Current evaluation setting %s\n',setting_name_list{i});
    setting_name = setting_name_list{i};
    gt_dir = sprintf('../tiny-face/eval_tools/ground_truth/wider_%s.mat',setting_name);
    fprintf( 'Reformatting ground truth file for %s difficulty.\n', setting_name );
    gt_info = pr_reformat_gt( gt_dir, evt_idx );
    pr_evaluation( norm_pred_list, gt_info, setting_name, setting_class, legend_name, evt_idx );
end

fprintf('Plot pr curve under overall setting.\n');
dataset_class = 'Val';

% scenario-Int:
seting_class = 'int';
dir_int = sprintf('pr_plot_tools/baselines/%s/setting_%s',dataset_class, seting_class);
pr_plot(setting_name_list,dir_int,seting_class,dataset_class);
