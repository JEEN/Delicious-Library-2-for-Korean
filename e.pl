#!/usr/bin/env perl
# isbn input shell
use strict;
use warnings;
use WebService::Aladdin;
use Encode qw/decode/;
use Mac::AppleScript qw(RunAppleScript);
use Term::ReadLine;

my $file = $ENV{HOME} . "/Library/Application Support/Delicious Library 2/Scanned UPCs Log.txt";

my $term = Term::ReadLine->new();
my $aladdin = WebService::Aladdin->new;

while(defined(my $code = $term->readline("isbn> "))) {
	my $res = $aladdin->search($code, { Cover => "Big" });
	my $result = $res->{items}->[0];
	unless ($result) {
		warn "can't find a products : $code";
		next;
	}
	process_res($result);
}

sub process_res {
	my ($result) = @_;

	my $param = {
		book_name => $result->{title},
		authors   => $result->{author},
		genres    => $result->{categoryName},
		image     => $result->{cover},
		publisher => $result->{publisher},
		isbn      => $result->{isbn},
		features  => $result->{description},
		notes     => $result->{content},
		url       => $result->{link},
		pages     => $result->{itemPage},
		price     => $result->{priceStandard},
	};
	
	$param = _filter($param);
	__run_apple_script($param);
	if ($@) {
		warn "something's wrong : $@";
		next;
	} 
	print $result->{title}."\n";
}


sub _filter {
	my ($param) = @_;

	$param->{$_} = Encode::decode('utf8', $param->{$_}) for keys %{ $param };
	$param->{features} =~ s/"/'/g;
	$param->{notes} =~ s/"/'/g;
    $param->{notes} =~ s/<br\s?\/?>/\n/g;
	$param->{notes} =~ s/<\/?[a-zA-Z]*\s?[a-zA-Z]*=[^>]*?\s*\/?>//g;
	$param;
}

sub __run_apple_script {
	my ($param) = @_;

	my $script = <<SCRIPT;
tell first document of application "Delicious Library 2"
set selected media to make new book with properties {name:"$param->{book_name}", creators:"$param->{authors}", publisher:"$param->{publisher}", genres:"$param->{genres}", cover URL:"$param->{image}", isbn:"$param->{isbn}", price:"$param->{price}", associated URL:"$param->{url}", features:"$param->{features}", notes:"$param->{notes}"}
end tell
SCRIPT

	RunAppleScript($script);
}
