use strict; use warnings;
package App::TeXMine;
{
  $App::TeXMine::VERSION = '0.01_15';
}
use feature 'say';

# ABSTRACT: extract information from LaTeX files


sub img_cmd {
	my $c = shift;
	my $files = $c->argv;
	return _exec_cmd(\&img,$files,$c->options);
}



sub img {
	my ($file,$options) = @_;
	my $res = [];
	my $imgpat  = qr/\\(?:includegraphics|pgfimage).*?{.*?}/;
	my $fh = _open_file($file);
	while (my $line = <$fh>){
		last if $line =~ m|\\end{document}| and ! $options->{a};
	 	if ($line =~ /$imgpat/p) {
			my $comm = ${^MATCH};
			my $img = $comm;
			$img =~ s/^.*?{(.*?)}/$1/;
			push @$res,$img if $img;
		}
	}
	close $fh;
	return 0+@$res if $options->{c};
	return join "\n",(defined($options->{s}) ? sort { lc($a) cmp lc($b) } @$res : @$res);
}



sub url_cmd {
	my $c = shift;
	my $files = $c->argv;
	return _exec_cmd(\&url,$files,$c->options);
}


sub url{
	my ($file,$options) = @_;
	my $res = [];
	my $urlpat  = qr/\\url{.*?}/;
	my $fh = _open_file($file);
	while (my $line = <$fh>){
		last if $line =~ m|\\end{document}| and ! $options->{a};
	 	if ($line =~ /$urlpat/p) {
			my $comm = ${^MATCH};
			my $url = $comm;
			$url =~ s/^.*?{(.*?)}/$1/;
			say $url;
			push @$res,$url if $url;
		}
	}
	close $fh;
	return 0+@$res if $options->{c};
	return join "\n",(defined($options->{s}) ? sort { lc($a) cmp lc($b) } @$res : @$res);
}


sub bib_cmd {
	my $c = shift;
	my $files = $c->argv;
	return _exec_cmd(\&bib,$files,$c->options);
}


sub bib {
	my ($file,$options) = @_;
	my $res = [];
	my $citepat = qr/\\(?:no)?cite{.*?}/;
	my $fh = _open_file($file);
	while (my $line = <$fh>){
		last if $line =~ m|\\end{document}| and ! $options->{a};
	 	if ($line =~ /$citepat/p) {
			my $comm = ${^MATCH};
			my $cite = $comm;
			$cite =~ s/^.*?{(.*?)}/$1/;
			push @$res,(split /,/,$cite);
		}
	}
	close $fh;
	return 0+@$res if $options->{c};
	return join "\n",(defined($options->{s}) ? sort { lc($a) cmp lc($b) } @$res : @$res);
}


sub index_cmd {
	my $c = shift;
	my $files = $c->argv;
	return _exec_cmd(\&index,$files,$c->options);
}


sub index {
	my ($file,$options) = @_;
	my $res;
	my $secpat  = qr/\\(?:sub)*section{.*?}/;
	my $chpat   = qr/\\chapter{.*?}/;
	my $fh = _open_file($file);
	while (my $line = <$fh>) {
		last if $line =~ m|\\end{document}| and ! $options->{a};
		if ($line =~ /$chpat/p) {
			my $comm = ${^MATCH};	
			my $chap = $comm;
			$chap =~ s/^.*?{(.*?)}/$1/;
			$res.="$chap\n";
		}
		if ($line =~ /$secpat/p){
			my $comm = ${^MATCH};	
			my $sec = $comm;
			$sec =~ s/^.*?{(.*?)}/$1/;
			my $tabs = 0;
	
			$tabs = $comm =~ s/sub//g;
			
			$res.= "    "x$tabs;
			$res.=" - $sec\n";
		}
	}
	close $fh;
	return $res;
}


sub _open_file {
	my ($file) = @_;
	open my $fh, '<', $file or die "Could not open file '$file': $!";
	return $fh;
}

sub _exec_cmd {
	my ($func,$files,$options) = @_;
	my $res;
	foreach my $file (@$files){
		$res.= $func->($file,$options);
	}
	return $res;
}


1; # End of App::TeXMine

__END__
=pod

=head1 NAME

App::TeXMine - extract information from LaTeX files

=head1 VERSION

version 0.01_15

=head1 SYNOPSIS

texmine command file.tex

Run C<texmine help> for more options

=head1 DESCRIPTION

texmine is a script to quickly inspect the contents of a LaTeX file,
such as image references, URLs, table of contens and citations.

=head1 SUBROUTINES/METHODS

=head2 img_cmd

=head2 img

=head2 url_cmd

=head2 url

=head2 bib_cmd

=head2 bib

=head2 index_cmd

=head2 index

=head1 AUTHOR

Andre Santos, C<< <andrefs at cpan.org> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::TeXMine

=head1 DEVELOPMENT

=head2 Repository

L<http://github.com/andrefs/app-texmine>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Andre Santos.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 AUTHOR

Andre Santos <andrefs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Andre Santos.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

