This is a project to apply facial recognition, via OpenFace, to archival photo collections. In this version, you can process images on any machine, update the web content, and deploy it to any site--there's no live connection between the web content and the database.

There is a working installation at charliebyers.org/AFID/index.html

I've only seen openface build successfully under Linux (Torch seems to be the squeaky wheel,) but the rest is just Python, so if you'd like to try it on Windows/OSX, go for it.


To install:
1) Install Python 2.7
2) Install MySQL and the MySQL Connector python library. (Both get-able through apt.)
3) Build the full openface distribution according to their instructions at https://github.com/cmusatyalab/openface (This hasn't been tested with the Docker install, but there's no reason it shouldn't work.)
4) Pull down the zip for this project and extract it somewhere convenient.
5) Run the mysqldump files to create the database. (This will take some manual executing--mysqldump is shy about views, for some reason.)
6) Configure a MySQL user/password for the AFID database, and update that information in getFaceImages.py and facialRecFunctions.py.

Use:
1) Add source images to tblSourceImage, then run getFaceImages.py to process and compare faces.
2) Open index.html in any browser to view the processed image content

Questions? Post issues here on GitHub, or email CLByers@gmail.com
Thanks,
Charlie Byers
11/9/16
