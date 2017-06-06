% Function to return a list of recall percentages for every image in the
% original list and also returns a list of with 1's where the recall is
% below the given cut off.
%
% Alec Flanigan 2017
%
% The function calculates the recall percentage for each image for both
% sets and produces a "show_list" that is used to represent images were the
% recall for the set is below the cut off number.
%
% @param detection_list list of each bounding box from the ground truth 
%   and whether it was detected for both sets
% @param cut_off a threshold number used to determine whether an image has
%   a large enough difference from the ground truth to be exported. If the
%   image has a recall percentage below the given cut off for either set,
%   then it will be counted in the show_list.
%
% @return recall_list list of recall percentages for each image within both
%   sets.
% @return show_list list of 1s and 0s that represent whether an image has
%   a recall percentage below the cut off for either set
function [ recall_list, show_list ] = pr_calc_recall_list( detection_list, cut_off )

    num_of_evts = size( detection_list, 1 );
    recall_list = cell( num_of_evts, 1 );
    show_list = cell( num_of_evts, 1 );
    
    for i=1 : num_of_evts
        
        cur_evt_list = detection_list{ i, 1 };
        num_of_files = size( cur_evt_list, 1 );
        evt_recall_list = cell( num_of_files, 1 );
        evt_show_list = zeros( num_of_files, 1 );
        
        for j=1 : num_of_files
            
            cur_file_list = cur_evt_list{ j, 1 };
            num_of_bboxes = size( cur_file_list, 1 );
            first_num_bboxes = 0;
            sec_num_bboxes = 0;
            
            for k=1 : num_of_bboxes
                if cur_file_list( k, 5 ) == 1
                    first_num_bboxes = first_num_bboxes + 1;
                end
                if cur_file_list( k, 6 ) == 1
                    sec_num_bboxes = sec_num_bboxes + 1;
                end
            end
            
            first_rec = first_num_bboxes / num_of_bboxes;
            sec_rec = sec_num_bboxes / num_of_bboxes;
            file_recall = [ num_of_bboxes, first_rec, sec_rec ];
            evt_recall_list( j, 1 ) = mat2cell( file_recall, 1, 3 );
            
            % if either sets have recall lower than the defined cut off add
            %   it to the list
            if first_rec < cut_off || sec_rec < cut_off
                evt_show_list( j, 1 ) = 1;
            end
        end
        
        recall_list( i, 1 ) = mat2cell( evt_recall_list, num_of_files, 1 );
        show_list( i, 1 ) = mat2cell( evt_show_list, num_of_files, 1 );
    end
end