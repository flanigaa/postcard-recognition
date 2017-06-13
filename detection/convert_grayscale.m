% Function to convert an entire directory from color images to grayscale
% images
%
% Alec Flanigan 2017
%
% The function takes an original directory as an input and loads and
% converts all images to grayscale, then saves them to the given
% output directory.
%
% @param dir_path the path to the original image directory to be converted to grayscale
% @param out_path directory path to store the converted images
function convert_grayscale( dir_path, out_path )

    if ~exist( out_path, 'dir' )
        mkdir( out_path );
    end
    
    if exist( sprintf('%s/%s', out_path, 'checkpoint.txt'), 'file' )
        checkpoint = fopen( sprintf('%s/%s', out_path, 'checkpoint.txt'),  'r+');
        checkpoint_data = textscan( checkpoint, '%s', 'Delimiter', '\n' );
        checkpoint_data = checkpoint_data{ 1, 1 };
        last_completion = checkpoint_data{ end, 1 };
        last_completion = strsplit( last_completion, ',' );
        dir_start = str2double( last_completion{ 1 } );
        file_start = str2double( last_completion{ 2 } );
    else
        checkpoint = fopen( sprintf( '%s/%s', out_path, 'checkpoint.txt' ), 'w+' );
		fprintf( checkpoint, '%d,%d\n', 1, 1 );
        dir_start = 1;
        file_start = 1;
    end
    
    org_dir = dir( dir_path );
    num_of_dir = sum( [ org_dir.isdir ] )-2;
    pure_dir_num = dir_start-1;
	num_of_evts = size( org_dir, 1 );
    
    for i=dir_start+2 : num_of_evts
        cur_dir_path = sprintf( '%s/%s', dir_path, org_dir(i).name );
        if isdir( cur_dir_path )
            cur_dir = dir( cur_dir_path );
            pure_dir_num = pure_dir_num + 1;
        else
            continue;
        end
		
		cur_out_path = sprintf( '%s/%s', out_path, org_dir( i ).name );
        if ~exist( cur_out_path, 'dir' )
            mkdir( cur_out_path );
        end
		
		fprintf( 'Converting dir %d/%d\n', pure_dir_num, num_of_dir );
		
		num_of_files = size( cur_dir, 1 );
        
        for j=file_start+2 : num_of_files
            
            fprintf( checkpoint, '%d,%d\n', i-2, j-2 );
			
            cur_file = cur_dir( j );
            file_path = sprintf( '%s/%s', cur_dir_path, cur_file.name );
			
			try
            	gray_file = rgb2gray( imread( file_path ) );
			catch
				continue;
			end
            
            new_file_path = sprintf( '%s/%s', cur_out_path, cur_file.name );
            imwrite( gray_file, new_file_path );
            
        end
        
        file_start = 1;
    end
    
	fclose( checkpoint );
    delete( sprintf('%s/%s', out_path, 'checkpoint.txt') );
end