#! /usr/bin/perl -w

#the file README.markdown will be made into html to have it in the dmg, in the app help at runtime, and on the web site
#this script should be called from a "Run Script" phase in the Xgrid FUSE target

# This is the original script developed by John Gruber: thanks!
# Markdown script buried in Textmate package
my $markdown_script_path = "/Applications/TextMate.app/Contents/SharedSupport/Support/bin/Markdown.pl";

#path of markdown and html versions of the file
my $readme_markdown_path = "README.markdown";
my $readme_html_path = "README.html";
my $readme_html_template_path = "README-template1.html";

#generate partial html corresponding to the markdown file
my $readme_html_partial = `$markdown_script_path $readme_markdown_path`;

#the final html is obtained by replacing the portion between the markdown markers in the current html file
my $readme_html = slurp ( $readme_html_template_path );
my ( $header , $footer ) = ( $readme_html =~ /^(.*Begin markdown contents -->).*(<!-- End markdown contents.*)$/s );
$readme_html = "$header\n\n$readme_html_partial\n\n$footer";
burp ( $readme_html_path, $readme_html );

exit 0;
							 
# usage: slurp $file_path
# returns: string or array
sub slurp
{
my $path = shift;
local($/) = wantarray ? $/ : undef;
open PATH, "$path" or die "Could not open file $path for reading:\n$!";
my @lines = <PATH>;
close PATH or die "Could not close file $path\n$!";
return $lines[0] unless wantarray;
return @lines;
}
							 
# usage: burp $file_path @lines
# returns: nothing
sub burp
{
	my $path = shift;
	open OUTPUTFILE, ">$path" or die "Could not open file $path for writing:\n$!";
	foreach ( @_ ) { print OUTPUTFILE $_; }
	close OUTPUTFILE or die "Could not close file $path\n$!";
}