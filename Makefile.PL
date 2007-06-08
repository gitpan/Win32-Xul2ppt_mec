use strict;
use inc::Module::Install;
#my $plmake = "script/plmake";

name            ('xul2ppt_mec');
all_from        ('lib/Win32/xul2ppt_mec.pm', );
license         ('perl');
install_script  'bin/xul2ppt';

build_requires  ('Test::More');

requires  ('Win32::GuiTest');
requires  ('Clipboard');


&WriteAll;


