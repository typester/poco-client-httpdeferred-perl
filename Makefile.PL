use inc::Module::Install;
name 'POE-Component-Client-HTTPDeferred';
all_from 'lib/POE/Component/Client/HTTPDeferred.pm';

requires 'POE';
requires 'POE::Component::Client::HTTP';
requires 'Moose';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
