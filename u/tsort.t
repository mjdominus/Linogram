#!perl

use Chunk;
use Expression;
use Test::More tests => 1;
use lib '../lib/testutils';
require 'exprs.pl';

sub check_tsort {
    my ($expr, @t) = @_;
    my %done;
    for my $var (@t) {
        
    }
}
