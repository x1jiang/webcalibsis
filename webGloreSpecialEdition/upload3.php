<?php
if ((($_FILES["predictionFile"]["type"] == "text/plain"))
&& ($_FILES["predictionFile"]["size"] < 900000)
&& (($_FILES["modelFile"]["type"] == "text/plain"))
&& ($_FILES["modelFile"]["size"] < 900000))
  {
  if (($_FILES["predictionFile"]["error"] > 0))
    {
    echo "Return Code: " . $_FILES["predictionFile"]["error"] . "<br />";
    }
  elseif (($_FILES["modelFile"]["error"] > 0))
    {
    echo "Return Code: " . $_FILES["modelFile"]["error"] . "<br />";
    }  
  else
    {
    echo "Upload predictionFile: " . $_FILES["predictionFile"]["name"] . "<br />";
    echo "PredictionFile Type: " . $_FILES["predictionFile"]["type"] . "<br />";
    echo "PredictionFile Size: " . ($_FILES["predictionFile"]["size"] / 1024) . " Kb<br />";
    echo "Temp PredictionFile file: " . $_FILES["predictionFile"]["tmp_name"] . "<br />";
	 
	echo "Upload modelFile: " . $_FILES["modelFile"]["name"] . "<br />";
    echo "ModelFile Type: " . $_FILES["modelFile"]["type"] . "<br />";
    echo "ModelFile Size: " . ($_FILES["modelFile"]["size"] / 1024) . " Kb<br />";
    echo "Temp modelFile file: " . $_FILES["modelFile"]["tmp_name"] . "<br />";
	  
	  if($_GET['taskName'] != null)
	  {
			$ip = $_GET['taskName'];
			$ip=md5($ip);
	  }
	  else{
		$ip=$_SERVER['REMOTE_ADDR'];
		$ip=md5($ip);
	  }
	  echo "<b>IP Address= $ip</b>";
	  $cdir = getcwd();
	  chmod  (  $cdir  ,  0777  )	;
	  mkdir("$ip", 0777);
			
    if (file_exists("$ip/" . $_FILES["predictionFile"]["name"]))
      {
		echo $_FILES["predictionFile"]["name"] . " already exists. ";
      }
	elseif (file_exists("$ip/" . $_FILES["modelFile"]["name"]))
      {
		echo $_FILES["modelFile"]["name"] . " already exists. ";
      }	  
	 elseif (file_exists("$ip/index.html"))
	 {
		echo "<b>report exists</b>";
		header("Location: http://dbmi-engine.ucsd.edu/webcalibsis/"."$ip"."/index.html");
	 }
    else
      {      
      $cdir = getcwd();
      $inputDir  = $cdir;	
      chmod  (  $inputDir."\\$ip"  ,  0777  )	;
      $floc1 = "$ip\\" . $_FILES["predictionFile"]["name"];
      echo $floc1;
	  
	  $floc2 = "$ip\\" . $_FILES["modelFile"]["name"];
      echo $floc2;
	  
      move_uploaded_file($_FILES["predictionFile"]["tmp_name"],
      "$ip\\" . $_FILES["predictionFile"]["name"]);
      echo "-- stored in: " . "$ip/" . $_FILES["predictionFile"]["name"];
	  
	  move_uploaded_file($_FILES["modelFile"]["tmp_name"],
      "$ip\\" . $_FILES["modelFile"]["name"]);
      echo "-- stored in: " . "$ip/" . $_FILES["modelFile"]["name"];
  	    
	    $predictionFilename = $cdir."\\$floc1";
		$modelFilename = $cdir."\\$floc2";
		//$command = "matlab -sd ".$inputDir." -nodisplay -nosplash -nodesktop -r graphicalreport2("."'$predictionFilename'".",'$modelFilename'".",'$ip'". ")";
		$command= $cdir."\\webcalib2.exe"." $predictionFilename"." $modelFilename"." $ip";
	    // Output a 'waiting message'
		echo '<br/> Please wait 30 seconds while the function is being processed <br/>';
//		pclose(popen("start /B cmd /C ". $command ." >NUL 2>NUL", 'r'));
		
		set_time_limit(0);
		$timeout = 30; // sec
		$output = $inputDir. "\\$ip\\image\\rocplot.png";
		echo "Image file to be checked is: "."$output"."<br/>";	
		
		$start = time();
		try {
			if (! @unlink($output) && is_file($output))
				throw new Exception("Unable to remove old file");

			exec($command);
			
			while ( true ) {
				// Check if file is readable
				if (is_file($output) && is_readable($output)) {
					$img = @imagecreatefrompng($output);
					// Check if Math Lab is has finished writing to image
					if ($img !== false) {
						//header('Content-type:image/png');
						//imagepng($img);
						echo "Image is ready... "."<br/>";	
						break;
					}
				}
				// Check Timeout
				if ((time() - $start) > $timeout) {					
					throw new Exception("Timeout Reached");
					break;
				}
			}
		} catch ( Exception $e ) {
			echo $e->getMessage();
		}
		sleep(2);
		echo "The following command was run: ".$command."<br/>";
//	    echo $filename." was created in ".$outputDir."<br/>";
	    echo "wait, we will jump in a second...<br/>";		
	 	echo "total time is: ". (time() - $start);
	    header("Location: http://dbmi-engine.ucsd.edu/webcalibsis/"."$ip"."/index.html");
	    unlink($floc1);
		unlink($floc2);
    }     
  	
    }
  }
else
  {
  echo "Invalid file";
  }
?>