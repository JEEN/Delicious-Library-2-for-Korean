package DL2::Updater;
use strict;
use warnings;
use Mac::AppleScript qw(RunAppleScript);

sub update {
   my ($class, $param) = @_;

   my $script = <<SCRIPT;
tell first document of application "Delicious Library 2"
set selected media to make new book with properties {name:"$param->{title}", creators:"$param->{authors}", publisher:"$param->{publisher}", genres:"$param->{genres}", cover URL:"$param->{image}", isbn:"$param->{isbn}", price:"$param->{price}", associated URL:"$param->{url}", features:"$param->{features}", notes:"$param->{notes}"}
end tell
SCRIPT

   RunAppleScript($script);
}

1;