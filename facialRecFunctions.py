import numpy as np
#import cv2
import os
#from os.path import isfile, join
import mysql.connector
import igraph



def populateComparisons():
  ##======================================
  ##This function populates tblComparison
  ##with distances between each pair
  ##of images in tblFaceImage
  ##======================================
  cx = mysql.connector.connect(user='root',password='Mtm9WAVkbM5w',host='127.0.0.1',database='AFID')
  cursor = cx.cursor()

  #Empty and re-populate tblComparison
  cursor.execute("truncate table tblComparison;")

  cursor.execute("insert tblComparison(faceImageFK1, faceImageFK2) select a.pk, b.pk from tblFaceImage a inner join tblFaceImage b on b.pk < a.pk;")
  cursor.execute("commit;")

  #representationData stores representation arrays in a byteArray form.
  #Get them into numpy ndarrays through reshape(str(rep)) (right?)

  #pull down each record in tblComparison and the
  #associated representationData from tblFaceImage.
  #Loop them into an array
  cursor.execute("call spFillTblComparison();")
  cursor.execute("select pk, faceImageFK1, faceImageFK2, rep1, rep2 from vwComparisonsNeedingDistance;")
  
  updateRows = cursor.rowcount
  updatedRows = 0
  print updateRows,"comparisons to be updated"
  updateSQL = "update tblComparison set distance = %s where pk = %s"

  comparisonReps = []

  for pk, fk1, fk2, rep1, rep2 in cursor:
    comparisonReps.append((pk, fk1, fk2, np.fromstring(str(rep1)), np.fromstring(str(rep2))))
  updatePairs = []
  for (pk, fk1, fk2, rep1, rep2) in comparisonReps:
    d = rep1 - rep2
    dist = np.dot(d, d)
    #print "Updating distance {0} for images {1} and {2}".format(dist, fk1, fk2)
    #cursor.execute(updateSQL, (float(dist), pk))
    updatePairs.append((float(dist), pk))
  cursor.executemany(updateSQL, updatePairs)
  cursor.execute('commit;')
  cursor.close()
  cx.close()

def makeWebData():
  ##And crank out the javascript data
  cx = mysql.connector.connect(user='root',password='Mtm9WAVkbM5w',host='127.0.0.1',database='AFID')
  cursor = cx.cursor()
  cursor.execute("select * from vwComparedFaceImages order by distance")
  page = open('AFIDData.js','w')

  addComma=False
  page.write("matchData=[")
  for PK1, url1, PK2, url2, distance in cursor:
    if addComma is True:
      page.write(",")
    page.write("[{0},'{1}',{2},'{3}',{4}]\n".format(PK1, url1, PK2, url2, distance))
    addComma = True
  page.write("];\n")
  addComma=False

  cursor.execute('select pk, imageURL, sourceImageURL, sourceTitle, sourceFK, boundingRectLeft, boundingRectTop, boundingRectWidth, boundingRectHeight, minDistance from vwFacesData')
  page.write("faceData=[")
  for pk, imageURL, sourceImageURL, sourceTitle, sourceFK, bboxLeft, bboxTop, bboxWidth, bboxHeight, minDist in cursor:
    if addComma is True:
      page.write(",")
    page.write("[{0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}']\n".format(pk, imageURL, 'contextImages/'+sourceImageURL.split('.')[0]+'_context.jpg', sourceTitle, sourceFK, bboxLeft, bboxTop, bboxWidth, bboxHeight, minDist))
    addComma = True
  page.write("];\n")
  addComma=False
  
  cursor.execute("select count(*) from tblSourceImage\
                 union select count(*) from tblFaceImage\
                 union select count(*) from tblComparison\
                 union select DATE_FORMAT(max(lastProcessedDate),'%b %d %Y') from tblSourceImage;")
  page.write("statData=[")
  for datum in cursor:
    if addComma is True:
      page.write(",")
    page.write("'{0}'".format(datum[0]))
    addComma = True
  page.write("];\n")


  page.close()
  cursor.close()
  cx.close()


def makeNetworkGraph():
  cx = mysql.connector.connect(user='root',password='Mtm9WAVkbM5w',host='127.0.0.1',database='AFID')
  cursor = cx.cursor()
  cursor.execute("select * from vwSourceNetworkData")
  networkGraph = igraph.Graph()
  
  sourceIndices = {} #This is just to track whether vertices have been added to the graph
  
  for PK1, PK2, nConnections in cursor:
    PK1 = "v"+str(PK1)
    PK2 = "v"+str(PK2)
    if not sourceIndices.has_key(PK1):
      networkGraph.add_vertex(PK1)
      sourceIndices[PK1] = 1
    if not sourceIndices.has_key(PK2):
      networkGraph.add_vertex(PK2)
      sourceIndices[PK2] = 1
    if PK1 != PK2:
      for n in range(nConnections):
        networkGraph.add_edge(PK1, PK2)
      
  layout = networkGraph.layout_auto()
  igraph.plot(networkGraph, layout=layout)
  cursor.close()
  cx.close()
