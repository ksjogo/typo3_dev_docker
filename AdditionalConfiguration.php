<?php
$GLOBALS['TYPO3_CONF_VARS']['DB']['host'] = getenv('MYSQL_HOST');
$GLOBALS['TYPO3_CONF_VARS']['DB']['username'] = getenv('MYSQL_USER');
$GLOBALS['TYPO3_CONF_VARS']['DB']['password'] = getenv('MYSQL_PASSWORD');
$GLOBALS['TYPO3_CONF_VARS']['DB']['port'] = 3306;
$GLOBALS['TYPO3_CONF_VARS']['DB']['database'] = getenv('MYSQL_DATABASE');
$GLOBALS['TYPO3_CONF_VARS']['BE']['installToolPassword'] = md5(getenv('INSTALL_TOOL_PASSWORD'));
