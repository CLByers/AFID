<?php

	$subjectInfo = "Unknown image";
	$matchThreshold = 0.4;

	$sourcesPage = 1;
	$facesPage = 1;
	$matchNum = 0;
	$queryCount = 0;
	$matchFaceImageURL = "";
	$matchSourceImageWidth = 0;
	$imagesPerPage = 20;
	$facesPerPage = 50;

	if(is_numeric($_GET["sourcesPage"])) {
		$sourcesPage = $_GET["sourcesPage"];
	}
	if(is_numeric($_GET["facesPage"])) {
		$facesPage = $_GET["facesPage"];
	}
	if (is_numeric($_GET["matchImage"])) {
		$matchNum = $_GET["matchImage"];
	}
	$linkAction = $_GET["linkAct"];
	
	$sectionVisibility = array("none","none","block");
	if($linkAction == "sourcesPage") {
		$sectionVisibility = array("none","block","none");
	} else if ($linkAction == "facesPage") {
		$sectionVisibility = array("block","none","none");
	}

	$db = new PDO('mysql:host=localhost;dbname=AFID;charset=utf8mb4', 'AfidUser', 'AfidUserPassword');
	$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	#echo 'just tried to create a connection...';		

	$queryString = 'select count(*) as ct from tblSourceImage union select count(*) from tblFaceImage;';
	logQuery($queryString);
	$stmt = $db->query($queryString);
	try {		
		$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
	} catch(PDOException $ex) {
		echo "PDO FAIL!";
		echo($ex->getMessage());
	}

	$totalSources = $results[0]['ct'];
	$totalFaces = $results[1]['ct'];

	$statsString = $totalFaces." faces identified from ".$totalSources." source images.";
	$totalSources = $results[0]['ct'];
	$maxSourcesPage = $totalSources / $imagesPerPage;
	$maxFacesPage = $totalFaces / $facesPerPage;
	
	
	if ($sourcesPage > 1) {
		$sourcePagerString = $sourcePagerString . " <a href=\"".getLinkWithParam("sourcesPage",$sourcesPage - 1)."\">&lt;</a>";
	}
	$sourcePagerString = $sourcePagerString . "Page ".$sourcesPage." of ".ceil($maxSourcesPage);
	if ($sourcesPage < $maxSourcesPage) {
		$sourcePagerString = $sourcePagerString . " <a href=\"".getLinkWithParam("sourcesPage",$sourcesPage + 1)."\">&gt;</a>";
	}
	
	if ($facesPage > 1) {
		$facePagerString = $facePagerString . " <a href=\"".getLinkWithParam("facesPage",$facesPage - 1)."\">&lt;</a>";
	}
	$facePagerString = $facePagerString . "Page ".$facesPage." of ".ceil($maxFacesPage);
	if ($facesPage < $maxFacesPage) {
		$facePagerString = $facePagerString . " <a href=\"".getLinkWithParam("facesPage",$facesPage + 1)."\">&gt;</a>";
	}
	
	
	$sourceBrowserString = prepDatabaseContent(($sourcesPage-1)*$imagesPerPage,$imagesPerPage);

	$faceBrowserString = drawFaceImageGrid(($facesPage-1)*$facesPerPage,$facesPerPage);

	#drawSourceImageForMatch($matchNum); #populates $sourceImageString and $faceImageString

	#$sourceImageString = drawSourceImageForMatch($matchNum);
	#$faceImageString = drawFaceImage($matchNum,$matchFaceImageURL);
	$matchContentString = getMatchContent($matchNum);

	#echo $queryCount." queries total.";

	
	
	

	function prepDatabaseContent($start, $limit)
	{
		global $db, $matchNum,$faceImageString,$sourceImageString;
		$queryString = 'select vfd.*, pks.selectContext
			from (
				select sourceImageFK pk, "match" selectContext from tblFaceImage where pk = '.$matchNum.'
				union all select pk, selectContext from (
					select pk, "normal" selectContext from  tblSourceImage limit '.$start.','.$limit.'
				)pks_inner
			) pks
			left join tblFacesData vfd
			on vfd.sourceFK = pks.pk;';
		logQuery($queryString);		
		$stmt = $db->query($queryString);
		try {		
			$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
		} catch(PDOException $ex) {
			echo "PDO FAIL!";
			echo($ex->getMessage());
		}

		#get all of the source Images in the result into one place
		foreach($results as $row) {
			if($row['pk'] == $matchNum && $row['selectContext'] == "match") { 
				$matchFaceImageURL = $row['imageURL'];
				$sourceImagePK = $row['sourceFK'];
			}
			$sourcesData[$row['sourceFK']] = array('selectContext'=>$row['selectContext'],'sourceFK'=>$row['sourceFK'],'title'=>$row['sourceTitle'],'URL'=>$row['sourceImageURL']);
		}

		foreach($sourcesData as $key=>$row) {
			$currentSourceData = array_filter($results, function($var) use($key){return($var['sourceFK'] == $key);});
			#if($row['selectContext'] == "match") {
			if($sourcesData[$key]['sourceFK'] == $sourceImagePK) {
				$sourceImageString = drawSourceImageFromRowset($currentSourceData,true);
			} else {
				$divBoxString = $divBoxString . drawSourceImageFromRowset($currentSourceData);
			}
		}
		$faceImageString = drawFaceImage($matchNum,$matchFaceImageURL,"mainFaceImage");
		return $divBoxString;
	}

	function drawFaceImageGrid($start, $limit)
	{
		global $db;	
		$queryString = 'SELECT * FROM tblFaceImage limit '.$start.','.$limit.';';
		logQuery($queryString);
		$stmt = $db->query($queryString);
		try {		
			$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
		} catch(PDOException $exc) {
			echo "PDO FAIL!";
			echo($exc->getMessage());
		}
		$divBoxString = "";
		foreach($results as $row) {
			$divBoxString = $divBoxString . drawFaceImage($row['pk'], $row['imageURL']);
		}
		return $divBoxString;
	}

	function logQuery($string){
		global $queryCount;
		#echo $string."<br>";
		$queryCount = $queryCount + 1;
		
	}

	function drawSourceImageFromRowset($rowset, $isMatchSource = false) {
		global $matchThreshold,$matchNum;
		$divBoxString = "";
		$mainImageURL = "";
		#$linkClass = "likely";
		foreach($rowset as $row) {
			if($row['pk']==$matchNum && $isMatchSource == true) {
				$linkClass = "highlight";
				$calloutBoxWidth = $row['boundingRectLeft'] + 1;
				$calloutBoxLeft = -6;
				$calloutBoxHeight = $row['boundingRectTop'] + $row['boundingRectHeight'] / 2;
				$calloutBoxTop = 0;
				$divBoxString = $divBoxString . "<div class='callout' style='position: absolute; left:".$calloutBoxLeft."; top:".$calloutBoxTop."; width:".($calloutBoxWidth+10)."; height:".$calloutBoxHeight.";'>&nbsp;</div>";
			} else if ($row['minDistance'] <= $matchThreshold) {
				$linkClass = "likely";
			} else {
				$linkClass = "unlikely";
			}
			$divBoxString = $divBoxString . "<a href=\"".getLinkWithparam("matchImage",$row['pk'])."\"><div class='".$linkClass."' style='position: absolute; left:".($row['boundingRectLeft']+5)."; top:".$row['boundingRectTop']."; width:".$row['boundingRectWidth']."; height:".$row['boundingRectHeight'].";'>&nbsp;</div></a>";
			if ($isMatchSource == true) {
				$sourceDir = "sourceImages";
			} else {
				$sourceDir = "contextImages";
			}
			$imageString = "<img src='".$sourceDir."/".$row['sourceImageURL']."' height='400' class='photoBrowserImg'></img>";
				#echo $row['imageURL'].' '.$row['sourceImageURL'].' '.$row['boundingRectLeft'].' '.$row['boundingRectTop'].' '.$row['boundingRectWidth'].' '.$row['boundingRectHeight'].'<br>';
				#echo "<img src='".$row['imageURL']."' height='192' class='photoBrowserImg'></img>";
		}
		
		return("<div style='display:inline; float:left; position:relative; margin:5px; padding:0px;'>".$imageString.$divBoxString."<p>".$row['sourceTitle']." <a href=\"sourceImages/".$row['sourceImageURL']."\" target=\"_New\">[Full size]</a> <a href=\"#\">[Source]</a></p></div>");

	}

	function drawFaceImage($PK, $imageURL,$imageClass = "") {
		return("<a href=\"".getLinkWithParam("matchImage",$PK)."\"><img id=\"faceImage\" height=\"192\" width=\"192\" style=\"height: 192px; width:192px; vertical-align:text-top;\" src=\"".$imageURL."\" class=\"".$imageClass."\"></a>");

	}

	function getLinkWithParam($paramName,$value){
		global $matchNum, $facesPage, $sourcesPage;
		$params = array("matchImage"=>$matchNum,"facesPage"=>$facesPage,"sourcesPage"=>$sourcesPage,"linkAct"=>$paramName);
		$params[$paramName]=$value;
		return "index.php?matchImage=".$params["matchImage"]."&sourcesPage=".$params["sourcesPage"]."&facesPage=".$params["facesPage"]."&linkAct=".$params["linkAct"];
	}	

	function getMatchContent($PK) {
		global $db,$matchThreshold;
		#vwComparedFaces only has rows where pk1 < pk2, so double them up here.
		$queryString = 'select pk2 pk, url2 url, distance from vwComparedFaceImages
			where PK1 = '.$PK.'
			and distance < '.$matchThreshold.'
			union select pk1, url1, distance from vwComparedFaceImages
			where PK2 = '.$PK.'
			and distance < '.$matchThreshold.'
			order by distance;';
		//logQuery($queryString);
		$stmt = $db->query($queryString);
		$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
		//echo $stmt->rowCount()." rows";
		$divBoxString = "";
		foreach($results as $row) {
		
		#$divBoxString = $divBoxString . "<a href=\"index.php?matchImage=".$row['pk']."\"><img id=\"faceImage\" height=\"192\" width=\"192\" style=\"height: 192px; width:192px; vertical-align:text-top;\" src=\"".$row['url']."\"></a>";
		$divBoxString = $divBoxString . "<a href=\"".getLinkWithParam("matchImage",$row['pk'])."\"><img id=\"faceImage\" height=\"192\" width=\"192\" style=\"height: 192px; width:192px; vertical-align:text-top;\" src=\"".$row['url']."\"></a>";

		$imageString = "<img src='sourceImages/".$row['sourceImageURL']."' height='400' class='photoBrowserImg'></img>";
			#echo $row['imageURL'].' '.$row['sourceImageURL'].' '.$row['boundingRectLeft'].' '.$row['boundingRectTop'].' '.$row['boundingRectWidth'].' '.$row['boundingRectHeight'].'<br>';
			#echo "<img src='".$row['imageURL']."' height='192' class='photoBrowserImg'></img>";
		}
		
		return($divBoxString);

	}
	
	

