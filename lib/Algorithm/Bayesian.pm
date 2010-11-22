package Algorithm::Bayesian;

use Carp;
use Math::BigFloat;
use strict;
use warnings;

use constant HAMSTR => '*ham';
use constant SPAMSTR => '*spam';

our $VERSION = '0.3';

=head1 NAME

Algorithm::Bayesian - Bayesian Spam Filtering Algorithm

=head1 SYNOPSIS

    use Algorithm::Bayesian;
    use Tie::Foo;

    my %storage;
    tie %storage, 'Tie:Foo', ...;
    my $b = Algorithm::Bayesian->new(\%storage);

    $b->spam('spamword1', 'spamword2', ...);
    $b->ham('hamword1', 'hamword2', ...);

    my $pr = $b->test('word1', 'word2', ...);

=head1 DESCRIPTION

Algorithm::Bayesian provide an easy way to handle Bayesian spam filtering algorithm.

=head1 SUBROUTINES/METHODS

=head2 new

    my $b = Algorithm::Bayesian->new(\%hash);

Constructor. Simple hash would be fine. You can use L<Tie::DBI> to store data to RDBM, or othre key-value storage.

=cut

sub new {
    my $self = shift or croak;

    my $s = shift;
    $s->{HAMSTR} = 0 if !defined $s->{HAMSTR};
    $s->{SPAMSTR} = 0 if !defined $s->{SPAMSTR};

    bless {storage => $s}, $self;
}

=head2 getHam

    my $num = $b->getHam($word);

Get C<$word> count in Ham.

=cut

sub getHam {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    my $w = shift;

    return $s->{HAMSTR} if !defined $w;
    return $s->{"h$w"} || 0;
}

=head2 getSpam

    my $num = $b->getSpam($word);

Get C<$word> count in Spam.

=cut

sub getSpam {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    my $w = shift;

    return $s->{SPAMSTR} if !defined $w;
    return $s->{"s$w"} || 0;
}

=head2 ham

    $b->ham(@words);

Train C<@words> as Ham.

=cut

sub ham {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    foreach my $w (@_) {
	$s->{"h$w"}++;
    }

    $s->{HAMSTR}++;
}

=head2 spam

    $b->spam(@words);

Train C<@words> as Spam.

=cut

sub spam {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    foreach my $w (@_) {
	$s->{"s$w"}++;
    }

    $s->{SPAMSTR}++;
}

=head2 test

    my $pr = $b->test(@words);

Calculate the spam probability of C<@words>. The range of C<$pr> will be in 0 to 1.

=cut

sub test {
    my $self = shift or croak;

    my $a1 = Math::BigFloat->new('1');
    my $a2 = $a1->copy;

    foreach my $w (@_) {
	my $pr = $self->testWord($w);

	# Avoid 0/1
	$pr = 0.99 if $pr > 0.99;
	$pr = 0.01 if $pr < 0.01;

	$a1 *= 2 * $pr;
	$a2 *= 2 * (1 - $pr);
    }

    return ($a1 / ($a1 + $a2))->bstr;
}

=head2 testWord

    my $pr = $b->testWord($word);

Calculate the spam probability of C<$word>.

The range of C<$pr> will be in 0 to 1.  For non-existence word, it will be 0.5.

=cut

sub testWord {
    my $self = shift or croak;
    my $w = shift or croak;

    my $hamNum = $self->getHam;
    my $spamNum = $self->getSpam;
    my $totalNum = $hamNum + $spamNum;

    return 0.5 if 0 == $totalNum;
    return 1 if 0 == $hamNum;
    return 0 if 0 == $spamNum;

    my $hamPr = $hamNum / $totalNum;
    my $spamPr = $spamNum / $totalNum;

    my $a1 = $self->getSpam($w) * $spamPr / $spamNum;
    my $a2 = $self->getHam($w) * $hamPr / $hamNum;

    return $a1 / ($a1 + $a2);
}

=head1 AUTHOR

Gea-Suan Lin, C<< <gslin at gslin.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-algorithm-bayesian at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-Bayesian>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::Bayesian


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-Bayesian>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-Bayesian>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-Bayesian>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-Bayesian/>

=back


=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Gea-Suan Lin.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Algorithm::Bayesian
