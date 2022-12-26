# 3DCV-Final-Project-GROUP14
This is group 14 final project for 3DCV


## Usage
### COLMAP
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
### ORB-SLAM 3 
* Feed segmented mp4 to SLAM
```
- put myvideo.cpp under ORB_SLAM folder
- replace origin Cmakefile
- Rebuild with ORB-SLAM build.sh
```
### CloudCompare
* ICP paremeter
```
Random sampling limit: 50000
Rotation: unfixed
RMS difference: 1.0e-06
```
* To merge ply into one
```
CloudCompare -O {filename} -MERGE_CLOUDS
```
## Dataset
[Dataset](https://cloud.lalalachuck.com:9999/index.php/s/YFXkLiWS8dHd5Nr?fbclid=IwAR3p7WdAIoRPrgfy2oAAJp97stQjc6yHydjc4CVGl94wJNCCZPqFmGf9FUQ)

* bag file to RGB frame
```
python bag2frame2_RGBRGBD_SaveAsPng.py --input <path/to/input> --i <interval_of_frame> --output <path/to/output>
```

## Output
[Merge output](https://cloud.lalalachuck.com:9999/index.php/s/6oPag7Fmtr62L3e?path=%2F)
