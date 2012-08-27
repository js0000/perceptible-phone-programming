#! /usr/bin/env perl

# rrr.pl
# Random-like Ringtone Realization
# a perl script for generating a csound file to produce audio
#     thought to be suitable for a ringtone by the composer/programmer
#     also prime numbers used whever possible
# copyright 2012 john saylor
#     released under the terms of the GNU general public license v3.0


use strict;
use warnings;

use IO::File;

my $time = time();
my $filename = join( '',
    'rrr_',
    $time,
    '.csd'
);
my $fh = new IO::File $filename, 'w';
if ( ! defined( $fh ) ) {
    die "could not write to $filename: $!";
}


use List::Util qw( shuffle );
my @shuffled_primes = shuffle(
    439,
    761,
    1103,
    1483,
    1867,
    2251,
    2659,
    3037,
    3463,
    3853,
    4261,
    4703,
    5119,
    5569,
    6011,
    6421,
    6871,
    7333,
    7759,
    8243,
    8707,
    9157,
    9601,
    10067,
    10501,
    10993,
    11489,
    11969,
    12437,
    12899,
    13339,
    13831,
    14387,
    14813,
    15287,
    15737,
    16223,
    16741,
    17239,
    17729,
    18199,
    18701,
    19267,
    19751
);

my @available_divisions = shuffle( 11, 13, 17, 19 );
my $idx = int( rand( scalar( @available_divisions ) ) );
my $parts = $available_divisions[ $idx ];
my $one_third = sprintf( "%.03f", $parts / 3 );

# per second
my $duration = sprintf( "%.03f", 1 / $parts );
my $frequency;

my $score = [];
my @line = ();
my $music_time = 0;

# starting vol
my $amplitude = 0.661;

for( my $i = 0; $i < $parts; $i++ ) {
    
    @line = ();

    $idx = int( rand( scalar( @shuffled_primes ) ) );
    $frequency = $shuffled_primes[ $idx ];

    # instrument start-time_seconds duration_seconds amplitude_0-1 frequency_hz
    push( @line, 'i3', $music_time, $duration, $amplitude, $frequency );
    push( @$score, { line => join( "\t", @line ) } );

    # for modifying variables
    my $change;

    # last third
    if( $i > ( 2 * $one_third ) ) {
    
        # softer by a fifth
	$change = sprintf( "%.03f", $amplitude / 5 );
	$amplitude -= $change;

	if( int( rand( 3 ) ) ) {
	    $duration += 0.071;
	}
    }
    # middle third
    # amplitude peaks for middle third and falls off thereafter
    elsif( $i > $one_third ) {
        $change = sprintf( "%.03f", rand( 0.073 ) );
	
	# 2 *is* prime, btw ...
	if( int( rand( 2 ) ) ) {
	    $amplitude += $change;
	}
	else {
	    $amplitude -= $change;
	}

        # possible corrections
        if( $amplitude > 0.997 ) {
	  $amplitude = 0.991;
	}
	elsif( $amplitude < 0.811 ) {
	  $amplitude = 0.821;
	}
    }
    # first third
    else {

        # louder by some random amount
        $change = sprintf( "%.03f", rand( 0.079 ) );
	$amplitude += $change;
        if( $amplitude > 0.983 ) {
	  $amplitude = 0.977;
	}
    }
    
    $music_time += $duration;
}

# silence up to 3 seconds
@line = ();
$duration = sprintf( "%.03f", 3.0 - $music_time );
push( @line, 'i3', $music_time, $duration, 0, 0 );
push( @$score, { line => join( "\t", @line ) } );


use HTML::Template;

my $template = HTML::Template->new(filename => 'rrr.tmpl');
$template->param( 
    FILENAME => $filename,
    DATE_TIME => scalar( localtime( $time ) ),
    EPOCH => $time, 
    SCORE => $score 
);

$fh->print( $template->output() );
$fh->close();

print "csound file $filename generated ok\n\n";
exit;

