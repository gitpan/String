# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
use Data::Dumper;
use diagnostics;
BEGIN {
  plan tests => 35;
};
require String;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $str = new String('Sherzod');
ok($str);

ok($str eq 'Sherzod');

ok($str->length == 7);

ok($str->charAt(0) eq 'S');

ok($str->charAt( $str->length-1 ) eq 'd');
ok($str->charAt( $str->length-1 ) eq $str->charAt(-1) );
#ok($str->charAt(0) eq $str->char_at(0));

my $concat = $str->concat(" ", "Ruzmetov");
ok($concat eq "Sherzod Ruzmetov");
ok($concat->isa('String'));



my $str2 = new String("Ruzmetov");

ok( $str->eq("Sherzod") );
ok($str->concat($str2) eq "SherzodRuzmetov");
ok($str . " " . $str2 eq "Sherzod Ruzmetov");


ok($str->indexOf('er') == 2);
#ok($str->indexOf('er') == $str->index_of('er'));

my $uc =  $str->toUpperCase();
my $lc =  $str->toLowerCase();

ok($uc eq 'SHERZOD');
ok($lc eq 'sherzod');

ok(ref($uc) eq 'String');
ok(ref($lc) eq 'String');

ok($uc->asString eq "SHERZOD");


my $str3 = new String("Hello World");

ok(($str3->split('\s+'))[1] eq 'World');
ok(ref( ($str3->split('\s+'))[1]) eq 'String');

ok( ( split /\s+/, $str3 )[1] eq 'World');

my $str4 = new String('Sherzod Ruzmetov <sherzodr@cpan.org>');

my $result = $str4->match('([\w.-]+)@([\w-]+\.[\w.-]+)');
ok($result);
ok($result->[0] eq 'sherzodr@cpan.org');
ok($result->[1] eq 'sherzodr');
ok($result->[2] eq 'cpan.org');
ok(ref($result->[0]) eq 'String');
ok($result->[2]->match('^cpan\.org$') );
ok($str4->match('sherzodr@hotmail.com') ? 0 : 1);


# testing overloaded '+' operator
my $str5 = new String("Hello");
ok($str5->as_string eq 'Hello');
$str5 += " World";
ok($str5 eq "Hello World");

my $str6 = " " + $str5 + " " + $str4;
ok($str6 eq " Hello World Sherzod Ruzmetov <sherzodr\@cpan.org>");

# in the end we still need to make sure that with all the above
# operations we didn't alter the original string
ok($str eq 'Sherzod');
ok($str2 eq 'Ruzmetov');
ok($str3 eq 'Hello World');
ok($str4 eq 'Sherzod Ruzmetov <sherzodr@cpan.org>');



