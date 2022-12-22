#this file convert bag file from Intel realsense to 3channel or 4 channel frame
import pyrealsense2 as rs
import numpy as np
import cv2
import sys, os, argparse, glob
# import matplotlib.pyplot as plt



# bag_file_path =  r'C:\Users\milers\Documents\20220607_133815.bag'
# bag_file_path =  r'C:\Users\milers\Desktop\ARK_20220613\bunch_tomatoes\first_row\20220608_101922.bag'

# savepath_RGBD = r"C:/Users/milers/Desktop/test/RGBD/"
# savepath_RGB = r"C:/Users/milers/Desktop/test/RGB/"

class BagToFrame:
    def __init__(self, args):
        # self.frame_paths = sorted(list(glob.glob(os.path.join(args.input, '*.png'))))
        self.args = args
        self.bag_file_path = args.input
        self.savepath = args.output
        self.interval = args.i

    def run(self):
        # Create a pipeline
        pipeline = rs.pipeline()

        #Create a config and configure the pipeline to stream
        #  different resolutions of color and depth streams
        config = rs.config()
        rs.config.enable_device_from_file(config,self.bag_file_path, repeat_playback=False)
        # config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 30)
        # config.enable_stream(rs.stream.color, 1280, 720, rs.format.bgr8, 30)

        # Start streaming
        profile = pipeline.start(config)
        playback = profile.get_device().as_playback()  #固定frame數量
        playback.set_real_time(False) #固定frame數量

        # Getting the depth sensor's depth scale (see rs-align example for explanation)
        depth_sensor = profile.get_device().first_depth_sensor()
        depth_scale = depth_sensor.get_depth_scale()
        print("Depth Scale is: " , depth_scale)

        # We will be removing the background of objects more than
        #  clipping_distance_in_meters meters away
        # clipping_distance_in_meters = 1 #1 meter
        # clipping_distance = clipping_distance_in_meters / depth_scale

        # Create an align object
        # rs.align allows us to perform alignment of depth frames to others frames
        # The "align_to" is the stream type to which we plan to align depth frames.
        align_to = rs.stream.color
        align = rs.align(align_to)
        i = 0

        colorizer = rs.colorizer(2) #2 white to black
        # hole_filling = rs.hole_filling_filter()
        # Streaming loop
        try:
            while True:
                # Get frameset of color and depth

                frames = pipeline.wait_for_frames()

                # Align the depth frame to color frame
                aligned_frames = align.process(frames)


                # Get aligned frames
                aligned_depth_frame = aligned_frames.get_depth_frame() # aligned_depth_frame is a 640x480 depth image
                # print((np.asanyarray(aligned_depth_frame.get_data())).dtype)
                # filled_aligned_depth_frame = hole_filling.process(aligned_depth_frame)
                aligned_depth_color_frame = colorizer.colorize(aligned_depth_frame)
                # filled_aligned_depth_frame = colorizer.colorize(filled_aligned_depth_frame)

                color_frame = aligned_frames.get_color_frame()

                # Validate that both frames are valid
                if not aligned_depth_frame or not color_frame:
                    continue

                # depth_image = np.asanyarray(aligned_depth_frame.get_data())
                depth_image = np.asanyarray(aligned_depth_color_frame.get_data())
                # filled_depth_img = np.asanyarray(filled_aligned_depth_frame.get_data())
                # print(depth_image.shape)
                # print(depth_image.dtype)
                depth_image_gray = cv2.cvtColor(depth_image, cv2.COLOR_BGR2GRAY)
                # filled_depth_img_gray = cv2.cvtColor(filled_depth_img, cv2.COLOR_BGR2GRAY)

                # print(depth_image_gray.dtype)
                # print(depth_image_gray.shape)

                # depth_image = depth_image.astype('uint8')
                color_image = np.asanyarray(color_frame.get_data())

                r_channel, g_channel, b_channel = color_image[:,:,0], color_image[:,:,1], color_image[:,:,2]
                
                img_BGR = cv2.merge((b_channel, g_channel, r_channel))
                img_BGRD = cv2.merge((b_channel, g_channel, r_channel,depth_image_gray))
                # img_BGRD = cv2.merge((b_channel, g_channel, r_channel, depth_image_gray))
                # filled_img_BGRD = cv2.merge((b_channel, g_channel, r_channel, filled_depth_img_gray))
                
                # if i % self.interval == 0:
                    # cv2.imwrite(self.savepath+ "/rgb/frame_rgb_" + str(i) + ".png", img_BGR)
                    # cv2.imwrite(self.savepath+ "/depth/frame_depth_" + str(i) + ".png", img_BGRD)

                # print(i)
                i += 1

                # images = np.vstack((img_BGR, depth_image))
                # cv2.namedWindow('f:', cv2.WINDOW_AUTOSIZE)

                # cv2.namedWindow('f:', cv2.WINDOW_NORMAL)
                # cv2.resizeWindow('f:', 1024, 1152)
                # cv2.imshow('file:'+ bag_file_path, filled_depth_img)
                # cv2.imshow('f:'+ bag_file_path, depth_image)
                # cv2.imshow('f:'+ bag_file_path, depth_image_gray)

                # print(img_BGRD.shape)
                cv2.imshow('f:'+ self.bag_file_path, img_BGR)
                key = cv2.waitKey(1)

                # if i >= 258:
                    # break
                # Press esc or 'q' to close the image window
                if key & 0xFF == ord('q') or key == 27:
                    cv2.destroyAllWindows()
                    break
                
        finally:
            # print(b_channel.dtype)
            # print(g_channel.dtype)
            # print(r_channel.dtype)
            # print(depth_image.dtype)
            # print("img_BGRD shape:", img_BGRD.shape)
            # print(depth_image.shape)
            # print("img_BGRD type:", type(img_BGRD))
            # hist= cv2.calcHist([color_image],[0],None, [256], [0,256])
            # plt.plot(hist)

            pipeline.stop()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', 
                        help='input bag file')
    parser.add_argument('--i',
                    type=int,
                    default=5,
                    help='the interval of frame')
    parser.add_argument('--output',
                        default='./',
                        help='output folder')

    args = parser.parse_args()

    vo = BagToFrame(args)
    vo.run()
