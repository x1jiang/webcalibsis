<?php
header('Expires: Tue, 08 Oct 1991 00:00:00 GMT');
header('Cache-Control: no-cache, must-revalidate');
 
if(isset($_GET['uid'])){
   $status = apc_fetch('upload_' . $_GET['uid']);
   echo round($status['current']/$status['total']*100);
}
?>