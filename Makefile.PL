use strict;
use inc::Module::Install;
#my $plmake = "script/plmake";

name            ('Xul2ppt_mec');
all_from        ('lib/Win32/Xul2ppt_mec.pm', );
license         ('perl');
install_script  'bin/xul2ppt';

build_requires  ('Test::More');

requires  ('Win32::GuiTest');
requires  ('Clipboard');

makemaker_args  (
    test => { TESTS => "t/*.t"},
);

&WriteAll;


