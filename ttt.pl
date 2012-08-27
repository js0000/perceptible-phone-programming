#! /usr/bin/env perl

# ttt.pl
# Text Transmission Tones
# a perl script for generating a csound file to produce audio
#     thought to be suitable for an audio SMS notification by the composer/programmer
#     also powers of 2 [or similar geometric doubling] used whever possible
# copyright 2012 john saylor
#     released under the terms of the GNU general public license v3.0

use strict;
use warnings;


use IO::File;
my $time = time();
my $filename = join( '',
    'ttt_',
    $time,
    '.csd'
);
my $fh = new IO::File $filename, 'w';
if ( ! defined( $fh ) ) {
    die "could not write to $filename: $!";
}


use List::Util qw( shuffle );

# of one second
my $sixty_fourth = sprintf( "%.02f", 1 / 32 );

my @durations = (
    $sixty_fourth * 8,
    $sixty_fourth * 4,
    $sixty_fourth * 2,
    $sixty_fourth
);

my @amplitudes = (
    0.5,
    0.75,
    0.875,
    0.9375
);

my @tmp = shuffle( @durations );
@durations = shuffle( @tmp );

@tmp = shuffle( @amplitudes );
@amplitudes = shuffle( @tmp );

my $dur;
my $amp;

# one of these becomes $p5 depending on instrument
my $bfl = 1;
my $frq = 32;
my $p5 = $bfl;

my $idx;
my $score = [];
my @line = ();
my $music_time = 0;
my $instrument = 'i4';

for( my $i = 0; $i < 16; $i++ ) {

    # select randomly from several different durations/amplitudes
    $idx = int( rand( scalar( @durations ) ) );
    $dur = $durations[ $idx ];

    if( int( rand( 8 ) ) ) {
        $idx = int( rand( scalar( @amplitudes ) ) );
        $amp = $amplitudes[ $idx ];
    }
    # silent surprise
    else {
        $amp = 0;
    }

    @line = ();
    push( @line, $instrument, $music_time, $dur, $amp, $p5 );
    push( @$score, { line => join( "\t", @line ) } );

    $music_time += $dur;
    
    # do this each time, even if not used
    $bfl = sprintf( "%.02f", $bfl - 0.04 );

    if( int( rand( 4 ) ) ) {
        $instrument = 'i4';
	$p5 = $bfl;
    }
    else {
        $instrument = 'i2';

        my $change = 4;
        if( int( rand( 2 ) ) ) {
            $frq -= $change;
        }
        else {
            $frq += $change;
        }

	if( $frq < 24 ) {
	    $frq = 32;
	}
	elsif( $frq > 40 ) {
	    $frq = 32;
	}

	$p5 = $frq;
    }
}

# silence up to 2 seconds
@line = ();
$dur = sprintf( "%.02f", 2.0 - $music_time );
push( @line, 'i2', $music_time, $dur, 0, 0 );
push( @$score, { line => join( "\t", @line ) } );


use HTML::Template;

my $template = HTML::Template->new(filename => 'ttt.tmpl');
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

