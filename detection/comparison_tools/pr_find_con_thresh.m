% Function to find the highest confidence threshold for the defined
% precision. Precision is calculated by dividing the true faces detected
% (col 2) by the total number of detection (col 1).
function con_thresh = pr_find_con_thresh( org_pr_path, prec_thresh )
    load( org_pr_path );
    prec_idx = 0;
    num_of_thresh = size( org_pr_curve, 1 );
    for l=1 : num_of_thresh
        cur_prec = org_pr_curve( l, 2 ) / org_pr_curve( l, 1 );
        if ( cur_prec >= prec_thresh )
            prec_idx = l;
        else
            break;
        end
    end
    con_thresh = 1 - ( (1/num_of_thresh) * prec_idx );
end