package String;

# $Id: String.pm,v 1.2 2003/05/12 02:15:10 sherzodr Exp $

use strict;
use Carp;
use diagnostics;
use vars qw($VERSION $AUTOLOAD);
use overload (
    '""'     => 'asString',
    fallback => 'asString'
  );

($VERSION) = '$Revision: 1.2 $' =~ m/Revision:\s*(\S+)/;

# Preloaded methods go here.

sub AUTOLOAD {
  my $string = shift;

  my (undef, $cline, $cfile) = caller;

  my ($method) = $AUTOLOAD =~ m/([^:]+)$/;
  if ( $method =~ m/^(\w+)_([a-z])(\w+)$/ ) {
    my $properMethod = sprintf("%s%s%s", $1, uc($2), $3);
    unless ( $string->can($properMethod) ) {
      die "Undefined method '$method' called at line $cline of $cfile\n";
    }
    return $string->$properMethod(@_);
  }
  die "Undefined method '$method' called at line $cline of $cfile\n";
}




sub DESTROY {
  my $string = shift;
  $$string = undef;

}




sub new {
  my $class = shift;
  $class = ref($class) || $class;
  my $string = $_[0];
  if ( ref($string) && (ref($string) eq 'SCALAR') ) {
    $string = $$string;
  } elsif ( ref($string) ) {
    croak "$$string doesn't look like a string";
  }

  return bless (\$string, $class);
}


sub length {
  my $string = shift;
  return length ($$string);
}



