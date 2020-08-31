<?php
/**
 * @author Achyut Khadka
 * @copyright 2017 Achyut Khadka <achyut@pioneersolutionsglobal.com>
 *
 * @example
 *		// set configuration settings
 *		autoloader(array(array(
 *			'debug' => true, // set debug mode on/off
 *			'basepath' => '/var/www/myproject', // set project base path
 *			'extensions' => array('.php'), // set allowed class extension(s) to load
 *			// 'extensions' => array('.php', '.php4', '.php5'), // example of multiple extensions
 *		)));
 *
 *		// add class paths to autoload
 *		autoloader(array(
 *			'lib', // really '/var/www/myproject/lib' when using basepath in config settings
 *			'models/data' // really '/var/www/myproject/models/data' when using basepath in config settings
 *		));
 *
 *		// get array registered class paths (when in debug mode any autoloaded classes will show up as 'loaded')
 *		$registered_class_paths = autoloader();
 */

/**
 * Autoloader
 *
 * @staticvar boolean $is_init
 * @staticvar array $conf
 * @staticvar array $paths
 * @param array|string|NULL $class_paths
 *		when loading class paths ex: array('path/one', 'path/two')
 *		when loading class ex: 'myclass'
 *		when returning cached paths: NULL
 * @param boolean $use_base_dir (when true will prepend class path with base directory)
 * @return array|boolean
 *		(default boolean if class paths registered/loaded, or when debugging
 *			(or NULL passed as $class_paths) array of registered class paths
 *			(and loaded class files, configuration settings) returned)
 */
function autoloader($class_paths = NULL, $use_base_dir = true) {
	static $is_init = false;

	static $conf = array(
		'basepath' => '',
		'debug' => false,
		'extensions' => array('.php') // multiple extensions ex: array('.php', '.class.php')
	);

	static $paths = array();

	if(is_null($class_paths)) { // autoloader(); returns paths (for debugging)
		return $paths;
	}

	if(is_array($class_paths) && isset($class_paths[0]) && is_array($class_paths[0])) { // conf settings
		foreach($class_paths[0] as $k => $v) {
			if(isset($conf[$k]) || array_key_exists($k, $conf)) {
				$conf[$k] = $v; // set conf setting
			}
		}

		return true; // conf set
	}

	if(!$is_init) { // init autoloader
		spl_autoload_extensions(implode(',', $conf['extensions']));
		spl_autoload_register(NULL, false); // flush existing autoloads
		$is_init = true;
	}

	if($conf['debug']) {
		$paths['conf'] = $conf; // add conf for debugging
	}

	if(!is_array($class_paths)) { // autoload class
		// class with namespaces, ex: 'MyPack\MyClass' => 'MyPack/MyClass' (directories)
		$class_path = str_replace('\\', DIRECTORY_SEPARATOR, $class_paths);
		
		foreach($paths as $path) {
			if(!is_array($path)) { // do not allow cached 'loaded' paths
				foreach($conf['extensions'] as &$ext) {
					$ext = trim($ext);
					if(file_exists($path . $class_path . $ext)) {
						if($conf['debug']) {
							if(!isset($paths['loaded'])) {
								$paths['loaded'] = array();
							}
							$paths['loaded'][] = $path . $class_path . $ext;
						}
						require $path . $class_path . $ext;
						return true;
					}
				}
			}
		}

		return false; // failed to autoload class
	} else { // register class path
		$is_registered = false;
		$is_unregistered = false;

		foreach($class_paths as $path) {
			$tmp_path = ( $use_base_dir ? rtrim($conf['basepath'], DIRECTORY_SEPARATOR)
				. DIRECTORY_SEPARATOR : '' ) . trim(rtrim($path, DIRECTORY_SEPARATOR))
				. DIRECTORY_SEPARATOR;

			if(!in_array($tmp_path, $paths)) {
				$paths[] = $tmp_path;
			}

			$is_registered = spl_autoload_register('autoloader', (bool)$conf['debug']);

			unset($tmp_path);

			if(!$is_registered) {
				$is_unregistered = true; // flag unable to register
			}
		}
		
		return !$conf['debug'] ? !$is_unregistered : $paths;
	}
}