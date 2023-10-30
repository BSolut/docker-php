<?php
$apc_avail = function_exists('apcu_store');

if (!$apc_avail) {
	echo 'function missing; in memory caching is not available, this will cause lots of problems'."\r\n";
	exit(1);
}

$cache_enabled = true;
$random = md5(time());
$ckey = 'r_test';
$timeout = 30;
apcu_store($ckey, $random, $timeout);

$cached = apcu_fetch($ckey,$success);

if ($cached != $random) {
	echo 'cache test; in memory caching is not *working*, this will cause lots of problems'."\r\n";
	exit(1);
}

exit(0);