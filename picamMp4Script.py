from picamera2 import Picamera2, Preview
from picamera2.encoders import Quality
from picamera2.encoders import H264Encoder
from picamera2.outputs import FfmpegOutput
from time import sleep
from datetime import datetime

from tkinter import *
from tkinter import filedialog
from pathlib import Path

from tkinter import simpledialog

from pathvalidate import sanitize_filepath

#Create Button Function for data input
def get_file_path():
    global directory
    home = str(Path.home())
    directory = home
    # Open and return file path
    directory = filedialog.askdirectory(
    title = "Select Save Directory for Video", 
    initialdir = home,
    )
    l1 = Label(window, text = "File Path: " + directory).pack()
window = Tk()
width = window.winfo_screenwidth()
height = window.winfo_screenheight()

def close():
    window.destroy()

# Creating a button to search the file
b1 = Button(window, text = "Select Directory", command = get_file_path).pack()
b2 = Button(window, text = "OK", command = close).pack()
window.geometry("%dx%d" % (width / 2, height / 2))
window.mainloop()


now = datetime.now()
timeMinutes = simpledialog.askinteger(
    title = 'Length of Recording in Minutes',
    prompt = 'Enter Length of Recording in Minutes'
)
timeSeconds = timeMinutes * 60
dateAndTime = now.strftime("%m,%d,%Y--%H-%M-%S")
animalName = simpledialog.askstring(
    title = "Animal Name" ,
    prompt = "Enter Animal Name: "
)

#animalName = 'test'
#filename = "/media/camerapi1/b125d8d6-317b-4b88-9dfd-216329074a5c/Data/Video" + "/" + animalName + ":" + dateAndTime + ".h264"
directory = sanitize_filepath(Path(directory), platform='auto')
filename = str(directory) + "/" + animalName + "-" + dateAndTime + ".mp4"
print(filename)

picam2 = Picamera2()
#picam2.video_configuration.controls.FrameRate = 30.0
video_config = picam2.create_video_configuration()
picam2.configure(video_config)

#encoder = H264Encoder(10000000)
encoder = H264Encoder()
output = FfmpegOutput(filename)

picam2.start_preview(Preview.QTGL)
picam2.start_recording(encoder,output,Quality.VERY_HIGH)
sleep(timeSeconds)
picam2.stop_recording()
picam2.stop_preview()

