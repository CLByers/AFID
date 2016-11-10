
var faceImage, contextImage, matchFrame, matchTable, faceBrowserDiv, subjectInfoBox, contextMap;
var photoBrowser, faceBrowser, matchBrowser, aboutBrowser;
var photoDivs = [];
var sourceData = [];

var contextImages = [];

var faceMatches = [];

var matchThreshold = 0.4;

function init() {
	document.getElementById('stats').innerText = statData[1] + ' faces identified from '+statData[0]+' photos. Last updated '+statData[3]+'.';
	faceImage = document.getElementById('faceImage');
	contextImage = document.getElementById('contextImage');
	contextMap = document.getElementById('contextMap');
	matchTable = document.getElementById('matchTable');
	matchFrame = document.getElementById('matchFrame');
	faceBrowserDiv = document.getElementById('faceBrowserDiv');
	subjectInfoBox = document.getElementById('subjectInfoBox');

	faceBrowser=document.getElementById('faceBrowser');
	photoBrowser=document.getElementById('photoBrowser');
	matchBrowser=document.getElementById('matchBrowser');
	aboutBrowser=document.getElementById('aboutBrowser');

	//randIndex = faceData[Math.floor(Math.random()*faceData.length)][0];
	//loadFaceContent(randIndex);
	//loadFaceContent(759);	
	//Put faces in the faceBrowser
	//faceBrowserDiv.innerHTML = "<p>All faces:</p>";
	//for (i = 0; i<faceData.length;i++) {
	//	faceBrowserDiv.innerHTML += "<a href='#' onClick='loadFaceContent("+faceData[i][0]+")'><img src='"+faceData[i][1]+"'></a>";
	//}

	//Find all of the source image PKs referenced in faceData
	//And flag images that do have likely matches in matchData
	for (i = 0;i<faceData.length;i++) {
		if(sourceData.indexOf(faceData[i][4]) == -1) {
			sourceData.push(faceData[i][4]);
		}
		
	}

	//Populate the photoBrowser element with all of the context images, image-mapped with their identified faces.
	for(i = 0; i < sourceData.length; i++) {	
		photoBrowser.innerHTML += imageDivForSourceImage(sourceData[i]);
	}
	//And make matchData symmetrical. (In its original state, it's just distinct pairs.)
	lenMatches = matchData.length;	
	for (i=0;i<lenMatches;i++){
		matchData.push([matchData[i][2],matchData[i][3],matchData[i][0],matchData[i][1],matchData[i][4]])
	}

	browsePhotos();
}

function browsePhotos() {
	photoBrowser.style.display="block";
	matchBrowser.style.display="none";
	faceBrowser.style.display="none";
	aboutBrowser.style.display="none";	
}

function browseID() {
	photoBrowser.style.display="none";
	matchBrowser.style.display="block";
	faceBrowser.style.display="none";	
	aboutBrowser.style.display="none";	
}

function browseFaces() {
	photoBrowser.style.display="none";
	matchBrowser.style.display="none";
	faceBrowser.style.display="block";	
	aboutBrowser.style.display="none";	
}

function browseAbout() {
	photoBrowser.style.display="none";
	matchBrowser.style.display="none";
	faceBrowser.style.display="none";	
	aboutBrowser.style.display="block";	
}

