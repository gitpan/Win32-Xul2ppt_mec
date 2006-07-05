@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15
#xul2ppt.pl is a command line tool to convert Xul to ppt on Win32 platform mechanically
#Copy Right (C) Sal Zhong 
#2006-07-04 2006-07-05


use strict;
use warnings;
use Win32::GuiTest qw(:ALL);
use Clipboard;
use Carp qw/croak carp/;
use Getopt::Std;

our $VERSION = '0.01';

my %opts;
getopt('ridn', \%opts);

my $range = $opts{'r'};
if($range) {
	if($range =~ m/(\d+),\s*(\d+)/) {
		$range = [$1, $2];
	} else {
		die "Usage: perl [ -r '[num1, num2]' | -i num | -d string | -n string | -p string ]  xul2ppt.pl";
	}
} else {
	$range = [1, 10];
}
my $interval = $opts{'i'} || 2;
my $dir = $opts{'d'} || 'D:/tmp';
my $name = $opts{'n'} || 'sample.ppt';

	
mkdir "$dir" unless -d "$dir";
mkdir "$dir/png" unless -d "$dir/png";
mkdir "$dir/ppt" unless -d "$dir/ppt";

shoot();
trim();
to_ppt();


sub shoot {
	my $self = shift;
	my @mozilla = FindWindowLike(0, "Mozilla");
	if (@mozilla){
		print "start shooting\n" ;
		SetForegroundWindow($mozilla[0]);
		sleep $interval;
		SendKeys("{F11}");
		sleep $interval;

	} else {
		croak "\n", '-'x80, "\nPlease open Xul file with mozilla firefox! and starting powerpoint\n", '-'x80, "\n";
	}
	my $i = 1;
	while(1) {		
		if($i >= $$range[0] && $i <= $$range[1]) {
			SendKeys("{PRTSCR}");
			sleep $interval;		
			
			sleep $interval;	
			my $file = "$dir/png/tmp".sprintf("%03d", $i).".png";
			open my $fh, ">$file" or carp "cannot open $file to write:$!\n";
			binmode $fh;
			print $fh Clipboard->paste; 
			close $fh or carp $!, "\n";	
		}
		if($i > $$range[1]) {
			last;
		}
		SendKeys("{DOWN}");
		$i++;		
	}
	

}

sub trim {
	my $self = shift;
	print "start trimming pictures!\n";
	my @pngs = glob("$dir/png/tmp*.png");
	for(@pngs) {
			last if system "convert -crop +0+25 $_ $_";
			last if system "convert -trim $_ $_";
	}
}

sub to_ppt {
	my $self = shift;
	my @ppt = FindWindowLike(0, "PowerPoint");
	if (@ppt){
		print "start converting\n" ;
		SetForegroundWindow($ppt[0]);
		sleep $interval;
		
		SendKeys("^n");
		sleep $interval;
	} else {
		croak "Please start powerpoint\n";
	}
	my @pngs = glob("$dir/png/tmp*.png");
	for(@pngs) {
		Clipboard->copy($_);
		sleep $interval;
		SendKeys("%ipf");
		#WaitWindowLike($ppt[0], "≤Â»ÎÕº∆¨");
		sleep $interval;
		SendKeys("^v~");
		sleep $interval;
		SendKeys("^m");

	}
	SendKeys("^s");
	sleep $interval;
	my $location = "$dir/ppt/$name~";
	$location =~ s{\/}{\\}g;
	SendKeys("$location");
}


__END__
:endofperl
