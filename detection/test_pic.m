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
% @param display_image whether or not the image should be displayed
% @param tiny_face_path directory path to the tiny-face directory
% @param model_path if using a different model, specify the path, otherwise
%   leave empty for tiny-face default
%
% @return matrix of bounding boxes for the image
function bboxes = test_pic( filePath, outputDir, prob_thresh, nms_thresh, gpu_id, display_image, tiny_face_path, model_path )
    addpath( tiny_face_path );
    
    if nargin < 6 || isempty( display_image )
        display_image = false;
    end
    if nargin < 7 || isempty( tiny_face_path )
        tiny_face_path = 'tiny-face';
    end
    if nargin < 8 || isempty( model_path )
        model_path = sprintf( '%s/trained_models/hr_res101.mat', tiny_face_path );
    end

    % runs tiny_face_detector on the given image with the given parameters
    bboxes = tiny_face_detector_bk( filePath, outputDir, prob_thresh, ...
        nms_thresh, gpu_id, display_image, tiny_face_path, model_path );
    
    % saves the bounding boxes to a mat file in the same directory of the
    %   saved image if given an output directory
    if ~isempty( outputDir )
        splitPath = strsplit( filePath, '/' );
        endPath = strsplit( splitPath{ end }, '.' );
        endPath = sprintf( '%s/%s', outputDir, endPath{ 1 } );
        save( endPath, 'bboxes' );
    end
end