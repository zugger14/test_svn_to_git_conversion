<?php

	$file_names = $_POST['file_names'];
		
	$user_dir_destination = '../../../adiha.php.scripts/dev/shared_docs/certificate_keys';
	$user_dir_source = '../../../adiha.php.scripts/dev/shared_docs/temp_Note/certification_key';
	$files = scandir($user_dir_source);
	

	foreach ($files as $file) {
		if (in_array($file, $file_names)) {
			if (!file_exists($user_dir_destination)) {
				mkdir($user_dir_destination);
            }
            print_r($file, $user_dir_destination . '/' . $file);
			rename($user_dir_source . '/' . $file, $user_dir_destination . '/' . $file);
		}
	}
?>