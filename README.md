# 3DCV-Final-Project-GROUP14
This is group 14 final project for 3DCV
## Usage
### Colmap
* Run colmap.sh to create point cloud file
```
bash colmap.sh
```
* Merge ply files
```
python merge_ply_files.py --input <path/to/all/ply/files> --output <path/to/output>
```

### Meshroom
### Maplab
### ORB-SLAM

## Dataset
[Dataset](https://cloud.lalalachuck.com:9999/index.php/s/YFXkLiWS8dHd5Nr?fbclid=IwAR3p7WdAIoRPrgfy2oAAJp97stQjc6yHydjc4CVGl94wJNCCZPqFmGf9FUQ)
* bag file to RGB frame
```
python bag2frame2_RGBRGBD_SaveAsPng.py --input <path/to/input> --i <interval_of_frame> --output <path/to/output>
```

## Output
[Merge output](https://cloud.lalalachuck.com:9999/index.php/s/6oPag7Fmtr62L3e?path=%2F)
