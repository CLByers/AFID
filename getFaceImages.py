import numpy as np
import cv2
from os import listdir
from os.path import isfile, join
import mysql.connector
import dlib
import openface
import facialRecFunctions

##======================================
##This script updates the
##tblFaceImages table from the
##contents of tblSourceImages.
##Then it updates the tblComparisons
##table.
##======================================

updateTblFaceImages()
facialRecFunctions.populateComparisons()

def updateTblFaceImages:
	#Flags and constants
	contextImageHeight = 400
	showImagesDuringProcessing = False

	print('Loading detectors...')
	#get our cascades
	face_cascade1 = cv2.CascadeClassifier('/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_default.xml')
	#face_cascade3 = cv2.CascadeClassifier('/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml')
	#face_cascade2 = cv2.CascadeClassifier('/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt2.xml')

	align = openface.AlignDlib("/home/charlie/openface/models/dlib/shape_predictor_68_face_landmarks.dat")
	net = openface.TorchNeuralNet("/home/charlie/openface/models/openface/nn4.small2.v1.t7", 96)


	print('Connecting to AFID database...')
	#make a connector for SQL
	cx = mysql.connector.connect(user='AfidUser',password='AfidUserPassword',host='127.0.0.1',database='AFID')
	cursor = cx.cursor()


	addFaceImage = ("INSERT INTO tblFaceImage "
		          "(sourceImageFK, boundingRectLeft, boundingRectTop, boundingRectWidth, boundingRectHeight, imageData, representationData, imageURL) "
		          "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)")
	deleteFaceImageForSourcePK = ("delete from tblFaceImage where sourceImageFK = {0}")

	#and loop over tblSourceImage
	sourceResults = []
	print('getting source images')
	cursor.execute("select pk, imageURL from tblSourceImage where lastProcessedDate is null")
	for (sourceImagePK, sourceImage) in cursor:
	  sourceResults.append((sourceImagePK, sourceImage))



	if showImagesDuringProcessing is True:
	  #Make a window for displaying images.
	  cv2.startWindowThread()
	  cv2.namedWindow('Image')

	for (sourceImagePK, sourceImage) in sourceResults:
	  cursor.execute(deleteFaceImageForSourcePK.format(int(sourceImagePK)))
	  #Notice that deletions will 'cascade' into tblComparison, so it doesn't have to be explicitly cleaned up.
	  print sourceImage,"..."
	  filename = sourceImage
	  filenameBase = filename.split('.')[0]
	  img = cv2.imread(join('sourceImages',sourceImage))
	  gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

	  
	  faces = face_cascade1.detectMultiScale(gray,1.3,5)
	  print len(faces), "faces detected."

	  #faceNumber becomes the suffix for image filenames. Not related to any database field.
	  faceNumber = 0

	  contextImg = np.copy(img)
	  scaleFactor = contextImageHeight/float(contextImg.shape[0])
	  
	  for (x,y,w,h) in faces:
		
		faceNumber+=1
		#cv2.rectangle(contextImg,(x,y),(x+w,y+h),(200,200,200),4)
		height, width, depth = img.shape

		x2 = x - w/4
		y2 = y - h/4
		w2 = int(w * 1.5)
		h2 = int(h * 1.5)
		if x2 < 0: x2 = 0
		if y2 < 0: y2 = 0
		if x2+w2 > width: w2 = width - x2
		if y2+h2 > height: h2 = height - y2
		cropped = img[y2:y2+h2, x2 :x2+w2]
		scaled = cv2.resize(cropped,(192,192),interpolation = cv2.INTER_CUBIC)
		faceImageFilename = 'faceImages/'+filenameBase+'_'+str(faceNumber)+'.jpg'

		#bbox = align.getLargestFaceBoundingBox(cropped)

		bbox = dlib.rectangle(int(x),int(y), int(x+w), int(y+h))
		alignedFace = align.align(96, img, bbox, landmarkIndices=openface.AlignDlib.OUTER_EYES_AND_NOSE)

		#alignedFace = align.align(96, cropped, landmarkIndices=openface.AlignDlib.OUTER_EYES_AND_NOSE)

		if alignedFace is None:
		    raise Exception("Unable to align image: {}".format(filenameBase))

		cv2.imwrite(faceImageFilename,scaled)
		
		#And get the representation that will be used to measure similarities
		rep = net.forward(alignedFace)

		if showImagesDuringProcessing is True:
		  cv2.imshow('Image',alignedFace)
		##For each one: insert the coords to tblFaceImages then write the image to disk and/or insert the image to the db as a blob.
		#print x, y, w, h, scaleFactor, contextImageHeight, contextImg.shape[0]
		faceImageRowData = (int(sourceImagePK), int(float(x) * scaleFactor), int(float(y) * scaleFactor), int(float(w) * scaleFactor), int(float(h) * scaleFactor),scaled.tostring(), rep.tostring(), str(faceImageFilename))
		#print faceImageRowData[1], faceImageRowData[2], faceImageRowData[3], faceImageRowData[4]
		cursor.execute(addFaceImage, faceImageRowData)
		cx.commit()
		cursor.execute("update tblSourceImage set lastProcessedDate = current_timestamp where pk = {0};".format((int(sourceImagePK))))
		cx.commit()

	  #Save the context image for this source: (That is, a scaled-down version of the source image.)
	  contextImg = cv2.resize(contextImg,(int(float(contextImg.shape[1]) * (scaleFactor)),contextImageHeight),interpolation = cv2.INTER_CUBIC)
	  cv2.imwrite('contextImages/'+filenameBase+'.jpg',contextImg)
	  
	if showImagesDuringProcessing is True:
	  cv2.destroyAllWindows()
		
	#Close the connection to the database
	cursor.close()
	cx.close()


