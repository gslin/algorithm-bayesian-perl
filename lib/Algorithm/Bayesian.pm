package Algorithm::Bayesian;

use Carp;
use strict;
use warnings;

use constant HAMSTR => '*ham';
use constant SPAMSTR => '*spam';

our $VERSION = '0.1';

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

    my $bool = $b->test('word1', 'word2', ...);

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 new
=cut

sub new {
    my $self = shift or croak;

    my $s = shift;
    $s->{HAMSTR} = 0 if !defined $s->{HAMSTR};
    $s->{SPAMSTR} = 0 if !defined $s->{SPAMSTR};

    bless {storage => $s}, $self;
}

=head2 getHam
=cut

sub getHam {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    my $w = shift or croak;

    return $s->{"h$w"} || 0;
}

=head2 getHamNum
=cut

sub getHamNum {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    return $s->{HAMSTR};
}

=head2 getSpam
=cut

sub getSpam {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    my $w = shift or croak;

    return $s->{"s$w"} || 0;
}

=head2 getSpamNum
=cut

sub getSpamNum {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    return $s->{SPAMSTR};
}

=head2 ham
=cut

sub ham {
    my $self = shift or croak;
    my $s = $self->{storage} or croak;

    foreach my $w (@_) {
	$s->{"h$w"}++;
    }

    $s->{HAMSTR}++;
}

=head2 ham
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
=cut

sub test {
    my $self = shift or croak;

    my $a1 = 1;
    my $a2 = 1;

    foreach my $w (@_) {
	my $pr = $self->testWord($w);

	# Avoid 0/1
	$pr = 0.99 if $pr > 0.99;
	$pr = 0.01 if $pr < 0.01;

	$a1 *= 2 * $pr;
	$a2 *= 2 * (1 - $pr);
    }

    return $a1 / ($a1 + $a2);
}

=head2 testWord
=cut

sub testWord {
    my $self = shift or croak;
    my $w = shift or croak;

    my $hamNum = $self->getHamNum;
    my $spamNum = $self->getSpamNum;
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
