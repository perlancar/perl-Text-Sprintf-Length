package Text::Sprintf::Length;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(sprintf_length);

# XXX BEGIN COPIED FROM Text::sprintfn

my  $re1   = qr/[^)]+/s;
my  $re2   = qr{(?<fmt>
                    %
                       (?<pi> \d+\$ | \((?<npi>$re1)\)\$?)?
                       (?<flags> [ +0#-]+)?
                       (?<vflag> \*?[v])?
                       (?<width> -?\d+ |
                           \*\d+\$? |
                           \((?<nwidth>$re1)\))?
                       (?<dot>\.?)
                       (?<prec>
                           (?: \d+ | \* |
                           \((?<nprec>$re1)\) ) ) ?
                       (?<conv> [%csduoxefgXEGbBpniDUOF])
                   )}x;
our $regex = qr{($re2|%|[^%]+)}s;

# faster version, without using named capture
if (1) {
    $regex = qr{( #all=1
                    ( #fmt=2
                        %
                        (#pi=3
                            \d+\$ | \(
                            (#npi=4
                                [^)]+)\)\$?)?
                        (#flags=5
                            [ +0#-]+)?
                        (#vflag=6
                            \*?[v])?
                        (#width=7
                            -?\d+ |
                            \*\d+\$? |
                            \((#nwidth=8
                                [^)]+)\))?
                        (#dot=9
                            \.?)
                        (#prec=10
                            (?: \d+ | \* |
                                \((#nprec=11
                                    [^)]+)\) ) ) ?
                        (#conv=12
                            [%csduoxefgXEGbBpniDUOF])
                    ) | % | [^%]+
                )}xs;
}

# XXX END COPIED FROM Text::sprintfn

sub sprintf_length {
    my $format = shift;

    my $sprintf_width = length($format);

    while ($format =~ /$regex/g) {
        my ($all, $fmt, $pi, $npi, $flags,
            $vflag, $width, $nwidth, $dot, $prec,
            $nprec, $conv) =
                ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12);

        if ($fmt && defined $sprintf_width) {

            if ($conv eq '%' || $conv eq 'c') {
                $width //= 1;
            } elsif ($conv eq 'p' || $conv eq 'c') {
                $width //= 1;
            } elsif ($conv eq 'n') {
                $width = 0;
            }

            if (defined $width) {
                $sprintf_width += $width - length($all);
            } else {
                $sprintf_width = undef;
            }

        }
    }

    $sprintf_width;
}

1;
# ABSTRACT: Calculate length of sprintf()-formatted string

=head1 SYNOPSIS

 use Text::Sprintf::Length qw(sprintf_length);

 my $len;

 $len = sprintf_length("%s");        # => undef
 $len = sprintf_length("%8s") ;      # => 8
 $len = sprintf_length("%8s %% %c"); # => 12


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 sprintf_length

Usage:

 sprintf_length($fmt) => int|undef

=cut
