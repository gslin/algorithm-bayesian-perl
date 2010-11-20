#!perl -T

use Algorithm::Bayesian;
use Test::More tests => 6;

my %hash;
my $s = Algorithm::Bayesian->new(\%hash);

isa_ok($s, 'Algorithm::Bayesian');
can_ok($s, 'test');

is($s->getHamNum, 0);
is($s->getSpamNum, 0);

is($s->testWord('test'), 0.5);
is($s->test, 0.5);
