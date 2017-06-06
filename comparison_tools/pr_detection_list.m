% Function that returns a list of the ground truth bounding boxes for each
% event and image and records if the detection is present for each set of
% predictions.
%
% Alec Flanigan 2017
%
% NOTE: For the function to work correctly, both sets must be tested on the
% same set of images. Both sets must include every picture from the
% opposite set and no more.
%
% The function returns a detection list that is formatted by event/file and
% for each file, has a list of bounding boxes within the ground truth. Each
% row represents a single bounding box with its start x, start y, end x,
% end y, whether it is detected or not in the first set, whether or not it
% is detected in the second set. If the bounding box is detected, it will
% have a 1, and 0 otherwise.
%
% The function also returns the reformatted ground truth information to
% match the tested images from each set.
%
% @param first_res_path directory path to the first set of results
% @param sec_res_path directory path to the second set of results
% @param gt_path file path to the ground truth data
% @param first_org_pr_path file path to the list of total detections versus
%   true detections for each threshold for the first set
% @param sec_org_pr_path file path to the list of total detections versus
%   true detections for each threshold for the second set
% @param prec_thresh precision to find the corresponding threshold for for
%   both sets. e.g. the first set may have a 60% precision when the
%   confidence threshold is set to 0.3. This confidence threshold will then
%   be used for the first set when evaluating, as it produces a 60%
%   precision.
%
% @return detection_list list of each bounding box from the ground truth 
%   and whether it was detected for both sets
% @return gt_info_full reformatted ground truth information to match the
%   tested images
function [ detection_list, gt_info_full ] = pr_detection_list( first_res_path, sec_res_path, gt_path, first_org_pr_path, sec_org_pr_path, prec_thresh )
    addpath ../eval_tools;

    first_con_thresh = find_con_thresh( first_org_pr_path, prec_thresh );
    sec_con_thresh = find_con_thresh( sec_org_pr_path, prec_thresh );
    
    fprintf( 'Reading/formatting prediction info for first set.' );
    [ first_pred_list, first_evt_idx ] = pr_read_pred( first_res_path, gt_path );
    fprintf( 'Reading/formatting prediction info for second set.' );
    [ sec_pred_list, sec_evt_idx ] = pr_read_pred( sec_res_path, gt_path );
    first_pred_list = pr_norm_score( first_pred_list, first_evt_idx );
    sec_pred_list = pr_norm_score( sec_pred_list, sec_evt_idx );
    gt_info_full = pr_reformat_gt( gt_path, first_evt_idx );
    gt_info = gt_info_full.face_bbx_list;
    
    num_of_evts = size( gt_info, 1 );
    detection_list = cell( num_of_evts, 1 );
    for i=1 : num_of_evts
        first_evt_info = first_pred_list{ i, 1 };
        sec_evt_info = sec_pred_list{ i, 1 };
        gt_evt_info = gt_info{ i, 1 };
        
        num_of_files = size( gt_evt_info, 1 );
        seen_bbox_evt = cell( num_of_files, 1 );
        for j=1 : num_of_files
            first_file_bbox_list = first_evt_info{ j, 1 };
            sec_file_bbox_list = sec_evt_info{ j, 1 };
            gt_file_bbox_list = gt_evt_info{ j, 1 };
            
            gt_file_bbox_list(:,3) = gt_file_bbox_list(:,1) + gt_file_bbox_list(:,3);
            gt_file_bbox_list(:,4) = gt_file_bbox_list(:,2) + gt_file_bbox_list(:,4);
            
            gt_bbox_num = size( gt_file_bbox_list, 1 );
            seen_bbox_file = zeros( gt_bbox_num, 6 );
            
            for k=1 : gt_bbox_num
                gt_bbox = gt_file_bbox_list( k, : );
                seen_bbox_file( k, 1 ) = gt_bbox( 1, 1 );
                seen_bbox_file( k, 2 ) = gt_bbox( 1, 2 );
                seen_bbox_file( k, 3 ) = gt_bbox( 1, 3 );
                seen_bbox_file( k, 4 ) = gt_bbox( 1, 4 );
                
                for l=1 : size( first_file_bbox_list, 1 )
                    first_bbox = first_file_bbox_list( l, : );
                    
                    overlap_ratio = boxoverlap( gt_bbox, first_bbox );
                    if overlap_ratio >= 0.5 ...
                            && first_bbox(1, 5) >= first_con_thresh
                        seen_bbox_file( k, 5 ) = 1;
                        break;
                    end
                end
                
                for l=1 : size( sec_file_bbox_list, 1 )
                    sec_bbox = sec_file_bbox_list( l, : );
                    
                    overlap_ratio = boxoverlap( gt_bbox, sec_bbox );
                    if overlap_ratio >= 0.5 ...
                            && sec_bbox(1, 5) >= sec_con_thresh
                        seen_bbox_file( k, 6 ) = 1;
                        break;
                    end
                end
            end
            
            seen_bbox_evt( j, 1 ) = mat2cell( seen_bbox_file, gt_bbox_num, 6 );
        end
        detection_list( i, 1 ) = mat2cell( seen_bbox_evt, num_of_files, 1 );
    end
end

% Function to find the highest confidence threshold for the defined
% precision. Precision is calculated by dividing the true faces detected
% (col 2) by the total number of detection (col 1).
function con_thresh = find_con_thresh( org_pr_path, prec_thresh )
    load( org_pr_path );
    prec_idx = 0;
    num_of_thresh = size( org_pr_curve, 1 );
    for l=1 : num_of_thresh
        cur_prec = org_pr_curve( l, 2 ) / org_pr_curve( l, 1 );
        if ( cur_prec >= prec_thresh )
            prec_idx = l;
        else
            break;
        end
    end
    con_thresh = 1 - ( (1/num_of_thresh) * prec_idx );
end