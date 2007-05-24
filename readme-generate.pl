#! /usr/bin/perl -w

#the file README.markdown will be made into html to have it in the dmg, in the app help at runtime, and on the web site
#this script should be called from a "Run Script" phase in the Xgrid FUSE target

# This is the original script developed by John Gruber: thanks!
# Markdown script buried in Textmate package
my $markdown_script_path = "/Applications/TextMate.app/Contents/SharedSupport/Support/bin/Markdown.pl";

#generate partial html corresponding to the markdown file
my $readme_markdown_path = "README.markdown";
my $readme_markdown_translated = `$markdown_script_path $readme_markdown_path`;


#used below to extract header and footer in template html files where the markdown-translated html should be inserted
my $header_footer_regex = "^(.*Begin markdown contents -->).*(<!-- End markdown contents.*)\$";

#replace contents in the appropriate sections of template 1 (for app documentation)
create_new_file_by_replacing_section_in_file (
	"README-template1.html", # path of the initial file
	$header_footer_regex, # regex to identify header and footer to keep in template
	$readme_markdown_translated, # string to introduce between header and footer
	"README.html" # path for the final file
	);


#picture names are located in a different path for the next 2 templates
$readme_markdown_translated =~ s/(readme-.*\.png)/XgridFUSE-readme\/$1/g;

#replace contents in the appropriate sections of template 2 (for web site)
create_new_file_by_replacing_section_in_file (
	"README-template2.html", # path of the initial file
	$header_footer_regex, # regex to identify header and footer to keep in template
	$readme_markdown_translated, # string to introduce between header and footer
	"SVN-IGNORE/XgridFUSE-info.html" # path for the final file
	);


#replace contents in the appropriate sections of template 3 (for sparkle info display)
create_new_file_by_replacing_section_in_file (
	"README-template3.html", # path of the initial file
	$header_footer_regex, # regex to identify header and footer to keep in template
	$readme_markdown_translated, # string to introduce between header and footer
	"SVN-IGNORE/xgridfuse-sparkle-info.html" # path for the final file
	);



exit 0;


sub create_new_file_by_replacing_section_in_file
{
	#all arguments
	my $initial_path = shift;
	my $header_footer_regex = shift;
	my $section_string = shift;
	my $final_path = shift;
	
	#replace section in the intial file with $section_string
	my $initial_string = slurp ( $initial_path );
	my ( $header , $footer ) = ( $initial_string =~ /$header_footer_regex/s );
	my $final_string = $header . "\n\n" . $section_string . "\n\n" . $footer;
	
	#final_html
	burp ( $final_path, $final_string);
	return $final_string;
}

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
	open OUTPUTFILE, ">$path" or return; #die "Could not open file $path for writing:\n$!";
	foreach ( @_ ) { print OUTPUTFILE $_; }
	close OUTPUTFILE or die "Could not close file $path\n$!";
}