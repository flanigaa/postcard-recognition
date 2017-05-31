% Function used to test an entire directory of images using
% tiny_face_detector while converting them to grayscale first.
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
function testDirGrayscale( dir_path, out_path, prob_thresh, nms_thresh, gpu_id )
	img_dir = dir( dir_path );
    
    if ~exist( out_path, 'dir' )
        mkdir( out_path );
    end
    
    if exist( sprintf('%s/%s', out_path, 'checkpoint.txt'), 'file' )
        checkpoint = fopen( sprintf('%s/%s', out_path, 'checkpoint.txt'),  'r+');
        checkpoint_data = textscan( checkpoint, '%s', 'Delimiter', '\n' );
        checkpoint_data = checkpoint_data{ 1, 1 };
        check_params = strsplit( checkpoint_data{ 1, 1 }, ',' );
        if ( strcmp(check_params{1}, dir_path) && strcmp(check_params{2}, out_path) && (str2double(check_params{3}) == prob_thresh) && (str2double(check_params{4}) == nms_thresh) )
            last_completion = checkpoint_data{ end, 1 };
            last_completion = strsplit( last_completion, ',' );
            evt_start = str2double( last_completion{ 1 } );
            pic_start = str2double( last_completion{ 2 } ) + 1;
        else
            error( 'Checkpoint existent, but parameters do not match those of the checkpoint If you wish to overwrite the previous run, please delete the checkpoint.txt file' );
        end
    else
        checkpoint = fopen( sprintf('%s/%s', out_path, 'checkpoint.txt'), 'w+' );
        fprintf( checkpoint, '%s,%s,%d,%d\n', dir_path, out_path, prob_thresh, nms_thresh );
        evt_start = 3;
        pic_start = 3;
    end
    
	for i = evt_start : length( img_dir )
        
        cur_out_path = sprintf( '%s/%s', out_path, img_dir( i ).name );
        if ~exist( cur_out_path, 'dir' )
            mkdir( cur_out_path );
        end
        
	    cur_dir = sprintf( '%s/%s', dir_path, img_dir( i ).name );
	    pics = dir( cur_dir );
        
        for j = pic_start : length( pics )
            
            fprintf( 'Processing image %i/%i from %s (dir %d/%d)\n', ...
                j-2, length( pics )-2 ,img_dir( i ).name, (i-2), ...
                length( img_dir)-2 );
            
            cur_pic = pics( j );
            pic_path = sprintf( '%s/%s', cur_dir, cur_pic.name );
            gray_pic = rgb2gray( imread( pic_path ) );
            
            pic_res = testPicture( gray_pic, '', prob_thresh, ...
                nms_thresh, gpu_id, false);
            
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
            fclose( fid );
            dlmwrite( file_out_name, pic_res, '-append' );
            
            fprintf( checkpoint, '%d,%d\n', i, j );
        end
        
        pic_start = 3;
        
        fprintf( 'Processing complete for %s\n', img_dir( i ).name );
    end
    
    delete( sprintf('%s/%s', out_path, 'checkpoint.txt') );
end