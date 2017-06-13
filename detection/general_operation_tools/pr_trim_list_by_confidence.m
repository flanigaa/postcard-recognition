% Function to trim the size of the detection list based
% on a minimum confidence threshold
%
% Alec Flanigan 2017
%
% The function simply creates a new list of detections
% that are all over the given confidence threshold. While
% doing so, the function also creates a two dimensional list
% that contains the number of detections in each image and
% the indexing to their positions in the original file_paths
% list. This size list is also sorted by decending order of
% size.
%
% @param org_list original detection list to trim
% @param con_thresh minimum confidence threshold
% @return trimmed_list new, trimmed list from the original
% @return size_list sorted list of the number of detections
%   within each image
function [ trimmed_list, size_list ] = pr_trim_list_by_confidence( org_list, con_thresh )
    
    num_of_evts = size( org_list, 1 );
    trimmed_list = cell( num_of_evts, 1);
    
    total_num_of_imgs = 0;
    for i=1 : num_of_evts
        cur_evt = org_list{i,1};
        num_of_imgs = size( cur_evt, 1);
        total_num_of_imgs = total_num_of_imgs + num_of_imgs;
    end
    
    size_list = cell( total_num_of_imgs, 2 );
    sizes = zeros( total_num_of_imgs, 1 );
    size_list_idx = 1;
    
    for i=1 : num_of_evts
    
        cur_evt = org_list{i,1};
        num_of_imgs = size( cur_evt, 1);
        evt_trimmed_list = cell( num_of_imgs, 1 );
        for j=1 : num_of_imgs
            
            img_bboxes = cur_evt{j, 1};
            num_of_bboxes = size( img_bboxes, 1);
            
            valid_bboxes = zeros( 0, 5 );
            valid_list_idx = 0;
            for k=1 : num_of_bboxes
                if img_bboxes( k, 5 ) >= con_thresh
                    valid_list_idx = valid_list_idx + 1;
                    valid_bboxes( valid_list_idx, 1 ) = img_bboxes(k,1);
                    valid_bboxes( valid_list_idx, 2 ) = img_bboxes(k,2);
                    valid_bboxes( valid_list_idx, 3 ) = img_bboxes(k,3);
                    valid_bboxes( valid_list_idx, 4 ) = img_bboxes(k,4);
                    valid_bboxes( valid_list_idx, 5 ) = img_bboxes(k,5);
                end
            end
            
            size_list( size_list_idx, 1 ) = num2cell( size( valid_bboxes, 1 ) );
            size_list( size_list_idx, 2 ) = cellstr( sprintf( '%d,%d', i, j ) );
            sizes( size_list_idx, 1 ) = size( valid_bboxes, 1 );
            size_list_idx = size_list_idx+1;
            
            evt_trimmed_list( j, 1 ) = mat2cell( valid_bboxes, size( valid_bboxes, 1 ), 5 );
        end
        
        trimmed_list( i, 1 ) = mat2cell( evt_trimmed_list, num_of_imgs, 1 );
    end
    [ ~, idx_list ] = sort( sizes( :, 1 ), 'descend' );
    size_list = size_list( idx_list, : );
end