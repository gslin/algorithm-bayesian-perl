#!perl -T

use Algorithm::Bayesian;
use Test::More tests => 13;

my %hash;
my $s = Algorithm::Bayesian->new(\%hash);

can_ok($s, 'ham');
can_ok($s, 'spam');

$s->spam('word1');
is($s->getSpam, 1);
is($s->getHam, 0);

ok($s->testWord('word1') > 0.5);
is($s->testWord('word2'), 0.5);
ok($s->test('word1') > 0.5);

$s->ham('word1', 'word2');
is($s->getSpam, 1);
is($s->getHam, 1);

is($s->testWord('word1'), 0.5);
ok($s->testWord('word2') < 0.5);
is($s->testWord('word3'), 0.5);
ok($s->test('word1', 'word2') < 0.5);
