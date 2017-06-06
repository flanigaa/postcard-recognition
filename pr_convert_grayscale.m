function pr_convert_grayscale( dir_path, out_path )

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
        pic_start = str2double( last_completion{ 2 } ) + 1;
    else
        checkpoint = fopen( sprintf('%s/%s', out_path, 'checkpoint.txt'), 'w+' );
        fprintf( checkpoint, '3,2\n' );
        dir_start = 3;
        pic_start = 3;
    end
    
    org_dir = dir( dir_path );
    
    for i=dir_start : length( org_dir )
        cur_dir_path = sprintf( '%s/%s', dir_path, org_dir(i).name );
        cur_dir = dir( cur_dir_path );
        
        for j=pic_start : length( cur_dir )
            
            fprintf( 'Converting image %i/%i from %s (dir %d/%d)\n', ...
                j-2, length( cur_dir )-2 ,org_dir( i ).name, (i-2), ...
                length( org_dir)-2 );
            
            cur_pic = cur_dir( j );
            pic_path = sprintf( '%s/%s', cur_dir_path, cur_pic.name );
            gray_pic = rgb2gray( imread( pic_path ) );
            
            new_pic_path = sprintf( '%s/%s/%s', out_path, ...
                org_dir(i).name, cur_pic.name );
            if ~exist( sprintf( '%s/%s', out_path, org_dir(i).name ) )
                mkdir( sprintf( '%s/%s', out_path, org_dir(i).name ) );
            end
            imwrite( gray_pic, new_pic_path );
            
            fprintf( checkpoint, '%d,%d\n', i, j );
        end
        
        pic_start = 3;
        
        fprintf( 'Conversion complete for %s\n', cur_dir( i ).name );
    end
    
    delete( sprintf('%s/%s', out_path, 'checkpoint.txt') );
end

