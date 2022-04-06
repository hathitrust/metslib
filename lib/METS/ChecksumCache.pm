#!/usr/bin/perl

package METS::ChecksumCache;

sub new {
    my $class = shift;
    my $type = shift;
    my $files = shift;

    return bless {
	type => $type,
	files => $files
    }, $class;
}

sub get_checksum {
    my $self = shift;
    my $filename = shift;
    return $self->{'files'}{$filename};
}

sub get_checksum_type {
    return $self->{'type'};
}

1;

