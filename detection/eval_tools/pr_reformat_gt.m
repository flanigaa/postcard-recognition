% Function to reformat the original ground truth file to be representative
% of only the files that were tested.
%
% Alec Flanigan 2017
%
% @param gt_dir directory where the original ground truth mat file is
%   located
% @param evt_idx the structure that contains the indices of the tested
%   files within the ground truth file
% @return a structure that is formatted similarly to the ground truth file
%   that is representative of the tested results
function gt_info = pr_reformat_gt( gt_dir, evt_idx )

    if isempty( evt_idx )
        error( 'Ground truth cannot be reformatted to account for an empty directory. Check the result directory and try again.' );
    end

    % loads the original ground truth mat file
    load( gt_dir );

    evts_fnd = size( evt_idx, 1 );

    for i = 1:evts_fnd
        cur_evt = evt_idx{ i, 1 };
        cur_evt_imgs = evt_idx{ i, 2 };
    
        imgs_fnd = size( cur_evt_imgs, 1 );

        %stores the cell for the current event for each list from ground truth
        gt_blur = blur_label_list{ cur_evt, 1 };
        gt_event = event_list{ cur_evt, 1 };
        gt_expression = expression_label_list{ cur_evt, 1 };
        gt_face_bbx = face_bbx_list{ cur_evt, 1 };
        gt_file = file_list{ cur_evt, 1 };
        gt_li = gt_list{ cur_evt, 1 };
        gt_illumination = illumination_label_list{ cur_evt, 1 };
        gt_invalid = invalid_label_list{ cur_evt, 1 };
        gt_occlusion = occlusion_label_list{ cur_evt, 1 };
        gt_pose = pose_label_list{ cur_evt, 1 };
        
        %store the newly initialized cell arrays for the event
        rf_blur = cell( imgs_fnd, 1 );
        rf_expr = cell( imgs_fnd, 1 );
        rf_face = cell( imgs_fnd, 1 );
        rf_file = cell( imgs_fnd, 1 );
        rf_gt_l = cell( imgs_fnd, 1 );
        rf_illu = cell( imgs_fnd, 1 );
        rf_inva = cell( imgs_fnd, 1 );
        rf_occl = cell( imgs_fnd, 1 );
        rf_pose = cell( imgs_fnd, 1 );

        for j = 1:imgs_fnd
            cur_img_num = cur_evt_imgs( j );
            
            rf_blur( j, 1 ) = gt_blur( cur_img_num );
            rf_expr( j, 1 ) = gt_expression( cur_img_num );
            rf_face( j, 1 ) = gt_face_bbx( cur_img_num );
            rf_file( j, 1 ) = gt_file( cur_img_num );
            rf_gt_l( j, 1 ) = gt_li( cur_img_num );
            rf_illu( j, 1 ) = gt_illumination( cur_img_num );
            rf_inva( j, 1 ) = gt_invalid( cur_img_num );
            rf_occl( j, 1 ) = gt_occlusion( cur_img_num );
            rf_pose( j, 1 ) = gt_pose( cur_img_num );

        end
        
        gt_info.blur_label_list( i, 1 ) = mat2cell( rf_blur, imgs_fnd, 1 );
        gt_info.event_list( i, 1 ) = cellstr( gt_event );
        gt_info.expression_list( i, 1 ) = mat2cell( rf_expr, imgs_fnd, 1 );
        gt_info.face_bbx_list( i, 1 ) = mat2cell( rf_face, imgs_fnd, 1 );
        gt_info.file_list( i, 1 ) = mat2cell( rf_file, imgs_fnd, 1 );
        gt_info.gt_list( i, 1 ) = mat2cell( rf_gt_l, imgs_fnd, 1 );
        gt_info.illumination_label_list( i, 1 ) = mat2cell( rf_illu, imgs_fnd, 1 );
        gt_info.invalid_label_list( i, 1 ) = mat2cell( rf_inva, imgs_fnd, 1 );
        gt_info.occlusion_label_list( i, 1 ) = mat2cell( rf_occl, imgs_fnd, 1 );
        gt_info.pose_label_list( i, 1 ) = mat2cell( rf_pose, imgs_fnd, 1 );
        
    end

end