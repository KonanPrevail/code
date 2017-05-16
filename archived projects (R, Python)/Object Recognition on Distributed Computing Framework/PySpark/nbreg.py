from StringIO import StringIO
from PIL import Image # Image module for image processing #
import numpy as np
import math
import sys
from pyspark import SparkContext
from pyspark.mllib.classification import NaiveBayes, NaiveBayesModel
from pyspark.mllib.linalg import Vectors
from pyspark.mllib.regression import LabeledPoint

# CCD sizes
ccd_x_mm=22.2
ccd_y_mm=14.8

# original image size
enx=2256
eny=1504

# cropped image size
cropenx=701 
cropeny=341

# camera shift in mm in each direction 
x_shift_mm=5
y_shift_mm=5

# number of camera positions along x and y directions
x_num=7
y_num=4

# focal length
f=40

# starting and ending images indices 
im_start=1
im_end=28

# upfront shift
offsetshift=63

# number of classes, 3 toy car objects of size: 70 mm x 30 mm x 15 mm
class_num=3

# number of angles each object, Each car is placed on a stage at 270 mm from the camera lens. 
# the stage turns at 6 different angles of 0, 5, 10, 15, 20 and 25. 
angle_num=6

# stack() function to superimpose 2D images with overlaps inside Map Reduce
def stack(image, index, shift_px):
    # shift of shift_px for both x and y directions from the mapper function
    x_shift_px=shift_px-offsetshift
    y_shift_px=x_shift_px
    # reconstructed image, initialized with a multi dimensional arrays of zeros
    elem = np.zeros((cropeny+(y_shift_px)*(y_num-1), cropenx+(x_shift_px)*(x_num-1),3))
    # array for normalization
    overlap=np.zeros((cropeny+(y_shift_px)*(y_num-1), cropenx+(x_shift_px)*(x_num-1)))	
    # i is image index along x
    i=(index-im_start+1)%x_num
    if (i==0): 
        i=x_num
    # k is image index along y	
    k=math.ceil((index-im_start+1)/float(x_num))
    # superimpose an image to the sum of the images
    elem[y_shift_px*(k-1):y_shift_px*(k-1)+cropeny, x_shift_px*(i-1):x_shift_px*(i-1)+cropenx,:]=elem[y_shift_px*(k-1):y_shift_px*(k-1)+cropeny, x_shift_px*(i-1):x_shift_px*(i-1)+cropenx,:]+image
    # sum of ones for normalization later
    overlap[y_shift_px*(k-1):y_shift_px*(k-1)+cropeny, x_shift_px*(i-1):x_shift_px*(i-1)+cropenx]=overlap[y_shift_px*(k-1):y_shift_px*(k-1)+cropeny, x_shift_px*(i-1):x_shift_px*(i-1)+cropenx]+np.ones((cropeny,cropenx))
    return(elem,overlap)

# find the key for each image based on its path, for example if name of image is car_1_angle_1_0003.jpg 
# findKey returns car_1_angle_1 and findNumber returns 0003 
def findKey(path,shift_px_i):
    length = len(path)
    return(path[length-22:length-9]+"_"+str(shift_px_i))

# return the absolute image number from 1-28 at 1 camera angle, for example 3
def findNumber(path):
    length = len(path)
    return(int(path[length-8:length-4]))

# read all the images from HDFS into Spark Context in the form of Binary Files
# here there are 3*6*28 = 504 
images = sc.binaryFiles("C:\image\imcrop\*") 

# lambda function to convert the images into Array
image_array = lambda rawdata: np.asarray(Image.open(StringIO(rawdata)))

# initial map to get key value pairs, for example if the image name is car_1_angle_1_0003.jpg
# imagerddu will have (key,value) -> (car_1_angle_1,(Imagearray,3,78))
# 78px is the shift in px corresponding to the first reconstruction distance
# StringIO: 
imagerddu = images.map(lambda (x,y): (findKey(x,78),(np.asarray(Image.open(StringIO(y))),findNumber(x),78)))

# with the reconstruction distance changes, the shift in px between 2D images are from 77px-64px (14 reconstructed distances)
# append all these images to RDD imagerddu
# imagerddu will now have 3(cars)*6(angles)*28(images)*15(reconstruction distances)=7560
for shift_px in range(77,63,-1):
    imagerdd1 = images.map(lambda (x,y): (findKey(x,shift_px),(np.asarray(Image.open(StringIO(y))),findNumber(x),shift_px)))	
    imagerddu = imagerddu.union(imagerdd1)

# createScoreCombiner, scoreCombiner, scoreMerger are part of Map reduce function combineByKey
def createScoreCombiner(imageprops):
    (imgarray, number, shift_px) = imageprops
    return (stack(imgarray, number, shift_px))

def scoreCombiner(collector, imageprops):
    (elemC, overlapC) = collector
    (imgarray, number, shift_px) = imageprops
    (elemP, overlapP) = stack(imgarray, number, shift_px)
    return ((elemC+elemP),(overlapC + overlapP))

def scoreMerger(collector1, collector2):
    (elem1, overlap1) = collector1
    (elem2, overlap2) = collector2
    return((elem1 + elem2), (overlap1 + overlap2))

# Function to divide the overlap from the sum of all images
def imageAVG(canvas):
    (elem, overlap) = canvas
    elem[:,:,0] = elem[:,:,0]/overlap
    elem[:,:,1] = elem[:,:,1]/overlap
    elem[:,:,2] = elem[:,:,2]/overlap    
    return(elem)
	
# combineByKey gets grouped by all all keys, for example all 28 images with key car_1_angle_1 will be grouped and sent.
imageElemRdd = imagerddu.combineByKey( 
								createScoreCombiner, 
								scoreCombiner, 
								scoreMerger
								)

# Function to call imageAVG
imageRecRDD = imageElemRdd.map(lambda (x,y): (x, imageAVG(y)))

# Convert the image array to uint8
#####################################################################################################
imageOutuint = imageRecRDD.map(lambda (x,y): (x,(y.astype(np.uint8))))
imageOutIMG = imageOutuint.map(lambda (x,y): (x,(Image.fromarray(y))))
imageOutIMG.persist()
# Create an iterator and save the images with the mentioned path.
# path = "file:///Users//mcd04005//recon//" + x + ".jpg" 
for x,img in imageOutIMG.toLocalIterator():
    path = x + ".jpg" 
    img.save(path)
#####################################################################################################

def imageFlatten(elem):
    return((elem[:,:,0]+elem[:,:,1]+elem[:,:,2])/3)

def logTransform(flat):	
	flat = np.log(flat)
	flat[np.isneginf(flat)]=0
	return(flat)

def reshape(imagearr):	
    return(imagearr[0:344,0:707])

imageDataSetRDD = imageRecRDD.map(lambda (x,y): (x, imageFlatten(y)))
imageVec = imageDataSetRDD.map(lambda (x,y):(x,reshape(y))).map(lambda (x,y):(x,y.flatten()))


imageNB = imageVec.map(lambda (x,y):(x[4],y)).map(lambda (x,y): LabeledPoint(x, Vectors.dense((y))))

training, test = imageNB.randomSplit([0.6, 0.4], seed=0)

# Train a naive Bayes model.
model = NaiveBayes.train(training, 1.0)

# Make prediction and test accuracy.
predictionAndLabel = test.map(lambda p: (model.predict(p.features), p.label))
predictionAndLabel.saveAsTextFile("file:///image//result")
accuracy = 1.0 * predictionAndLabel.filter(lambda (x, v): x == v).count() / test.count()
# >>> accuracy
# 0.9357798165137615