sub charAt {
  my ($string, $n) = @_;

  unless ( defined($n) ) {
    croak "Usage: chartAt(n)";
  }
  return (split(//, $$string))[$n];
}



sub asString {
  my $string = shift;
  return $$string;
}


sub concat {
  my $string = shift;

  my $newStr = join ("", $$string, @_);
  return $string->new($newStr);
}



sub indexOf {
  my ($string, $substring, $start) = @_;

  my $rv = CORE::index($$string, $substring, $start||0);
  if ( $rv < 0 ) {
    return -1;
  }
  return $rv;
}


sub toUpperCase {
  my $string = shift;

  return $string->new(uc($$string));
}


sub toLowerCase {
  my $string = shift;

  return $string->new(lc($$string));
}


sub split {
  my ($string, $delim, $limit) = @_;

  my @rv =  CORE::split(/$delim/, $$string);
  if ( defined $limit ) {
    @rv = CORE::splice(@rv, $limit);
  }
  map { $string->new($_) } @rv;
}


sub eq {
  my ($string, $string2) = @_;

  return ($$string eq $string2);
}


sub serialize {
  my $string = shift;

  eval "require Storable";
  if ( $@ ) {
    croak "serialize is not supported: Storable is missing";
  }
  return Storable::freeze($string);
}







1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

String - Perl extension representing string object

=head1 SYNOPSIS

  use String;

  my $str = new String("Perl");

  print "The string is '$str'\n";
  printf("Length of the string is %d characters\n", $str->length);
  printf("The first character of the string is %s\n", $str->charAt(0));

  my $pos = $str->indexOf('er');
  if (  $pos != -1 ) {
    printf("String '%s' contains 'er' at position %d\n", $str, $pos);
  }

  my $newStr = $str->concat(" ", "Guru");
  printf("Length of the new string('%s') is %d characters\n", $newStr, $newStr->length);

=head1 FIRST OFF

Perl doesn't need any special class for manipulating strings. It's been successful without such
utilities for years already. String.pm is a utility for being converted programmers who just
want, or got used to seeing things complicated than they should be.

=head1 DESCRIPTION

String is a Perl 5 class representing a string object. It provides String methods for manipulating
text, such as match(), length(), charAt(), indexOf(), split(), asString() and several
more. Since Perl already provides built-in utilities for manipulating stgings, each METHOD description
also provides how this particular task is implemented internally. This may be useful for comparison.

=head1 CONSTRUCTOR

=over 4

=item new(STRONG)

takes a STRING as an argument, and returns String object. Argument passed to new() - STRING
can be either a string, a variable interpolating into a string or a reference to a string.
If it received anything else, will through an exception. Example:

  $str = new String("Perl");

Internally this object is simply a blessed reference to the string itself.
String is "Perl" in our case.

  Note: examples throughout the manual will be working on this particular String
  object unless noted otherwise.

=back

=head1 METHODS

=over 4

=item C<length()>

returns the length of the string. Internally calls Perl's C<length()> built-in function.
Example:

  # assuming 'Perl' is a string
  $str->length == 4;

=item C<charAt(n)>

takes a digit as the first argument, and returns the character from that position of the string.
Example:

  # getting the first character
  $str->charAt(0) == 'P';

  # getting the last character
  $str->charAt( $str->length-1 ) == 'l';

If the argument passed to charAt() is negative, starts the indexing from the end of the string

  # getting the last character of the string:
  $str->charAt(-1);

This function is internally implemented by splitting the string into an array with Perl's
split() function, such as:

  # non-OO alternative for charAt(-1):
  (split //, $string)[-1]

=item indexOf('substring')

returns the index of 'substring' from within String object. Internally calls Perl's built-in
index() function. Example:

  $str->indexOf('er') == 1;

This example returns 1, because the first (and the only in our case) occasion of
substring "er" starts at the second character of "Perl". Since indexing starts at 0,
the second character's index is actually 1. If the match doesn't occur, the return value
is -1. Example:

  if ( $str->indexOf('ear') != -1 ) {
    print "There is no 'ear' in '$str'\n";
  }

=item asString()

returns the original string. Due to overloading, whenever you use String object in the context
where string is expected, asString() will be called for you automatically. Example:

  printf("Original string is '%s'\n", $str->asString );
  # has the same effect as:
  print "Original string is '$str'\n";

=item eq(STRING)

for comparing the string to another string. The argument STRING can be either a literal string,
or String object:

  if ( $str->eq('Java') ) {
    print "They are the same\n";
  }

Due to smart overloading, you can also use Perl's built-in C<eq> operator to compare
String object to another String, or even String object to another string:

  if ( $str eq 'Java') {
    print "There are the same\n";
  }
  # or
  my $str2 = new String("Java");
  if ( $str eq $str2 ) {
    print "They are the same\n";
  }

This method is internally implemented with Perl's built-in C<eq> operator.

=item toLowerCase()

returns a String object by converting all the characters of the original string to their lower cases.
Internally implemented with Perl's built-in C<uc()> function:

  $str->toLowerCase() eq 'perl';

=item toUpperCase()

the same as toLowerCase(), but returns String object by upper-casing the its characters. Implemented
with Perl's built-in C<lc()> function

=item concat(LIST)

returns a String object by concatenating all the elements of LIST. String itself is not modified.
Example:

  $str = new String("Hello");
  $newStr = $str->concat(" ", "World");
  $newStr eq "Hello World";

=item split(REGEX [,LIMIT])

splits a string into substrings at each REGEX-pattern, and returns an array of respective
String objects. If LIMIT is defined, it will restrict the length of an array to first LIMIT
elements. Example:

  $str = new String("one, two, three, four, five");
  @array = $str->split(',\s*');
  for ( @array ) {
    print "$_\n";
  }

=item serialize()

returns a serialized String object. Internally uses L<Storable> to serialize the object
into a string. If the Sorable.pm is not available on your machine, you'll get an exception.

=back

=head1 TODO

I do not expect this class to be exhaustive nor comprehensive. I'm open to suggestions,
additions and comments.

=head1 AUTHOR

Sherzod B. Ruzmetov, E<lt>sherzodr@cpan.orgE<gt>

=head1 SEE ALSO

L<String::Approx>.

=cut
