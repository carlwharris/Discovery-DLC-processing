
import ffmpeg  # Note: import ffmpeg is not a must, when using OpenCV solution.
import cv2
import sys

def ReduceFrameRate(in_filename, skipSec):
    out_filename = "Trim_" + in_filename
    print(out_filename)
    fps = 1

    # Open video file for reading
    in_vid = cv2.VideoCapture(in_filename)
    width  = int(in_vid.get(3))
    height = int(in_vid.get(4))

    out_vid = cv2.VideoWriter(out_filename, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))

    fps = in_vid.get(cv2.CAP_PROP_FPS)
    totalNoFrames = in_vid.get(cv2.CAP_PROP_FRAME_COUNT);
    duration = float(totalNoFrames) / float(fps)
    duration = duration * 1000
    skipMSec = skipSec * 1000

    currTime = 0
    while currTime < duration:
        in_vid.set(cv2.CAP_PROP_POS_MSEC,currTime)
        ok, frame = in_vid.read()
        out_vid.write(frame)
        currTime += skipMSec

    out_vid.release()
    
if __name__ == '__main__':
    in_filename = sys.argv[1];
    skipSec = int(sys.argv[2]);
    ReduceFrameRate(in_filename, skipSec)
