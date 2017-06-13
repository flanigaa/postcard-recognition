% Function to load, change, and save a new image representing
% the detections for each image
%
% Alec Flanigan 2017
%
% @param img_path path to the original image
% @param bboxes list of bboxes found in the image
% @param out_path output path to save the visualization of the
%   bounding boxes
function pr_save_detection( img_path, bboxes, out_path )
    
    raw_img = imread( img_path );
    
    for i=1 : size( bboxes, 1 )
        bbox = bboxes( i, : );
        raw_img = draw_bbox( raw_img, bbox );
    end
    
    imwrite( raw_img, out_path );
end

% Function to draw the bounding boxes on the image
%
% @param raw_img loaded image
% @param bbox bounding box to draw
% @return raw_img altered image with the bounding boxes
%   drawn on the image
function raw_img = draw_bbox( raw_img, bbox )

    start_x = round( bbox( 1 ) );
    start_y = round( bbox( 2 ) );
    end_x = round( bbox( 3 ) );
    end_y = round( bbox( 4 ) );
    
    width = end_x - start_x;
    height = end_y - start_y;
    
    colors = parula(100);
    color = colors( ceil( 100 * bbox( 5 ) ), : );
    
    line_width = 2;
    
    % top & bottom line
    for i=0 : width
        for j=0 : line_width-1
            raw_img( start_y+j, start_x+i, : ) = color*255;
            raw_img( end_y-j, start_x+i, : ) = color*255;
        end
    end
    
    % left & right line
    for i=0 : height
        for j=0 : line_width-1
            raw_img( start_y+i, start_x+j, : ) = color*255;
            raw_img( start_y+i, end_x-j, : ) = color*255;
        end
    end
end