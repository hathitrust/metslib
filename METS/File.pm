package METS::File;
use strict;

use XML::LibXML;

sub new {
    my $class = shift;
    my $id = shift;
    my $versdate = shift;
    my $admid = shift;
    my $use = shift;
    return bless {}, $class;
}

# Add a file from a DOM element or a METS::File object.
sub add_file {
    my $self = shift;
    my $file = shift;
}

sub set_filecore {
    my $self = shift;
    my $filecore = shift; # from METS::FileCore
}
 
# The file location element <FLocat> provides a pointer to the location
# of a content file. It uses the XLink reference syntax to provide linking
# information indicating the actual location of the content file, along with
# other attributes specifying additional linking information. NOTE:
# <FLocat> is an empty element. The location of the resource pointed to
# MUST be stored in the xlink:href attribute.
					
 
sub add_fLocat {
    my $self = shift;
    my $id = shift;
    my $use = shift;
    my $xlink = shift; # from METS::XLink
}

sub set_fContent {
    my $self = shift;
    my $data = shift; # from METS::Data
}

sub add_stream {
    # not supported now, add later if needed
}

sub add_transform_file {
    # not supported now, add later if needed
}

