use inc::Module::Install;
name 'POE-Component-Client-HTTPDeferred';
all_from 'lib/POE/Component/Client/HTTPDeferred.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
