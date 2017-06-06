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

    % loads the original ground truth mat file
    load( gt_dir );

    evts_fnd = size( evt_idx, 1 );
    
    reform_blur_label_list = cell( evts_fnd, 1 );
    reform_event_list = cell( evts_fnd, 1 );
    reform_expression_list = cell( evts_fnd, 1 );
    reform_face_bbox_list = cell( evts_fnd, 1 );
    reform_file_list = cell( evts_fnd, 1 );
    reform_gt_list = cell( evts_fnd, 1 );
    reform_illumination_label_list = cell( evts_fnd, 1 );
    reform_invalid_label_list = cell( evts_fnd, 1 );
    reform_occlusion_label_list = cell( evts_fnd, 1 );
    reform_pose_label_list = cell( evts_fnd, 1 );

    for i = 1:evts_fnd
        cur_evt = evt_idx{ i, 1 };
        cur_evt_imgs = evt_idx{ i, 2 };
    
        imgs_fnd = size( cur_evt_imgs, 1 );

        %initialize cell arrays for each of the ground truth lists
        blur = cell( imgs_fnd, 1 );
        expression = cell( imgs_fnd, 1 );
        face_bbx = cell( imgs_fnd, 1 );
        file = cell( imgs_fnd, 1 );
        illumination = cell( imgs_fnd, 1 );
        invalid = cell( imgs_fnd, 1 );
        occlusion = cell( imgs_fnd, 1 );
        pose = cell( imgs_fnd, 1 );

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
        
        %initialize cell arrays for each event in reformatted gt
        reform_blur_label_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_expression_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_face_bbx_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_file_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_gt_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_illumination_label_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_invalid_label_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_occlusion_label_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        reform_pose_label_list( i, 1 ) = cell( size( imgs_fnd, 1 ), 1 );
        
        %store the newly initialized cell arrays for the event
        rf_blur = reform_blur_label_list( i, 1 );
        rf_expr = reform_expression_list( i, 1 );
        rf_face = reform_face_bbx_list( i, 1 );
        rf_file = reform_file_list( i, 1 );
        rf_gt_l = reform_gt_list( i, 1 );
        rf_illu = reform_illumination_label_list( i, 1 );
        rf_inva = reform_invalid_label_list( i, 1 );
        rf_occl = reform_occlusion_label_list( i, 1 );
        rf_pose = reform_pose_label_list( i, 1 );

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
        
        gt_info.blur_label_list( i, 1 ) = mat2cell( rf_blur, size( rf_blur, 1 ), 1 );
        gt_info.event_list( i, 1 ) = cellstr( gt_event );
        gt_info.expression_list( i, 1 ) = mat2cell( rf_expr, size( rf_expr, 1 ), 1 );
        gt_info.face_bbx_list( i, 1 ) = mat2cell( rf_face, size( rf_face, 1 ), 1 );
        gt_info.file_list( i, 1 ) = mat2cell( rf_file, size( rf_file, 1 ), 1 );
        gt_info.gt_list( i, 1 ) = mat2cell( rf_gt_l, size( rf_gt_l, 1 ), 1 );
        gt_info.illumination_label_list( i, 1 ) = mat2cell( rf_illu, size( rf_illu, 1 ), 1 );
        gt_info.invalid_label_list( i, 1 ) = mat2cell( rf_inva, size( rf_inva, 1 ), 1 );
        gt_info.occlusion_label_list( i, 1 ) = mat2cell( rf_occl, size( rf_occl, 1 ), 1 );
        gt_info.pose_label_list( i, 1 ) = mat2cell( rf_pose, size( rf_pose, 1 ), 1 );
        
    end

end