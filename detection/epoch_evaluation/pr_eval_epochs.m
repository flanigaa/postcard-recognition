% Function to iterate and test each epoch from the given directory of
% epochs in order to find the best one.
%
% Alec Flanigan
%
% The function evaluates the "score" of each epoch one at a time and for
% each widerface difficulty. This score representative of the area under
% the curve for a precision recall curve and can be compared to other
% scores calculated similarly.
%
% @param epoch_dir directory where the list of epochs are
% @param eval_output output direcotry to print the results
% @param img_dir directory for the testing images
% @param prob_thresh a minimum confidence threshold to use for the bounding
%   boxes. Lower threshhold results in more bounding box detections.
% @param nms_thresh overlap threshold
% @param gpu_id which gpu to use for testing. Starts at 1, 0 means no use
%   of gpu
% @param mode decides whether the image directory will be tested in its
%   original color or grayscale
function pr_eval_epochs( epoch_dir, eval_output, img_dir, prob_thresh, nms_thresh, gpu_id, mode )
    addpath ../;
    addpath ../eval_tools;
    
    if nargin < 7 || isempty( mode )
        mode = 'grayscale';
    end
    
    if ~exist( eval_output, 'dir' )
        mkdir( eval_output )
    end
    
    % handles checkpoint creation and access
    if exist( sprintf( '%s/checkpoint.txt', eval_output ), 'file' )
        checkpoint = fopen( sprintf('%s/%s', eval_output, 'checkpoint.txt'),  'r+');
        checkpoint_data = textscan( checkpoint, '%s', 'Delimiter', '\n' );
        checkpoint_data = checkpoint_data{ 1, 1 };
        last_completion = checkpoint_data{ end, 1 };
        last_completion = strsplit( last_completion, ',' );
        switch last_completion{1,2}
            case 'testing'
                epoch_start = str2double( last_completion );
                skip_test = true;
            case 'evaluation'
                epoch_start = str2double( last_completion )-1;
                skip_test = false;
        end
    else
        checkpoint = fopen( sprintf('%s/checkpoint.txt', eval_output ), 'w+' );
        epoch_start = 50;
        skip_test = false;
    end
    
    % sets the directory for the ground truth and the name format of the
    % epochs within the directory
    gt_dir = '../tiny-face/eval_tools/ground_truth/wider_face_val.mat';
    epoch_name_fmt = 'net-epoch-';
    
    fid = fopen( sprintf( '%s/epoch_scores.txt', eval_output ), 'a+' );
    
    % tests each epoch starting from the last, calculates the score, 
    % and prints the score to a file
    for i=epoch_start : -1 : 1
        
        epoch_name = sprintf( '%s%d', epoch_name_fmt, i );
        epoch_path = sprintf( '%s/%s.mat', epoch_dir, epoch_name );
        output_path = sprintf( '%s/%s_res', eval_output, epoch_name );
            
        if ~skip_test
            fprintf( 'Testing epoch %d\n', i );
            
            test_dir( img_dir, output_path, prob_thresh, nms_thresh, gpu_id, mode, '../tiny-face', epoch_path );

            fprintf( checkpoint, '%d,testing\n', i );
        end
        
        fprintf( 'Reading predictions for epoch %d\n', i );
        [ pred_list, evt_idx ] = pr_read_pred( output_path, gt_dir );
        norm_pred_list = pr_norm_score( pred_list );
        
        %evaluate on different settings
        difficulty = {'easy';'medium';'hard'};
        
        total_score = 0;
        fprintf( 'Evaluating epoch %d\n', i );
        for j = 1:size( difficulty, 1 )
            gt_dir = sprintf( '../tiny-face/eval_tools/ground_truth/wider_%s_val.mat', difficulty{j} );
            gt_info = pr_reformat_gt( gt_dir, evt_idx );
            pr_curve = pr_epoch_evaluation( norm_pred_list, gt_info );
            score = VOCap( pr_curve(:, 2), pr_curve(:, 1) );

            fprintf( fid, 'Epoch: %d, Difficulty: %s, Score: %d\n', i, difficulty{j}, score );
            total_score = total_score + score;
        end
        fprintf( fid, 'Epoch %d Average Score: %d\n', i, (total_score/3) );
        fprintf( checkpoint, '%d,evaluation\n', i );
        skip_test = false;
    end
    
    delete( sprintf( '%s/checkpoint.txt', out_path ) );
end