function loadFaceContent(facePK) {
	console.log('Loading content for face PK '+facePK);

	var sourceFK = faceData[indexForPK(facePK)][4];
	var mapString = "";
	//Source the images	
	faceImage.src=faceData[indexForPK(facePK)][1];
	//contextImage.src=faceData[indexForPK(facePK)][2];
	
	//Update the image map on contextImage
	contextImage.innerHTML = imageDivForSourceImage(sourceFK);	
	//contextMap.innerHTML = "";
	/*for (i=0; i < faceData.length; i++) {
		if (i != facePK && faceData[i][4]==sourceFK) {
			var x2 = Number(faceData[i][5])+Number(faceData[i][7]);
			var y2 = Number(faceData[i][6])+Number(faceData[i][8]);
			mapString = "<area shape='square' coords='"+faceData[i][5]+", "+faceData[i][6]+", "+x2+","+y2+"' href='#' onClick='loadFaceContent("+faceData[i][0]+");'>";
			console.log(mapString);
			contextMap.innerHTML += mapString;
		}
	}*/

	//Fill the info box
	subjectInfoBox.innerText="";
	if(faceData[indexForPK(facePK)][3] == "None") {
		//subjectInfoBox.innerText="Unidentified subject. Appears in unidentified photograph.";	
	} else {
		//subjectInfoBox.innerText="Unidentified subject. Appears in: "+faceData[indexForPK(facePK)][3];
	}

	//And populate the links to other faces
	var faceMatches = [];
	var likelies = 0;
	var imgClass = "";

	faceMatches = matchData.filter(matchFilter.bind(null,facePK));
	faceMatches = faceMatches.sort(distSort);
	console.log(faceMatches.length);
	if(faceMatches.length > 0) {	
		var likelies = 0;
		stillLoopingOverLikelies=true;
		matchFrame.innerHTML = "<p>Likely matches in other photographs:</p>";
		for (i = 0; i<faceMatches.length && i < 60;i++) {
			if(faceMatches[i][4] < matchThreshold) {
				likelies++;
			} else {
				imgClass = "unlikely";
				if (stillLoopingOverLikelies==true) { //If this is the switch from likely to unlikely matches
					stillLoopingOverLikelies=false;
					if(likelies==0) {
						matchFrame.innerHTML += "(None)";
					}
					faceBrowser.innerHTML = "";
				}
			}
			if (faceData[indexForPK(faceMatches[i][0])][9] != 'None') { imgClass = "likely"; } else { imgClass = "unlikely"; }
				
			if (stillLoopingOverLikelies==true) {
				//matchFrame.innerHTML += "<a href='#' onClick='loadFaceContent("+faceMatches[i][0]+")'><img class='"+imgClass+"' src='"+faceMatches[i][1]+"'></a>";
				matchFrame.innerHTML += "<a href='#' onClick='loadFaceContent("+faceMatches[i][0]+")'><img class='"+imgClass+"' src='"+faceMatches[i][1]+"'></a>";
			} else {
				if (faceData[indexForPK(faceMatches[i][0])][9] != 'None') { imgClass = "likely"; } else { imgClass = "unlikely"; }
				faceBrowser.innerHTML += "<a href='#' onClick='loadFaceContent("+faceMatches[i][0]+")'><img class='"+imgClass+"' src='"+faceMatches[i][1]+"'></a>";
			}
		}
		console.log('Best match is face index '+faceMatches[0][0]+" at distance "+faceMatches[0][4]);
		
	} else {
		//Zero entries in faceMatches. Shouldn't happen under the current design. Handle it anyway.
		matchFrame.innerHTML = "<p>Hm. Zero faces have match data for this key.</p><p>That's weird.</p>";
	}
	browseID();
}


function indexForPK(facePK) {
	var i;
	for(i=0;i<faceData.length;i++) {
		if (faceData[i][0]==facePK) {
			return i;
		}
	}
}

function imageDivForSourceImage(sourcePK) {
	var i = 0;
	var imageURL="";
	var sourceName="";
	var mapName = "contextMap"+sourcePK
	var linkClass;
	//var mapString = "<map name='"+mapName+"' id='"+mapName+"'>";	
	var mapString = "";	
	//Loop over faceImages for data
	for (i=0; i < faceData.length; i++) {
		if(faceData[i][4]==sourcePK) {
			if(faceData[i][9]!="None") {
				linkClass = 'likely';
			} else {
				linkClass = 'unlikely';
			}
			imageURL = faceData[i][2];
			sourceName = faceData[i][3];
			var x2 = Number(faceData[i][5])+Number(faceData[i][7]);
			var y2 = Number(faceData[i][6])+Number(faceData[i][8]);
			//mapString += "<area shape='square' coords='"+faceData[i][5]+", "+faceData[i][6]+", "+x2+","+y2+"' href='#' onClick='loadFaceContent("+faceData[i][0]+");'>";
			mapString += "<a href='#' onClick='loadFaceContent("+faceData[i][0]+");'><div class='"+linkClass+"' style='position: absolute; left:"+faceData[i][5]+"; top:"+faceData[i][6]+"; width:"+faceData[i][7]+"; height:"+faceData[i][8]+";'>&nbsp;</div></a>";
		}
	}
	if(sourceName == "None") {
		sourceName = "Unidentified photo";
	}
	imageString = "<img src='"+imageURL+"' height='400' class='photoBrowserImg' usemap=#"+mapName+"></img>";
	//mapString += "</map>";
	
	console.log(imageString+mapString);
	return("<div style='display:inline; float:left; position:relative; margin:5px; padding:0px;'>"+imageString+mapString+"<p>"+sourceName+"</p></div>"); 
}

function matchFilter(facePK, element) {
	return element[2]==facePK;
	//==facePK&&element[4] < matchThreshold;
}

function distSort(a,b) {
	//With matchData, this sorts in descending order of match strength.
	return a[4]>  b[4];
}

