#!/usr/bin/env perl6

use lib 'lib';
use lib '../perl6-http-server-threaded-router/lib';
use Piker;

my $app = Piker.new(dirs => ['usage']);

$app.bind;

$app.listen;
