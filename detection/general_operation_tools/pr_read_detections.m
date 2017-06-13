% Function to read in the detection results from a directory
%
% Alec Flanigan 2017
%
% The function reads each result file within the given directory
% and loads it into a list of all detections. While loading the
% detections, the function also creates a list of all the file
% paths, corresponding to the detection list
%
% @param res_path path to the directory containing all results
%   from testing
% @return detection_list list of all read detections
% @return file_paths list of the file path layout to use to
%   retrieve the original images later
function [ detection_list, file_paths ] = pr_read_detections( res_path )

    results = dir( res_path );
    num_of_evts = size( results, 1 )-2;
    
    detection_list = cell( num_of_evts, 1 );
    file_paths = cell( num_of_evts, 1 );
    
    for i=3 : num_of_evts+2
        
        evt_dir_path = sprintf( '%s/%s', res_path, results(i).name );
        evt_dir = dir( evt_dir_path );
        num_of_imgs = size( evt_dir, 1 )-2;
        
        evt_detection_list = cell( num_of_imgs, 1 );
        evt_file_paths = cell( num_of_imgs, 1 );
        
        for j=3 : num_of_imgs+2
        
            img_res_path = sprintf( '%s/%s', evt_dir_path, evt_dir(j).name );
            
            fid = fopen( img_res_path,'r' );
            tmp = textscan( fid, '%s', 'Delimiter', '\n' );
            tmp = tmp{ 1 };
            fclose( fid );
            
            evt_file_paths{ j-2, 1 } = tmp{1,1};
            bbx_num = tmp{2,1};
            bbx_num = str2double(bbx_num);
            bbx = zeros(bbx_num,5);
            if bbx_num ==0
                continue;
            end
            for k = 1:bbx_num
                raw_info = str2num(tmp{k+2,1});
                bbx(k,1) = raw_info(1);
                bbx(k,2) = raw_info(2);
                bbx(k,3) = raw_info(3);
                bbx(k,4) = raw_info(4);
                bbx(k,5) = raw_info(end);
            end
            [~, s_index] = sort(bbx(:,5),'descend');
            evt_detection_list{ j-2, 1 } = bbx(s_index,:);
            
        end
        
        detection_list( i-2, 1 ) = mat2cell( evt_detection_list, num_of_imgs, 1 );
        file_paths( i-2, 1 ) = mat2cell( evt_file_paths, num_of_imgs, 1  );
    end
end