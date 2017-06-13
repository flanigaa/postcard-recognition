% Function used to test an entire directory of images using
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
% @param mode whether the directory should be tested in color or grayscale.
%	must input either 'color' or 'grayscale'
% @param tiny_face_path directory path to the tiny-face directory
% @param model_path if using a different model, specify the path, otherwise
%   leave empty for tiny-face default
function test_dir( dir_path, out_path, prob_thresh, nms_thresh, gpu_id, mode, tiny_face_path, model_path )

	if nargin < 6 || isempty( mode )
		mode = 'color';
	end
	if nargin < 7 || isempty( tiny_face_path )
		tiny_face_path = 'tiny-face';
	end
	if nargin < 8 || isempty( model_path )
		model_path = sprintf( '%s/trained_models/hr_res101.mat', tiny_face_path );
	end
    
    if ~exist( out_path, 'dir' )
        mkdir( out_path );
    end
    
	checkpoint_path = sprintf('%s/%s', out_path, 'checkpoint.txt');
	
    if exist( checkpoint_path, 'file' )
        checkpoint = fopen( checkpoint_path,  'r+' );
        checkpoint_data = textscan( checkpoint, '%s', 'Delimiter', '\n' );
        checkpoint_data = checkpoint_data{ 1, 1 };
        check_params = strsplit( checkpoint_data{ 1, 1 }, ',' );
        
		% checks that the function has been run with the same parameters as the checkpoint
		% shows was previously run
        if ( (str2double(check_params{2}) == prob_thresh) && (str2double(check_params{3}) == nms_thresh) )
            last_completion = checkpoint_data{ end, 1 };
            last_completion = strsplit( last_completion, ',' );
            evt_start = str2double( last_completion{ 1 } );
            file_start = str2double( last_completion{ 2 } );
        else
            error( 'Checkpoint exists, but current parameters do not match those of the checkpoint. If you wish to overwrite the previous run, please delete the checkpoint.txt file' );
        end
    else
		checkpoint = create_checkpoint( out_path, dir_path, prob_thresh, nms_thresh );
        evt_start = 1;
        file_start = 1;
    end
	
	img_dir = dir( dir_path );
    num_of_dir = sum( [ img_dir.isdir ] )-2;
    pure_dir_num = evt_start-1;
	num_of_evts = size( img_dir, 1 );
    
    for i = evt_start+2 : num_of_evts
		
        cur_out_path = sprintf( '%s/%s', out_path, img_dir( i ).name );
        if ~exist( cur_out_path, 'dir' )
            mkdir( cur_out_path );
        end
        
	    cur_evt_path = sprintf( '%s/%s', dir_path, img_dir( i ).name );
        
        % skips files within the outer directory and only opens actual
        % directories to avoid possible crashing
        if isdir( cur_evt_path )
	        cur_evt = dir( cur_evt_path );
            pure_dir_num = pure_dir_num + 1;
        else
            continue;
        end
        
		num_of_files = size( cur_evt, 1 );
        
        fprintf( 'Processing started for dir %d/%d\n', pure_dir_num, num_of_dir );
        
        for j = file_start+2 : num_of_files
		
			fprintf( checkpoint, '%d,%d\n', i-2, j-2 );
            
%             fprintf( 'Processing image %i/%i from %s (dir %d/%d)\n', ...
%                 j-2, length( pics )-2 ,img_dir( i ).name, (i-2), ...
%                 length( img_dir)-2 );
            
            cur_file = cur_evt( j );
            file_path = sprintf( '%s/%s', cur_evt_path, cur_file.name );
            
            % skips files that cannot be opened as an image to avoid crashing
			try
				% reads the image as determined by the mode
                switch mode
                    case 'color'
                        img = imread( file_path );
                    case 'grayscale'
                        img = rgb2gray( imread( file_path ) );
                    otherwise
                        error( '%s is not a valid testing mode\n', mode );
                end
				
            catch
                continue;
            end
            
            pic_res = test_pic( img, '', prob_thresh, nms_thresh, ...
                gpu_id, false, tiny_face_path, model_path );
            
            file_dir = sprintf( '%s/%s', img_dir( i ).name, cur_file.name );
            bbox_num = size( pic_res, 1 );
            
            file_wo_ext = strsplit( cur_file.name, '.' );
            file_wo_ext = file_wo_ext{ 1 };
            
            % prints the info for the current image to a new file
            file_out_name = sprintf( '%s/%s.txt', cur_out_path, file_wo_ext );
            fid = fopen( file_out_name, 'a+' );
            fprintf( fid, file_dir );
            fprintf( fid, '\n' );
            fprintf( fid, num2str( bbox_num ) );
            fprintf( fid, '\n' );
            fclose( fid );
            dlmwrite( file_out_name, pic_res, '-append' );
            
        end
        
        file_start = 1;
    end
	
    fclose( checkpoint );
    delete( sprintf('%s/%s', out_path, 'checkpoint.txt') );
end

function fid = create_checkpoint( out_path, dir_path, prob_thresh, nms_thresh )
        fid = fopen( sprintf( '%s/%s', out_path, 'checkpoint.txt' ), 'w+' );
        fprintf( fid, '%s,%d,%d\n', dir_path, prob_thresh, nms_thresh );
		fprintf( fid, '%d,%d\n', 1, 1 );
end