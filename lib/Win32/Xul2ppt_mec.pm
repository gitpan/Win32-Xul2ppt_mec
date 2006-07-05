#Xul2ppt_mec.pm converts Xul to ppt on Win32 platform mechanically
#Copy Right (C) Sal Zhong 
#2006-07-04 2006-07-04

package Win32::Xul2ppt_mec;

use strict;
use warnings;
use Win32::GuiTest qw(:ALL);
use Clipboard;
use Carp qw/croak carp/;
our $VERSION = '0.01';

sub new {
	my $proto = shift;
	croak "uninvalid args!\n" unless @_%2 == 0;
	
	my $class = ref($proto) || $proto;
	my %args = @_;	
	my $self = \%args;
	$self->{'range'} = [1..10]		unless $self->{'range'};
	$self->{'interval'} = 2			unless $self->{'interval'};
	$self->{'dir'} = 'D:/tmp'		unless $self->{'dir'};
	$self->{'name'} = 'sample.ppt'  unless $self->{'name'};
	
	mkdir "$self->{'dir'}" unless -d "$self->{'dir'}";
	mkdir "$self->{'dir'}/png" unless -d "$self->{'dir'}/png";
	mkdir "$self->{'dir'}/ppt" unless -d "$self->{'dir'}/ppt";

	return bless $self, $class;
}

sub range {
	my $self = shift;
	my $range = shift;
	return $self->{'range'} unless $range;
	$self->{'range'} = $range;
}

sub interval {
	my $self = shift;
	my $range = shift;
	return $self->{'interval'} unless $range;
	$self->{'interval'} = $range;
}

sub dir {
	my $self = shift;
	my $dir = shift;
	return $self->{'dir'} unless $dir;
	$self->{'dir'} = $dir;
}

sub name {
	my $self = shift;
	my $name = shift;
	return $self->{'name'} unless $name;
	$self->{'name'} = $name;
}
sub postfix {
	my $self = shift;
	my $postfix = shift;
	return $self->{'postfix'} unless $postfix;
	$self->{'postfix'} = $postfix;
}

sub shoot {
	my $self = shift;
	my @mozilla = FindWindowLike(0, "Mozilla");
	if (@mozilla){
		print "start shooting\n" ;
		SetForegroundWindow($mozilla[0]);
		sleep $self->{'interval'};
		SendKeys("{F11}");
		sleep $self->{'interval'};

	} else {
		croak "\n",'-'x80,"\nPlease open Xul file with mozila firefox! and starting powerpoint......\n", '-'x80, "\n";
	}
	my $i = 1;
	while(1) {		
		if($i >= $self->{'range'}[0] && $i <= $self->{'range'}[1]) {
			SendKeys("{PRTSCR}");
			sleep $self->{'interval'};		
			sleep $self->{'interval'};	
			my $file = "$self->{'dir'}/png/tmp".sprintf("%03d", $i).".png";
			open my $fh, ">$file" or carp "cannot open $file to write:$!\n";
			binmode $fh;
			print $fh Clipboard->paste; 
			close $fh or carp $!, "\n";	
		}
		if($i > $self->{'range'}[1]) {
			last;
		}
		$i++;		
		SendKeys("{DOWN}");
	}
	

}

sub trim {
	my $self = shift;
	print "start trimming pictures!\n";
	my @pngs = glob("$self->{'dir'}/png/tmp*.png");
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
		sleep $self->{'interval'};
		
		SendKeys("^n");
		sleep $self->{'interval'};
	} else {
		croak "Please start powerpoint\n";
	}
	my @pngs = glob("$self->{'dir'}/png/tmp*.png");
	for(@pngs) {
		Clipboard->copy($_);
		sleep $self->{'interval'};
		SendKeys("%ipf");
		#WaitWindowLike($ppt[0], "²åÈëÍ¼Æ¬");
		sleep $self->{'interval'};
		SendKeys("^v~");
		sleep $self->{'interval'};
		SendKeys("^m");

	}
	SendKeys("^s");
	sleep $self->{'interval'};
	my $location = "$self->{dir}/ppt/$self->{name}~";
	$location =~ s{\/}{\\}g;
	SendKeys("$location");
}

1;

__END__

=head1 NAME

Xul2ppt_mec.pm - convert Xul to ppt on Win32 Platform mechanically

=head1 SYNOPSIS

	use strict;
	use warnings;	
	use Win32::Xul2ppt_mec;

	my $obj = Win32::Xul2ppt_mec->new(	  
					  'range'	=> [1, 10],
					  'interval'	=> 1,
					  'dir'			=> 'D:/tmp',
					  'name'		=> 'sample.ppt',
					  );

	$obj->shoot();	#catch screen from mozilla firefox and generate images 
	#$obj->trim();	#trim the intermediate images
	$obj->to_ppt(); #insert the images into your ppt

Note: (If you want to convert directly, please consult the bundled L<Xul2ppt>  utilities.)

=head1 DESCRIPTION

This module provides an interface to convert .Xul files to .ppt files with virtual or mechanical method.
By the interfaces of controlling keys and mouse automacally provided by Win32::Guitest, you can convert your Xul 
to ppt in free time. To do so, Win32::Guitest module installer is prerequired. And if you need to trim the pictures
to get a mini-ppt files Image-Magic installer also prerequired.

=head1 METHOD

=over

=item * $obj->new()

	my $obj = Win32::Xul2ppt_mec->new(	  
						  'range'	=> [1, 10],
						  'interval'	=> 1,
						  'dir'			=> 'D:/tmp',
						  'name'		=> 'sample.ppt',
						  );

The attributes of the Xul2ppt_mec are described below, in the L<ATTRIBUTES>
section.

=item * $obj->shoot()

Before invoking this method, please make sure that your xul file has already been opened by mozilla firefox and 
the window not minimized.

=item * $obj->trim()

After the shoot terminates, pictures of your Xul files displayed on mozilla firefox are catched and saved under a 
certain directory. However,  some blemish remains in the intial pictures, further trimming the pictures are strongly
recommended. Two command lines provided by Imagic-Magic are invoking: 

"convert -crop +0+25 $file $file" 

"convert -trim $file $file".

=item * $obj->to_ppt();

Automacally inserts pictures into your ppt files. Before running, powerpoint should be started and not minimized!

=back

=head1 ATTRIBUTES

=over

=item * $obj->{'range'}
Set the start and end index of Xul shooted

=item * $obj->{'interval'}

set the interval of seconds between each mechanical operation, if it runs on a fast machine, you can shorten it. 
2 seconds is default value.

=item * $obj->{'dir'}

set the directory, under which all the intermediate files will be saved. and 'D:\tmp' is default;

=item * $obj->{'name'}

set the name of your ppt file, 'sample.ppt' is default

=back

=head1 xul2ppt command tools to convert xul to ppt

=head2 SYNOPSIS

xul2ppt [ -r "[num1, num2]" | -i num | -d string | -n string ]  xul2ppt.pl

=head2 OPTIONS

=over

=item * -r See $obj->{'range'}

=item * -i See $obj->{'interval'}

=item * -d See $obj->{'dir'}

=item * -n See $obj->{'name'}

=back

set the postfix of the intermediate images. 'png' is default.

=head1 AUTHOR

Sal Zhong (Zhong Wei Xiang)

=begin html

<a href = "mailto: zhongxiang721@gmail.com"> Contact me </a>

=end html

=head1 COPYRIGHT

Copyright (c) 2006 Sal Zhong. All rights reserved.
