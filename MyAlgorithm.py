from sensors import sensor
import numpy as np
import threading
import cv2


def YUVa255(Y, U, V):
    Y = Y * 255
    U = (U + 0.5) / 0.8 * 255
    V = (V + 0.6) / 1.2 * 255
    return Y, U, V

class MyAlgorithm():

    def __init__(self, sensor):
        self.sensor = sensor
        self.imageRight=None
        self.imageLeft=None
        self.lock = threading.Lock()

    def execute(self):
        #GETTING THE IMAGES
        imageLeft = self.sensor.getImageLeft()
        imageRight = self.sensor.getImageRight()

        # Convert BGR to HSV
        iLyuv = cv2.cvtColor(imageLeft, cv2.COLOR_RGB2YUV)
        lowpass = [0, -0.8, 0.25]
        highpass = [0.38, 0, 0.45]
        lowpass = YUVa255(*lowpass)
        highpass = YUVa255(*highpass)

        ILyuvInRange = cv2.inRange(iLyuv, lowpass, highpass)

        IlyuvInRange3channels = np.dstack((ILyuvInRange, ILyuvInRange, ILyuvInRange))

        # Add your code here
        print "Runing"

        #EXAMPLE OF HOW TO SEND INFORMATION TO THE ROBOT ACTUATORS
        #self.sensor.setV(10)
        #self.sensor.setW(5)


        #SHOW THE FILTERED IMAGE ON THE GUI
        self.setRightImageFiltered(IlyuvInRange3channels)
        self.setLeftImageFiltered(IlyuvInRange3channels)



    def setRightImageFiltered(self, image):
        self.lock.acquire()
        self.imageRight=image
        self.lock.release()


    def setLeftImageFiltered(self, image):
        self.lock.acquire()
        self.imageLeft=image
        self.lock.release()

    def getRightImageFiltered(self):
        self.lock.acquire()
        tempImage=self.imageRight
        self.lock.release()
        return tempImage

    def getLeftImageFiltered(self):
        self.lock.acquire()
        tempImage=self.imageLeft
        self.lock.release()
        return tempImage

