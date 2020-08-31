<?php
/* Modified Date : 12/05/2019 */

include '../components/include.file.v3.php';
global $temp_path, $TEMP_FILE_RETENTION_DAYS;

# Here if value of $TEMP_FILE_RETENTION_DAYS is 7 then 7 days = 7 * 24 * 60 * 60 in seconds.
$max_life_time = $TEMP_FILE_RETENTION_DAYS * 24 * 60 * 60;

# Prepare an array of directories to clean. Only include path from temp_Note.
$paths_to_clean = array (
    $temp_path
);

# Prepare an array of directories to exclude. Paths should begin from folder temp_Note. Example: "\\temp_Note\\folder\\sub-folder\\sub-folder2\\" in case sub-folder2 should be excluded and all siblings of sub-folder2 should be deleted.
$exclude_paths = array(
    "\\temp_Note\\EDI\\"
);

foreach ($paths_to_clean as $item_to_clean) {
    clean_directory($item_to_clean, $exclude_paths, $max_life_time);
}

/**
 * Deletes all files from a directory.
 * @param  String  $dir            Physical path of the directory
 * @param  Array   $exclude_paths  Array of physical file paths to exclude
 * @param  Integer $max_life_time  Maximum time until which the file will not be deleted in secs
 */
function clean_directory($dir, $exclude_paths, $max_life_time) {
    global $temp_path;

    if (is_dir($dir)) {
        $objects = scandir($dir);
        foreach ($objects as $object) {
            if ($object != "." && $object != "..") {
                if (filetype($dir . "/" . $object) == "dir") {
                    clean_directory($dir . "/" . $object, $exclude_paths, $max_life_time);
                } else if (filetype($dir . "/" . $object) == "file" && (time() - filectime($dir . "/" . $object)) > $max_life_time) {
                    try {
                        $delete_file = true;
                        foreach ($exclude_paths as $exclude_path) {
                            if (strpos(str_replace("/", "\\", $dir . "\\" . $object), $exclude_path) > -1) {
                                $delete_file = false;
                            }
                        }
                        if ($delete_file) {
                            // echo "Delete file: " . $object;
                            // echo "<br/>";
                            unlink ($dir."/".$object);
                        }
                    } catch (exception $e) {
                        // continue deleting other items in case of any error with any item.
                        ;
                    }
                }
            }
        }
        reset($objects);
        //rmdir($dir); // This tries to delete tempNote folder as well.
        remove_empty_sub_folders($dir, $exclude_paths, $max_life_time, $temp_path);
    }
}

/**
 * Removes empty sub-folders from a directory.
 * @param  String  $path          Physical path of the directory
 * @param  Array   $exclude_paths Array of physical file paths to exclude
 * @param  Integer $max_life_time Maximum time until which the file will not be deleted in secs
 * @param  String  $temp_path     Physical path of temp_Note folder
 */
function remove_empty_sub_folders($path, $exclude_paths, $max_life_time, $temp_path) {
    $empty = true;
    foreach (glob($path . DIRECTORY_SEPARATOR . "*") as $file) {
        if (is_dir($file)) {
            if (!remove_empty_sub_folders($file, $exclude_paths, $max_life_time, $temp_path)) {
                $empty=false;
            }
        } else {
            $empty=false;
        }
    }
    $path = str_replace("/", "\\", $path);
    
    if ($empty && (time() - filectime($path)) > $max_life_time) {
        $delete_folder = true;
        foreach ($exclude_paths as $exclude_path) {
            if (strpos(str_replace("\\\\", "\\", $path . "\\"), $exclude_path) > -1) {
                $delete_folder = false;
            }
        }
        if ($delete_folder && str_replace("\\\\", "\\", $temp_path . "\\") !== str_replace("\\\\", "\\", $path . "\\") && is_dir_empty($path)) {
            // echo "Delete folder: " . str_replace("\\\\", "\\", $path . "\\");
            // echo "<br/>";
            rmdir($path);
        }
    }
    return $empty;
}

/**
 * Check if directory is empty.
 * @param  String  $dir Physical path of the directory
 * @return Boolean
 */
function is_dir_empty($dir) {
    $handle = opendir($dir);
    while (false !== ($entry = readdir($handle))) {
        if ($entry != "." && $entry != "..") {
            closedir($handle);
            return false;
        }
    }
    closedir($handle);
    return true;
}

?>