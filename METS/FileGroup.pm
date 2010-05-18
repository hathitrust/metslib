#!/usr/bin/perl

package METS::FileGroup;
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

# Add a file group from a DOM element or a METS::FileGroup object.
sub add_file_group {
    my $self = shift;
    my $file = shift;
}

