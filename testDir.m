% Functioned used to test an entire directory of images using
% tiny_face_detector.
%
% Alec Flanigan 2017
%
% In order for the function to work correctly the image directory must be
% formatted by "events". Within the given directory path, there must be a
% list of nested folders that then hold the images. There must be at least
% one nested folder within the given directory path.
%
% The function outputs a single file for each picture in a similarly
% formatted fashion to the given directory. The results of the bounding
% boxes can be found inside the .txt files that format the bounding boxes
% with the startX, startY, endX, endY, and the confidence score of the
% image.
%
% @param dir_path path of the directory that the images are stored in
% @param out_path output path for the bounding box results
% @param prob_thresh a minimum confidence threshold to use for the bounding
%   boxes. Lower threshhold results in more bounding box detections.
% @param nms_thresh overlap threshold
% @param gpu_id which gpu to use for testing. Starts at 1, 0 means no use
%   of gpu
function testDir( dir_path, out_path, prob_thresh, nms_thresh, gpu_id )
    start_time = cputime;
	img_dir = dir( dir_path );
    
	for i = 3 : length( img_dir )
        
        cur_out_path = strcat( out_path, '/', img_dir( i ).name );
        if ~exist( cur_out_path )
            mkdir( cur_out_path );
        end
        
	    cur_dir = strcat( dir_path, '/', img_dir( i ).name );
	    pics = dir( cur_dir );
        
        for j = 3 : length( pics )
            
            fprintf( 'Processing image %i/%i from %s\n', j-2, ...
                length( pics )-2 ,img_dir( i ).name );
            
            cur_pic = pics( j );
            pic_path = strcat( cur_dir, '/', cur_pic.name );
            
            pic_res = testPicture( pic_path, '', prob_thresh, ...
                nms_thresh, gpu_id );
            
            pic_dir = sprintf( '%s/%s', img_dir( i ).name, cur_pic.name );
            bbox_num = size( pic_res, 1 );
            
            pic_wo_ext = strsplit( cur_pic.name, '.' );
            pic_wo_ext = pic_wo_ext{ 1 };
            
            % prints the info for the current image to a new file
            file_out_name = sprintf( '%s/%s.txt', cur_out_path, ...
                pic_wo_ext );
            fid = fopen( file_out_name, 'wt' );
            fprintf( fid, pic_dir );
            fprintf( fid, '\n' );
            fprintf( fid, num2str( bbox_num ) );
            fprintf( fid, '\n' );
            fid = fclose( fid );
            dlmwrite( file_out_name, pic_res, '-append' );
            
        end
        
        fprintf( 'Processing complete for %s\n', img_dir( i ).name );
    end
    
    fprintf( 'Total time to process full directory: %f seconds\n', ( cputime-start_time ) );
end