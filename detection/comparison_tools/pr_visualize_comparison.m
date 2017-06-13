function pr_visualize_comparison( detection_list, show_list, gt_info, img_dir_path, output_dir )
    
    for i=1 : size( show_list, 1 )
        
        evt_name = gt_info.event_list{ i, 1 };
        evt_detection_list = detection_list{ i, 1 };
        evt_show_list = show_list{ i, 1 };
        evt_file_list = gt_info.file_list{ i, 1 };
        
        for j=1 : size( evt_show_list, 1 )
            if evt_show_list( j, 1 )
                file_detection_bboxes = evt_detection_list{ j, 1 };
                file_name = evt_file_list{ j, 1 };
                file_path = sprintf( '%s/%s/%s.jpg', img_dir_path, evt_name, file_name );
                
                full_output_dir = sprintf( '%s/%s', output_dir, evt_name );
                output_path = sprintf( '%s/%s', full_output_dir, file_name );
                if ~exist( full_output_dir, 'dir')
                    mkdir( full_output_dir );
                end
                
                pr_draw_comparison( file_path, file_detection_bboxes, output_path );
            end
        end
    end
end