?>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1"> 
		<title>AFID Gallery</title>
		<script language="javascript" src="AFIDFunctions.js"></script>
		<link rel="stylesheet" type="text/css" href="AFIDStyle.css"></link> 

		
	</head>	
	<body onLoad="init();">
	
<?php
		echo "<script type=\"text/javascript\">".$initScript."</script>";
	?>
		<div class="headerBar">
			<span class="stats" id="stats"><?php echo $statsString; ?></span>			
			<!--<h2>A.F.I.D. Gallery</h2>-->
			<h4>Archival Facial Identification Database</h4>
<h4><a class="header" href="#" onClick="browseFaces()">Browse by face</a> | <a class="header" href="#" onClick="browsePhotos()">Browse by photo</a> | <a class="header" href="#" onClick="browseID()">Browse by matches</a> | <a class="header" style="background:white;color:black;" href="#" onClick="browseAbout()">About AFID</a></h4>
		</div>
		
		
		<div class="threeup" id="matchBrowser" style="display:<?=$sectionVisibility[2]?>;">
			
			<div class="inlineContent" style="vertical-align=top; height:400px;">
				
				<?php echo $faceImageString; ?>	
				<div id="contextImage" style="height:400; width:auto; vertical-align:text-top; display:inline;">
				<?php echo $sourceImageString; ?>
				</div>
						<div class="matchFrame" id="matchFrame">
				
				Best matches in other images:<br>
				<?php echo $matchContentString; ?>
			</div>	
				
			
			<!--<span class="inlineContent" style="height:200px; width:auto;" id="subjectInfoBox">
			</span>-->
			
			</div>
			
		</div>
		

