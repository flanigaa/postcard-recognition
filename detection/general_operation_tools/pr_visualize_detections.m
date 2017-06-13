% Function to visualize the top number of results from a list
% of detections
%
% Alec Flanigan 2017
%
% The function iterates through the top results and creates a
% new version of the original image with all detections in the
% detection list.
%
% @param detection_list list of detections for each image
% @param file_paths list of file paths to each image
% @param num number of results to save
% @param size_list list of the number of detections in each image
% @param img_dir directory where all original images are present
% @param output_dir directory to output all top results
function pr_visualize_detections ( detection_list, file_paths, num, size_list, img_dir, output_dir )
    
    if num > size( size_list, 1 )
        num = size( size_list, 1 );
    end
    
    if ~exist( output_dir, 'dir' )
        mkdir( output_dir );
    end
    
    for i=1 : num
        size_info = size_list( i, : );
        list_idx = size_info{ 1, 2 };
        list_idx = strsplit( list_idx, ',' );
        evt_num = str2double( list_idx{ 1, 1 } );
        file_num = str2double( list_idx{ 1, 2 } );
        
        detection_evt = detection_list{ evt_num };
        file_path_evt = file_paths{ evt_num };
        bboxes = detection_evt{ file_num };
        file_path = file_path_evt{ file_num };
        file_name = strsplit( file_path, '/' );
        file_name = file_name{ end };
        full_file_path = sprintf( '%s/%s', img_dir, file_path );
        full_output_path = sprintf( '%s/%s', output_dir, file_name );
        
        pr_save_detection( full_file_path, bboxes, full_output_path );
    end
    
end