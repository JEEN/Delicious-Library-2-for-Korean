#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  link-fixer.pl
#
#        USAGE:  [in DL2 Library export dir] ./link-fixer.pl
#
#  DESCRIPTION:  DL2 에서 생성한 HTML결과물에 국내 서적들 링크를 알라딘으로 변경
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:
#      VERSION:  1.0
#      CREATED:  01/04/2010 23:26:04 KST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use 5.010;
use utf8;

use HTML::TreeBuilder;
use Encode qw(decode_utf8);

my $amazon_pattern =
qr#http://www\.amazon\.[a-z.]+/exec/obidos/ASIN/(?<isbn>\d+)/ref=nosim/deliciousmons-\d{2}#;
my $korean_book_pattern = qr#89\d{8}#;
my $aladin_pattern      = 'http://www.aladdin.co.kr/shop/wproduct.aspx?ISBN=';

for my $file ( 'index.html',glob('books-*.html')) {
    my $contents = decode_utf8(read_from_file($file));
    my $tree = HTML::TreeBuilder->new;

    $tree->warn(1);
    $tree->ignore_unknown(1);
    $tree->implicit_tags(1);
    $tree->parse($contents);

    for my $link ( $tree->look_down( 'class', 'title' ) ) {
        if ( $link->attr('href') =~ $amazon_pattern ) {
            my $isbn = $+{isbn};
            $link->attr('href',$aladin_pattern . $isbn) if ( $isbn =~ $korean_book_pattern );
        }
    }

    open my $fh,'>:encoding(utf-8)',$file or die ;
    print $fh $tree->as_HTML('<>&');
    close $fh;
}

sub read_from_file {
    my ( $file ) = @_;

    open my $fh,'<',$file or die;
    my $result;
    { undef $/; $result = <$fh>; }
    close $file;
    return $result;
}
