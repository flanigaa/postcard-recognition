% Script to run the comparison between two sets of results.
%
% Alec Flanigan 2017
%
% NOTE: Both sets must have been tested on the same set of images. No set
% must include more or less imags, and the images tested must be the same
% in order for the full script to function properly.
%
% The script runs a series of functions in order to output all images that
% have any recall below 1 from either set when comparing to the ground
% truth. The script also effectively produces a recall list for all images
% within both sets.
%
% KEY: 
% Green boxes in images represent faces from the ground truth that
%   were detected in both sets of results.
% Red boxes in images represent faces from the ground truth that were not
%   detected in either sets.
% Cyan boxes represent faces from the ground truth that were only detected
%   within the first set of results.
% Yellow boxes represent faces from the ground truth that were only
%   detected within the second set of results.

% Directory paths to the two sets of results
first_res_path = '../results/grayscale_model/widerface_res_grayscale';
sec_res_path = '../results/new_model/widerface_res_grayscale';

% File path to the ground truth information
gt_path = '../tiny-face/eval_tools/ground_truth/wider_hard_val.mat';

% File paths to the original information used to calculate the
%   precision-recall curves. These files contain information used to
%   calculate recall within a single image.
first_org_pr_path = '../eval_tools/pr_plot_tools/baselines/Val/setting_int/pr-grayscale-gtr/wider_org_pr_info_pr-grayscale-gtr_hard_val.mat';
sec_org_pr_path = '../eval_tools/pr_plot_tools/baselines/Val/setting_int/pr-grayscale/wider_org_pr_info_pr-grayscale_hard_val.mat';

% Lowest precision allowed by either of the sets.
% This threshold is used to calculate which confidence thresholds to
%   evaluate each set at.
prec_thresh = 0.6;

% Minimum difference required for an image to be evaluated. If the
%   threshold is set to 1, any images where either set has a recall lower
%   than 1 will be evaluated and output. Any other number must be entered
%   as a decimal to work correctly. e.g. .5 will evaluate and output any
%   images where either set has a recall below 50% from the ground truth.
difference_thresh = 1;

% Directory path to the entire directory of images used in the testing of
%   both sets.
img_dir_path = '../tiny-face/data/widerface/WIDER_val/images';

% Directory to output the results images with the visualization to.
output_dir = 'comparisons/new_&_grayscale_trained/widerface_val_hard_0.6';

% Runs a function that returns a list of the ground truth bounding boxes
%   and whether each bbox was found within either set. The function also
%   returns the reformatted ground truth to match the images tested by both
%   sets.
fprintf( 'Formatting the detection list for both sets\n' );
[ detection_list, reform_gt ] = pr_detection_list( first_res_path, sec_res_path, gt_path, first_org_pr_path, sec_org_pr_path, prec_thresh );

% Runs a function that calculates the recall for both sets for each image.
% The function returns the list of recall percentages and a list of images
% above the difference threshold
fprintf( 'Determining the list of images to output\n' );
[ recall_list, show_list ] = pr_calc_recall_list( detection_list, difference_thresh );

% Runs a funciton to draw and output each picture with the difference being
% below the threshold. These images have all the bounding boxes from the
% ground truth and show which faces were detected in neither of the sets,
% one of them, or both. If the face was found in just one, the color also
% represents which set it was found within (see the key above).
fprintf( 'Visualizing images\n' );
pr_visualize_comparison( detection_list, show_list, reform_gt, img_dir_path, output_dir );

fprintf( 'Comparison complete\n' );