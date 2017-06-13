% Function to draw the comparison rectangles over the image and then save
% the modified image.
%
% Alec Flanigan 2017
%
% @param file_path path to the image
% @param bboxes list of bounding boxes and whether they were seen for both
%   sets
% @param output_path path to save the modified file to
function pr_draw_comparison( file_path, bboxes, output_path )

    addpath 'export_fig';

    raw_img = imread( file_path );
    
    % Code reused from tiny_face_detector
    raw_img = single(raw_img);
    [raw_h, raw_w, ~] = size(raw_img);
    MAX_DISP_DIM = 3000;
    % % visualize with grace 
    vis_img = raw_img;
    vis_bbox = bboxes;
    if max(raw_h, raw_w) > MAX_DISP_DIM
      vis_scale = MAX_DISP_DIM/max(raw_h, raw_w);
      vis_img = imresize(raw_img, vis_scale);
      vis_bbox(:,1:4) = vis_bbox(:,1:4) * vis_scale;
    end
    visualize_detection( uint8( vis_img ), vis_bbox );

    %
    drawnow;

    % (optional) export figure
    if ~isempty(output_path)
      export_fig('-dpng', '-native', '-opengl', '-transparent', output_path, '-r300');
    end
    % end code reuse
    
end

% Function reused from tiny_face_detector with a small adjustment for
% comparing results
function visualize_detection( img, bbox )

    if ~isempty(img), imshow(img); end

    hold on;
    for i = 1:size(bbox, 1)
        if bbox(i,5) && bbox(i,6)
            color = 'g';
        elseif bbox(i,5) && ( ~bbox(i,6) )
            color = 'c';
        elseif ( ~bbox(i,5) ) && bbox(i,6)
            color = 'y';
        else
            color = 'r';
        end
        lw = 1;
        rectangle('position', [bbox(i,1:2) bbox(i,3:4)-bbox(i,1:2)+1], ...
                'EdgeColor', color, 'LineWidth', lw);
    end
    hold off;
    axis off;
    drawnow;
end