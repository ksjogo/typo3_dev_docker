<?php
$GLOBALS['TYPO3_CONF_VARS']['DB']['Connections']['Default'] =[
    'driver' => 'mysqli',
    'host' => getenv('MYSQL_HOST'),
    'port' => 3306,
    'dbname' => getenv('MYSQL_DATABASE'),
    'user' => getenv('MYSQL_USER'),
    'password' => getenv('MYSQL_PASSWORD')
];