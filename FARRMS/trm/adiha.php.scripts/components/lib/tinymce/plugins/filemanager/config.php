<?php 
include '../../../../../../adiha.php.scripts/components/include.file.v3.php'; 

//add leading slash (/) if missing in $farrms_virtual_domain
stripos($farrms_virtual_domain, '/') > 1 ? ($farrms_virtual_domain = '/'.$farrms_virtual_domain) : $farrms_virtual_domain;

function get_root_path($root, $virtual_path) { // D:\\Farrms\\Release_Oct2018\\FARRMS\\
$virtual_path = rtrim($virtual_path,'/');
$root = str_replace("\\", '/', $root);
//$root = str_replace($virtual_path, '', $root);
$root = rtrim($root,'/');

return $root;
}

$root = get_root_path($farrms_root_dir, $farrms_virtual_domain); // don't touch this configuration

//**********************
//Path configuration
//**********************
// In this configuration the folder tree is
// root
//   |- tinymce
//   |    |- source <- upload folder
//   |    |- js
//   |    |   |- tinymce
//   |    |   |    |- plugins
//   |    |   |    |-   |- filemanager
//   |    |   |    |-   |-      |- thumbs <- folder of thumbs [must have the write permission]

$base_url=""; //url base of site if you want only relative url leave empty
$upload_dir = '/trm/adiha.php.scripts/dev/shared_docs/temp_Note/'; // path from base_url to upload base dir
$current_path = '../../../../../dev/shared_docs/temp_Note/'; // relative path from filemanager folder to upload files folder
$MaxSizeUpload=100; //Mb

//**********************
//Image config
//**********************
//set max width pixel or the max height pixel for all images
//If you set dimension limit, automatically the images that exceed this limit are convert to limit, instead
//if the images are lower the dimension is maintained
//if you don't have limit set both to 0
$image_max_width=0;
$image_max_height=0;

//Automatic resizing //
//If you set true $image_resizing the script convert all images uploaded in image_width x image_height resolution
//If you set width or height to 0 the script calcolate automatically the other size
$image_resizing=false;
$image_width=600;
$image_height=0;

//******************
//Permits config
//******************
$delete_file=true;
$create_folder=true;
$delete_folder=true;
$upload_files=true;


//**********************
//Allowed extensions
//**********************
$ext_img = array('jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff'); //Images
$ext_file = array('doc', 'docx', 'pdf', 'xls', 'xlsx', 'txt', 'csv','html','psd','sql','log','fla','xml','ade','adp','ppt','pptx'); //Files
$ext_video = array('mov', 'mpeg', 'mp4', 'avi', 'mpg','wma'); //Videos
$ext_music = array('mp3', 'm4a', 'ac3', 'aiff', 'mid'); //Music
$ext_misc = array('zip', 'rar','gzip'); //Archives


$ext=array_merge($ext_img, $ext_file, $ext_misc, $ext_video,$ext_music); //allowed extensions

?>
