<?php
if ((($_FILES["file"]["type"] == "text/plain"))
&& ($_FILES["file"]["size"] < 900000))
  {
  if ($_FILES["file"]["error"] > 0)
    {
    echo "Return Code: " . $_FILES["file"]["error"] . "<br>";
    }
  else
    {
    echo "Upload: " . $_FILES["file"]["name"] . "<br>";
    echo "Type: " . $_FILES["file"]["type"] . "<br>";
    echo "Size: " . ($_FILES["file"]["size"] / 1024) . " Kb<br>";
    echo "Temp file: " . $_FILES["file"]["tmp_name"] . "<br>";
	  $ip=$_SERVER['REMOTE_ADDR'];
	  $ip=md5($ip);
	  echo "<b>IP Address= $ip</b>";
	  $cdir = getcwd();
	  chmod  (  $cdir  ,  0777  )	;
		mkdir("$ip", 0777);
			
    if (file_exists("$ip/" . $_FILES["file"]["name"]))
      {
      echo $_FILES["file"]["name"] . " already exists. ";
      }
    else
      {
      $cdir = getcwd();
      $inputDir  = $cdir;	
      chmod  (  $inputDir."\\$ip"  ,  0777  )	;
      $floc = "$ip\\" . $_FILES["file"]["name"];
      echo $floc . "<br>";
      move_uploaded_file($_FILES["file"]["tmp_name"], "$ip\\" . $_FILES["file"]["name"]);
      echo "Stored in: " . "$ip/" . $_FILES["file"]["name"] ."<br>";
  	    
	    $filename = $cdir."\\$floc";
//	    $outputDir = $cdir."\\html\\";
	    $command = "matlab -sd ".$inputDir." -r graphicalreport("."'$filename'".",'$ip'". ")";
	    // Output a 'waiting message'
		echo 'Please wait 30 seconds while the function is being processed<br>';
	    // exec($command);
	    // echo "The following command was run: ".$command."<br>";
	    // echo $filename." was created in ".$filename."<br>";
	    // echo "Wait, we will jump in 5 seconds.....<br>";
		// sleep(40);			 	 	
		
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
					// Check if MatLab is has finished writing to image
					if ($img !== false) {
						//header('Content-type:image/png');
						//imagepng($img);
						echo "Image is ready... "."<br>";	
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
		
		echo "http://localhost:8080/webcalibsis2/"."$ip"."/index.html<br>";
	    header("Location: http://localhost:8080/webcalibsis2/"."$ip"."/index.html");
	    unlink($floc);		  
    } 
	     
  	
    }
  }
else
  {
  echo "Invalid file";
  }
?>