use Test::Simple tests => 2;
use METS;
use PREMIS;

ok(defined METS->new);
ok(defined PREMIS->new);
