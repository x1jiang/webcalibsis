<?php
if($_SERVER['REQUEST_METHOD']=='POST') {
  $status = apc_fetch('upload_'.$_POST['APC_UPLOAD_PROGRESS']);
  $status['done']=1;
  echo json_encode($status);
  exit;
} else if(isset($_GET['progress_key'])) {
  $status = apc_fetch('upload_'.$_GET['progress_key']);
  echo json_encode($status);
  exit;
}
?>
<html>
<head>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/yahoo.js"></script>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/event.js"></script>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/dom.js"></script>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/animation.js"></script>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/dragdrop.js"></script>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/connection.js"></script>
<script type="text/javascript" src="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/container.js"></script>
<link rel="stylesheet" type="text/css" href="http://scholar.privacy.cs.cmu.edu/auc_demo/yui/container.css" />
<script type="text/javascript">
var fN = function callBack(o) {
  var resp = eval('(' + o.responseText + ')');
  var rate = parseInt(resp['rate']/1024);
  if(resp['cancel_upload']) {
    txt="Cancelled after "+resp['current']+" bytes!"; 
  } else {
    txt=resp['total']+" bytes uploaded!";
  }
  txt += "<br>Upload rate was "+rate+" kbps.";
  document.getElementById('pbar').style.width = '100%';
  document.getElementById('ppct').innerHTML = "100%";
  document.getElementById('ptxt').innerHTML = txt;
  setTimeout("progress_win.hide(); window.location.reload(true);",2000);
}
var callback = { upload:fN }

var fP = function callBack(o) {
  var resp = eval('(' + o.responseText + ')');
  if(!resp['done']) { 
    if(resp['total']) {
      var pct = parseInt(100*(resp['current']/resp['total']));
      document.getElementById('pbar').style.width = ''+pct+'%';
      document.getElementById('ppct').innerHTML = " "+pct+"%";
      document.getElementById('ptxt').innerHTML = resp['current']+" of "+resp['total']+" bytes";
    }
    setTimeout("update_progress()",500);
  } else if(resp['cancel_upload']) {
    txt="Cancelled after "+resp['current']+" bytes!"; 
    document.getElementById('ptxt').innerHTML = txt;
    setTimeout("progress_win.hide(); window.location.reload(true);",2000);
  }
}
var progress_callback = { success:fP }

function update_progress() {
  progress_key = document.getElementById('progress_key').value;
  YAHOO.util.Connect.asyncRequest('GET','progress.php?progress_key='+progress_key, progress_callback);
}

var progress_win;

function postForm(target,formName) {
  YAHOO.util.Connect.setForm(formName,true);
  YAHOO.util.Connect.asyncRequest('POST',target,callback);
/* Is there some event that triggers on an aborted file upload? */
/*   YAHOO.util.Event.addListener(window, "abort", function () { alert('abort') } ); */
  progress_win = new YAHOO.widget.Panel("progress_win", { width:"420px", fixedcenter:false, underlay:"shadow", close:false, draggable:true, modal:true, effect:{effect:YAHOO.widget.ContainerEffect.FADE, duration:0.3} } );
  progress_win.setHeader("Uploading "+document.getElementById('test_file').value+" ...");
  progress_win.setBody('<div style="height: 1em; width: 400px; border:1px solid #000;"> <div id="pbar" style="background: #99e; height: 98%; width:0%; float:left;">&nbsp;</div> <div id="ppct" style="height: 90%; position: absolute; margin: 1 0 0 185;">0%</div></div><div id="ptxt" style="margin: 3 0 0 5">0 of 0 bytes</div>');
  progress_win.render(document.body);
  update_progress();
}
</script>
</head>
<body>
 <form enctype="multipart/form-data" id="upload_form" action="" onsubmit="postForm('progress.php','upload_form'); return true;" method="POST">
  <input type="hidden" name="APC_UPLOAD_PROGRESS" id="progress_key" value="<?php echo uniqid()?>"/>
  <input type="file" id="test_file" name="test_file"/><br/>
  <input type="submit" value="Upload!"/>
 </form>
 <div id="progress_win"> 
    <div class="hd" style="color: #222; background: #bbb"></div> 
    <div class="bd"></div> 
    <div class="ft"></div> 
 </div> 
</body>
</html>
