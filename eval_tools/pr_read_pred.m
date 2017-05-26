% The function used in fr_eval to read the predictions into a prediction 
% list.
%
% Alec Flanigan 2017
%
% The function is modelled after the read_pred function from 
% widerface while containing changes that format the prediction list to
% contain only data from tested file.
%
% @param file_dir directory to read the prediction files from
% @param gt_dir directory to load the ground truth from
% @return pred_list the formatted prediction list
% @return evt_idx structure containing the corresponding indices from the
%   tested files to the ground truth.
function [ pred_list, evt_idx ] = pr_read_pred( file_dir, gt_dir )

    load(gt_dir);
    event_num = 61;
    evt_idx = [];

    % finds the indices of the existing tests within the ground truth
    for i = 1:event_num
        if exist( sprintf( '%s/%s', file_dir, event_list{ i } ), 'dir')

            img_idx = [];
            img_list = file_list{i};
            img_num = size(img_list,1);
            for j = 1:img_num
                if exist(sprintf('%s/%s/%s.txt',file_dir,event_list{i},img_list{j}),'file')
                    img_idx = vertcat( img_idx, j );
                end
            end

            evt_cell = cell( 1, 2 );
            evt_cell( 1, 1 ) = num2cell( i );
            evt_cell( 1, 2 ) = mat2cell( img_idx, size( img_idx, 1 ), 1 );
            evt_idx = vertcat( evt_idx, evt_cell );

        end
    end

    evts_fnd = size( evt_idx, 1 );
    pred_list = cell( evts_fnd, 1 );

    % formats the prediction list
    for i = 1:evts_fnd
        cur_evt_num = evt_idx{ i, 1 };
        fprintf( 'Read prediction: current event %d\n', cur_evt_num );
        cur_evt_imgs = evt_idx{ i, 2 };

        imgs_fnd = size( cur_evt_imgs, 1 );
        img_list = file_list{ cur_evt_num };
        bbx_list = cell( imgs_fnd,1 );

        for j = 1:imgs_fnd
            cur_img_num = cur_evt_imgs( j, 1 );

            fid = fopen(sprintf('%s/%s/%s.txt',file_dir,event_list{ cur_evt_num },img_list{ cur_img_num }),'r');
            tmp = textscan( fid, '%s', 'Delimiter', '\n' );
            tmp = tmp{ 1 };
            fclose( fid );
            try
                bbx_num = tmp{2,1};
                bbx_num = str2num(bbx_num);
                bbx = zeros(bbx_num,5);
                if bbx_num ==0
                    continue;
                end
                for k = 1:bbx_num
                    raw_info = str2num(tmp{k+2,1});
                    bbx(k,1) = raw_info(1);
                    bbx(k,2) = raw_info(2);
                    bbx(k,3) = raw_info(3);
                    bbx(k,4) = raw_info(4);
                    bbx(k,5) = raw_info(end);
                end
                [~, s_index] = sort(bbx(:,5),'descend');
                bbx_list{j} = bbx(s_index,:);
            catch
                fprintf('Invalid format %s %s\n',event_list{cur_evt_num},img_list{j});
            end

        end
        pred_list{i} = bbx_list;
    end
end