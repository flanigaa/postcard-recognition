% Function used to run the tiny_face_detector on a single image--returning
% the bounding boxes found
%
% Alec Flanigan 2017
%
% @param filePath absolute or relative path to the image that will be
%   tested
% @param outputDir directory to send the newly created image with bounding
%   boxes shown. Output directory can be empty and will result in not
%   saving the image nor the mat file of the bounding boxes.
% @param prob_thresh a minimum confidence threshold to use for the bounding
%   boxes. Lower threshhold results in more bounding box detections.
% @param nms_thresh overlap threshold
% @param gpu_id which gpu to use for testing. Starts at 1, 0 means no use
%   of gpu
% @return matrix of bounding boxes for the image
function bboxes = testPicture( filePath, outputDir, prob_thresh, nms_thresh, gpu_id, img_as_path, display_image )
    addpath tiny-face;
    
    if nargin < 6 || isempty( img_as_path )
        img_as_path = true;
    end
    if nargin < 7 || isempty( display_image )
        display_image = false;
    end

    % runs tiny_face_detector on the given image with the given parameters
    bboxes = tiny_face_detector( filePath, outputDir, prob_thresh, ...
        nms_thresh, gpu_id, img_as_path, display_image );
    
    % saves the bounding boxes to a mat file in the same directory of the
    %   saved image if given an output directory
    if ~isempty( outputDir )
        splitPath = strsplit( filePath, '/' );
        endPath = strsplit( splitPath{ length(splitPath) }, '.' );
        endPath = strcat( outputDir, '/', endPath{1} );
        save( endPath, 'bboxes' );
    end
end