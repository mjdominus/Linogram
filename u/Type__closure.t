
use lib '..';
use Type;
use Test::More tests => 4;

my $t = Type->new("snark");
ok($t->is_closed, "default is closed");
is($t->closure, "CLOSED", "default is closed");
$t->set_closure("OPEN");
ok(! $t->is_closed, "open is not closed");
is($t->closure, "OPEN", "closure is now open");
