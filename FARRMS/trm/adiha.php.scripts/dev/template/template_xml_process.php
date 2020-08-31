<?php
include "../../components/include.file.ini.php";
include "../../adiha.ini.php";
include "../../vbnet.recordset.ini.php";
include "../../genericFunctions.php";

$button_press = $_GET['button_press'];
$doc = new DomDocument('1.0');
$root = $doc->createElement('root');
$root = $doc->appendChild($root);
$occ = $doc->createElement("template");
$occ = $root->appendChild($occ);

/* 	
  foreach($_GET as $field_name=>$field_value){
  if($field_name!="session_id" || $field_name!="notesId" || $field_name!="fas_strategy"){
  $child = $doc->createElement($field_name);
  $child = $occ->appendChild($child);

  $value = $doc->createTextNode($field_value);
  $value = $child->appendChild($value);
  }
  }
  $xml_string = $doc->saveXML();
  $session_id=$_GET['session_id'];
  $ver=$_GET['template_ver'];

  $xml_file="../shared_docs/temp_Note/".$ver.".xml";
  $fp = @fo	pen($xml_file,'w');
  if(!$fp) {
  die('Error cannot create XML file');
  }
  fwrite($fp,$xml_string);
  fclose($fp);

  echo "Successfully Saved";

  $filepath=realpath($xml_file);
  $attachmentFileName=$filepath;
  $myOBJ = new COM($COM_ADIHA_PRCS_HTML);

  $myOBJ->setConnectionString($odbcUser, $odbcPass, $odbc_Server, $DB_Name);

  $attachmentChanged = 1;

  $notesId=$_GET['notesId'];
  $reporting_year=$_GET['reporting_year'];
  $fas_strategy=$_GET['fas_strategy'];
  $template_id=$_GET['template_id'];
  $template_name=$_GET['template_name'];

  $subject_id=$reporting_year."_".$fas_strategy ."_". $template_id;


  if($notesId==""){
  $type="Insert";
  }else{
  $type="Update";
  }

  $myOBJ->manageDocuments(3, $notesId, 5006, "0",$subject_id, $template_name, $attachmentChanged, $attachmentFileName,$attachmentFileName,"NULL", $type);
  // $myOBJ->manageDocuments($notesForObject, $notesId, $categoryValueId, $notesObjectId,$notesSubject, $notesText, $attachmentChanged, $attachmentFileName,$attachmentFileName, $sub_id, $Submit);

  $recordsetObject = new PSRecordSet(true);
  $xmldata=$recordsetObject->runCOMObject($myOBJ);
  $isSuccess=strstr($xmldata, 'Success');
  //echo $isSuccess;
 */

$template_doc = $_GET['template_doc'];
if ($button_press == "p") {
    $HTMLFileIn = $app_php_script_loc . "dev/template/" . $template_doc . "&session_id=$session_id&template_ver=1";

    $fileName = time();

    for ($i = 0; $i < 3; $i++) {
        $fileName .= chr(rand(65, 90));
    }

    header('Location: ' . $HTMLFileIn);

    die();
    //$DocFileOut = "../shared_docs/temp_Note/$fileName.doc";
	$DocFileOut = $temp_path . '\\' . $fileName . '.doc';

    $htmltodoc = new HTML_TO_DOC();
    $htmltodoc->createDocFromURL($HTMLFileIn, $DocFileOut);
    ?>

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
        <head>
            <title>Processing Document</title>
            <?php
            echo "<META HTTP-EQUIV='refresh' content='1; url=\"$DocFileOut\">'";
            ?>
        </head>
        <body> </body>
    </html>

<?php
} else {
?>
<script type="text/javascript">
      var myMessage = "Template Report Saved successfully";
      adiha_CreateMessageBox("alert", myMessage, '', '');
  </script>
<?php
}
?>
  