import numpy as np
import cv2
from os import listdir
from os.path import isfile, join
import mysql.connector
import dlib
import openface
import getComparisons

##======================================
##This script truncates and rebuilds the
##tblFaceImages table from the
##contents of tblSourceImages.
##Then it builds the tblComparisons
##table, then the preview webpage.
##======================================


#Flags and constants
contextImageHeight = 400
showImagesDuringProcessing = False


print('Connecting to AFID database...')
#make a connector for SQL
cx = mysql.connector.connect(user='root',password='Mtm9WAVkbM5w',host='127.0.0.1',database='AFID')
cursor = cx.cursor()

#print('Truncating tblFaceImage...')
#cursor.execute("truncate table tblFaceImage")
#cursor.reset()

#and loop over tblSourceImage
sourceResults = []
print('getting source images')
cursor.execute("select pk, imageURL from tblSourceImage")
#cursor.execute("select pk, imageURL from tblSourceImage where pk =12")
for (sourceImagePK, sourceImage) in cursor:
  sourceResults.append((sourceImagePK, sourceImage))



if showImagesDuringProcessing is True:
  #Make a window for displaying images.
  cv2.startWindowThread()
  cv2.namedWindow('Image')

for (sourceImagePK, sourceImage) in sourceResults:
  print sourceImage,"..."
  filename = sourceImage
  filenameBase = filename.split('.')[0]
  img = cv2.imread(join('sourceImages',sourceImage))
  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
  
  contextImg = np.copy(img)
  scaleFactor = contextImageHeight/float(contextImg.shape[0])
  
  #Save the context image for this source: (That is, a scaled-down version of the source image with boxes over all the faces.)
  contextImg = cv2.resize(contextImg,(int(float(contextImg.shape[1]) * (scaleFactor)),contextImageHeight),interpolation = cv2.INTER_CUBIC)
  cv2.imwrite('contextImages/'+filenameBase+'_context.jpg',contextImg)
  #cv2.waitKey(0)
if showImagesDuringProcessing is True:
  cv2.destroyAllWindows()
    
#Close the connection to the database
cursor.close()
cx.close()

