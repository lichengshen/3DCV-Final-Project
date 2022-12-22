#!/bin/bash
export QT_QPA_PLATFORM='offscreen'

# The project folder must contain a folder "images" with all the images.
DATASET_PATH="<path/to/dataset>"
VOCTREE_PATH="<path/to/vocab_tree>"


colmap feature_extractor \
   --database_path $DATASET_PATH/database.db \
   --image_path $DATASET_PATH/ \
   --ImageReader.camera_model SIMPLE_RADIAL \
   --ImageReader.single_camera 1\
   --SiftExtraction.max_image_size 5184\
   --SiftExtraction.max_num_features 8192 \
   --SiftExtraction.first_octave -1 \
   --SiftExtraction.num_octave 4 \
   --SiftExtraction.octave_resolution 3 \
   --SiftExtraction.peak_threshold 0.00667 \
   --SiftExtraction.edge_threshold 10 \
   --SiftExtraction.estimate_affine_shape 0 \
   --SiftExtraction.max_num_orientations 2 \
   --SiftExtraction.upright 0 \
   --SiftExtraction.domain_size_pooling 0 \
   --SiftExtraction.dsp_min_scale 0.16667 \
   --SiftExtraction.dsp_max_scale 3 \
   --SiftExtraction.dsp_num_scales 10 \
   --SiftExtraction.num_threads -1 \
   --SiftExtraction.use_gpu 1 \
   --SiftExtraction.gpu_index 0 \

echo 
echo feature_extractor.....done
echo 

colmap sequential_matcher \
   --database_path $DATASET_PATH/database.db \
   --SequentialMatching.overlap 10 \
   --SequentialMatching.quadratic_overlap 1 \
   --SequentialMatching.loop_detection 1 \
   --SequentialMatching.loop_detection_period 10 \
   --SequentialMatching.loop_detection_num_images 50 \
   --SequentialMatching.loop_detection_num_nearest_neighbors 1 \
   --SequentialMatching.loop_detection_num_checks 256\
   --SequentialMatching.loop_detection_num_images_after_verification 0 \
   --SequentialMatching.loop_detection_max_num_features -1 \
   --SequentialMatching.vocab_tree_path $VOCTREE_PATH\
   --SiftMatching.num_threads -1 \
   --SiftMatching.use_gpu 1 \
   --SiftMatching.gpu_index 0 \
   --SiftMatching.max_ratio 0.8 \
   --SiftMatching.max_distance 0.7 \
   --SiftMatching.cross_check 1 \
   --SiftMatching.max_num_matches 32768 \
   --SiftMatching.max_error 4 \
   --SiftMatching.confidence 0.999 \
   --SiftMatching.max_num_trials 10000 \
   --SiftMatching.min_inlier_ratio 0.25 \
   --SiftMatching.min_num_inliers 15 \
   --SiftMatching.multiple_models 0 \
   --SiftMatching.guided_matching 1 \

echo 
echo sequential_matcher.....done
echo 

mkdir $DATASET_PATH/sparse

### maybe: Reconstruction>Reconstruction options
colmap mapper \
   --database_path $DATASET_PATH/database.db \
   --image_path $DATASET_PATH/ \
   --output_path $DATASET_PATH/sparse \

echo 
echo mapper.....done
echo 

mkdir $DATASET_PATH/dense

### still don't know where it is
colmap image_undistorter \
   --image_path $DATASET_PATH/ \
   --input_path $DATASET_PATH/sparse/0 \
   --output_path $DATASET_PATH/dense \
   --output_type COLMAP \
   --max_image_size -1 \

echo 
echo image_undistorter.....done
echo 

colmap patch_match_stereo \
   --workspace_path $DATASET_PATH/dense \
   --workspace_format COLMAP \
   --PatchMatchStereo.max_image_size 2400 \
   --PatchMatchStereo.gpu_index 0 \
   --PatchMatchStereo.depth_min -1 \
   --PatchMatchStereo.depth_max -1 \
   --PatchMatchStereo.window_radius 5 \
   --PatchMatchStereo.window_step 1 \
   --PatchMatchStereo.sigma_spatial -1 \
   --PatchMatchStereo.sigma_color 0.2 \
   --PatchMatchStereo.num_samples 15 \
   --PatchMatchStereo.ncc_sigma 0.6 \
   --PatchMatchStereo.min_triangulation_angle 1 \
   --PatchMatchStereo.incident_angle_sigma 0.9 \
   --PatchMatchStereo.num_iterations 5 \
   --PatchMatchStereo.geom_consistency 1 \
   --PatchMatchStereo.geom_consistency_regularizer 0.3 \
   --PatchMatchStereo.geom_consistency_max_cost 3 \
   --PatchMatchStereo.filter 1 \
   --PatchMatchStereo.filter_min_ncc 0.1 \
   --PatchMatchStereo.filter_min_triangulation_angle 3 \
   --PatchMatchStereo.filter_min_num_consistent 2 \
   --PatchMatchStereo.filter_geom_consistency_max_cost 1 \
   --PatchMatchStereo.cache_size 32 \
   --PatchMatchStereo.write_consistency_graph 0 \

echo 
echo patch_match_stereo.....done
echo 

colmap stereo_fusion \
   --workspace_path $DATASET_PATH/dense \
   --workspace_format COLMAP \
   --input_type geometric \
   --output_path $DATASET_PATH/dense/fused.ply \
   --StereoFusion.max_image_size 2400 \
   --StereoFusion.min_num_pixels 5 \
   --StereoFusion.max_num_pixels 10000 \
   --StereoFusion.max_traversal_depth 100 \
   --StereoFusion.max_reproj_error 2 \
   --StereoFusion.max_depth_error 0.01 \
   --StereoFusion.max_normal_error 10 \
   --StereoFusion.check_num_images 50 \
   --StereoFusion.cache_size 32 \

echo 
echo stereo_fusion.....done 
echo 

colmap poisson_mesher \
  --input_path $DATASET_PATH/dense/fused.ply \
  --output_path $DATASET_PATH/dense/meshed-poisson.ply \
  --PoissonMeshing.point_weight 1 \
  --PoissonMeshing.depth 13 \
  --PoissonMeshing.color 32 \
  --PoissonMeshing.trim 10 \
  --PoissonMeshing.num_threads -1 \

echo 
echo poisson_mesher.....done
echo 

colmap delaunay_mesher \
   --input_path $DATASET_PATH/dense \
   --output_path $DATASET_PATH/dense/meshed-delaunay.ply \
   --DelaunayMeshing.max_proj_dist 20 \
   --DelaunayMeshing.max_depth_dist 0.05 \
   --DelaunayMeshing.distance_sigma_factor 1 \
   --DelaunayMeshing.quality_regularization 1 \
   --DelaunayMeshing.max_side_length_factor 25 \
   --DelaunayMeshing.max_side_length_percentile 95 \
   --DelaunayMeshing.num_threads -1 \

echo 
echo delaunay_mesher.....done
echo 