<div class="threeup" id="faceBrowser" style="display:<?=$sectionVisibility[0]?>;">
	<?php
		echo $facePagerString;
		echo "<br>";
		echo $faceBrowserString;
		echo "<br>";
		echo $facePagerString;
	?>
</div>
<div class="threeup" id="photoBrowser" style="display:<?=$sectionVisibility[1]?>;">
	<?php
		echo $sourcePagerString;
		echo "<br>";
		echo $sourceBrowserString;
		echo "<br>";
		echo "<div style='display:block; clear:both;'>".$sourcePagerString."</div>";
	?>
</div>
		<div class="threeup" id="aboutBrowser" style="display:none; background-image:url('network2.png');"><p>AFID is a project to bring face recognition to archival photo collections. The technology has grown by leaps and bounds to meet the parameters of social media and a few other applications, but I believe it can also reveal important historical data, too. There are deep layers of associative meaning in photo collections, I believe we can make those associations visible to researchers.
<!--<img src="network.png">-->
<p>The project is built on the <a href="https://cmusatyalab.github.io/openface/" target="_New">Openface</a> project, which uses OpenCV2, Torch, and DLib (among other great open-source software) to detect and classify faces through deep neural networks.
<p>Check out the GIT repository at <a href="https://github.com/CLByers/AFID" target="_New">https://github.com/CLByers/AFID</a>
<p>Thanks to the <a href="http://digitalarchives.wa.gov/" target="_New">Washington State Digital Archives</a> and the A.M. Kendrick photo collection for photos.
<p>I'm Charlie Byers, an M.A. student in Eastern Washington University's history program. Email me at CLByers at gmail dot com with questions, concerns, panels at SAA 2017, etc.
</div>
		
		
<div class="faceBrowser" id="faceBrowserDiv">
		</div>
	</body>
</html>
