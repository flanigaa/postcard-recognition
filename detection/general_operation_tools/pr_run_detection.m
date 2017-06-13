% Script to run testing on a set of images given operational settings
%
% Alec Flanigan
%
% The script test a directory of images with the given settings defined
% below and then proceeds to output a visualization of the top results
% within the directory. The term "top results" is used to mean images
% that contain the most detections in them, whether they are true or
% false positives.

% path to save or load the test results from
result_path = '../postcard_data/test_res';

% the directory where the original images are present
img_dir_path = '../postcard_data/images';

% whether or not to run the testing on the directory
% if the directory has already been tested and the results saved,
%   testing can be skipped to save a decent amount of time
skip_test = true;

if ~skip_test
    addpath '../';
    
    % a minimum confidence threshold to use for the bounding boxes
    test_prob_thresh = 0.03;
    % overlap threshold
    test_nms_thresh = 0.3;
    % num of gpu to run test on
    test_gpu = 4;
    % testing mode of the directory ( color or grayscale )
    test_mode = 'color';
    % path to the model to use for testing
    test_model_path = '../tiny-face/models/pr_grayscale_model.mat';
    
    % tests the directory
    test_dir( img_dir_path, result_path, test_prob_thresh, test_nms_thresh, test_gpu, test_mode, '../tiny-face', test_model_path );
end

addpath '../eval_tools';
fprintf( 'Reading detections...\n' );
% reads the detection results from the results folder into memory
[ pred_list, file_paths ] = pr_read_detections( result_path );
% normalizes confidence scores in the prediction list between 0 and 1
pred_list = pr_norm_score( pred_list );

addpath '../comparison_tools';

% path to the information used in the pr curve
% this table is used to find the confidence threshold that corresponds
%   to the given recall precision
model_org_pr_path = '../eval_tools/pr_plot_tools/baselines/Val/setting_int/pr-gray-grayscale/wider_org_pr_info_pr-gray-grayscale_hard_val.mat';

% number of top results to visualize and save
num_to_save = 100;

% directory to output the top result images
output_dir = '../postcard_data/top_results';

% list of precision thresholds to test and visualize ( lower 
%   precisions result in lower confidence thresholds )
precision_thresholds = [ 1 0.95 0.9 0.85 0.8 0.75 0.7 0.65 0.6 0.55 0.5 ];

fprintf( 'Trimming results and saving visualizations for all thresholds...\n')

for i=1 : length( precision_thresholds )
    prec_thresh = precision_thresholds( i );
    output_dir_name = sprintf( '%s/top_results_%.2f', output_dir, prec_thresh );

    con_thresh = pr_find_con_thresh( model_org_pr_path, prec_thresh );
    [ detection_list, size_list ] = pr_trim_list_by_confidence( pred_list, con_thresh );

    % visualizes and saves the detections
    pr_visualize_detections( detection_list, file_paths, num_to_save, size_list, img_dir_path, output_dir_name );
end