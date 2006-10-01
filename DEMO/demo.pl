#demo.pl
#2006-09-30 2006-09-30

use strict;
use warnings;
use Test::More tests => 7;

use Win32::xul2ppt_mec;

my $obj = Win32::Xul2ppt_mec->new(	 
				  'range'	=> [5, 10],
				  'interval'	=> 2,
				  'dir'		=> 'D:/tmp',
				  'name'	=> 'sample.ppt',
			 );

L:
print "\nplease open \"D:/zwx/Win32/t/pattern/pattern.xul\" with mozilla firefox,
	and start powerpoint.No minimizing any, if ready, please input 'ok'...\n: ";
my $sure = <STDIN>;
chomp $sure;

goto L unless $sure =~ m/ok/i;
$obj->shoot();
#$obj->trim();  #if image-magic has been installed, comment can be removed to get mini pictures
$obj->to_ppt();

for($obj->{range}[0]..$obj->{range}[1]) {
	is -e "$obj->{dir}/png/tmp".sprintf("%03d", $_).".png", 1, "$obj->{dir}/p/tmp".sprintf("%03d", $_).".png";
}
is -e "$obj->{dir}/ppt/$obj->{name}", 1, "$obj->{dir}/ppt/$obj->{name} exists!";
