#!/usr/bin/raku

my $cword = "";
my $cline = "";
my $lsize = 80;
my $para  = 0;

# Get character by character
for "/dev/stdin".IO.open.split("") {

	next if not $_;

	$para = ( $_ ~~ / \n / ) ?? $para + 1 !! 0;

	if $_ ~~ / \s / {
		if $cword.chars + $cline.chars + 1 < $lsize {
			$cline ~= " " if $cline;
			$cline ~= $cword;

			$cword = "";
		} elsif $cword {
			say $cline;
			$cline = $cword;
		}

		if $para == 2 {
			say $cline if $cline;
			say "";

			$para = 0;
			$cline = "";
		}
	} else {
		$cword ~= $_;
	}
}

# if (strlen(s) > 0)
# 	puts(s);
#
#

say $cline if $cline;
