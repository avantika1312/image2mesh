function fgraph = create_graph(class_uid)
if nargin < 1
    class_uid = '02924116';
end

data_paths
graph_file = fullfile(Graph_dir, sprintf('%s.mat', class_uid));
switch class_uid
    case class2uid('diningtable')
        throd_edges = 0.01;
    case class2uid('bottle')
        throd_edges = 0.01;
    case class2uid('bicycle')
        throd_edges = 0.01;
    otherwise
        throd_edges = 1;
end

if exist(graph_file, 'file')
    fgraph = load(graph_file);
    fgraph = fgraph.obj;
else
    fgraph = fusionGraph(class_uid);
    fgraph.connect_nodes();
    
    % voxelize all models
    cd ~/compact_3D_reconstruction/python/
    commandStr = ['python vxl.py -c ', class_uid, ' -r 128'];
    fprintf('Voxelizing models... \n')
    [status, commandOut] = unix(commandStr, '-echo');
    cd ~/compact_3D_reconstruction/
    
    % compute voxel IoU
    voxel_iou = compute_all_voxel_iou(fgraph);
    
    % create edges
    thd_dist = 0.035;
    thd_iou = 0.25;
    createEdges(fgraph, voxel_iou, thd_dist, thd_iou);
    
    % save graph
    fgraph.save();
end
