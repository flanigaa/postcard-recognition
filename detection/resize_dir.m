% Function to resize an entire directory so that the width of every image
% is 1024 pixels.
%
% Alec Flanigan 2017
%
% WARNING: The function will only work if the given, original directory is
%   structured in a way that the original directory has the images within
%   nested folders. e.g. the first image would exist at the path
%   org_dir/first_folder/first.img. The original directory can consist
%   of several "event" folders. In the case of the example, "first_folder"
%   would be the event name.
%
% NOTE: It is important that the image names only have one "." within the
%   full file name so that the original extension can be removed and
%   replaced. If this is not the case, the function will still work
%   but the image will not retain any part of its original name after
%   the first "." in the name.
%
% NOTE: If one wishes to change the resizing of the image, the size
%   manipulation of the original image is done where "resized_img"
%   is initialized.
%
% @param org_dir original directory that all the images exist in
% @param new_dir new directory to save the resized images to
function resize_dir( org_dir, new_dir )
    
    if ~exist( new_dir, 'dir' )
        mkdir( new_dir );
    end
    
    evts = dir( org_dir );
    num_of_evts = size( evts, 1 )-2;
    for i=1 : num_of_evts
    
        fprintf( 'Resizing images from directory number %d/%d\n', i, num_of_evts );
    
        cur_evt_name = evts( i+2 ).name;
        cur_evt_path = sprintf( '%s/%s', org_dir, cur_evt_name );
        
        % only opens nested directories and prevents crashing when
        % trying to open files as directories
        if isdir( cur_evt_path )
            cur_evt_dir = dir( cur_evt_path );
        else
            continue;
        end
        
        num_of_imgs = size( cur_evt_dir, 1 )-2;
        
        for j=1 : num_of_imgs
        
            cur_img_name = cur_evt_dir( j+2 ).name;
            cur_img_path = sprintf( '%s/%s', cur_evt_path, cur_img_name );
            
            % only opens valid image files to prevent crashing when
            % using imread
            try
                cur_img = imread( cur_img_path );
            catch
                warning( 'The path \"%s\" is not an image.\tSkipping file.\n', cur_img_path );
                continue;
            end
            
            % resizes the image to have a maximum width of 1024 pixels and maintain ratio
            resized_img = imresize( cur_img, [ 1024 NaN ] );
            
            new_img_name = strsplit( cur_img_name, '.' );
            new_img_name = new_img_name{ 1 };
            
            resized_img_dir = sprintf( '%s/%s', new_dir, cur_evt_name );
            if ~exist( resized_img_dir, 'dir' )
                mkdir( resized_img_dir );
            end
            
            resized_img_path = sprintf( '%s/%s.jpg', resized_img_dir, new_img_name );
            imwrite( resized_img, resized_img_path );
        end
        
    end
    
end