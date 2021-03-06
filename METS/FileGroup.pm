#!/usr/bin/perl

package METS::FileGroup;
use strict;
use Carp qw(croak);

use XML::LibXML;

sub new {
    my $class = shift;
    my %attrs = @_;
    return bless {
        components => [],
        attrs => METS::copyAttributes( \%attrs, qw(ID VERSDATE ADMID USE) ),
        prefix_count => {},
        fileids      => {},
	seq	     => 0 # counter for SEQ attribute
    }, $class;
}

sub get_file_id {
    my $self     = shift;
    my $filename = shift;

    my $id = $self->{'fileids'}{$filename};
    croak("File ID requested for unknown file $filename") unless $id;
    return $id;
}

# The given hash should map from filenames to their checksums.
sub set_checksum_cache {
    my $self = shift;
    my $checksums = shift;
    $self->{'checksum_cache'} = $checksums;
}

sub next_seq {
  my $self = shift;

  $self->{'seq'}++;
  return sprintf("%08d",$self->{'seq'});
}

sub assign_id {
  my $self = shift;
  my $prefix = shift;
  my $filename = shift;

  my $id = $self->get_next_id( $prefix );
  $self->{'fileids'}{$filename} = $id;
}

# Add a file from a DOM element or a METS::File object.
# Additional parameter 'path' gives temporary staging
# path to object.
sub add_file {
  my $self = shift;
  my $filename = shift;
  my %attrs = @_;

  if ( not defined $attrs{'id'} ) {
    $attrs{'id'} = $self->assign_id($attrs{'prefix'},$filename);
  }

  $attrs{seq} = $self->next_seq; 

  # path for staging.
  my $path = undef;
  if ( defined $attrs{'path'} ) {
      $path = $attrs{'path'};
      delete $attrs{'path'};
  }

  if ( defined $self->{'checksum_cache'} ) {
      my $checksum = $self->{'checksum_cache'}->get_checksum($filename);
      if ( defined $checksum ) {
          $attrs{'checksum'} = $checksum;
          $attrs{'checksumtype'}
              = $self->{'checksum_cache'}->get_checksum_type();
      }
  }

  my $file = new METS::File($self, %attrs);
  $file->set_local_file($filename,$path);
  push( @{ $self->{'components'} }, $file );
}

sub add_files {
    my $self      = shift;
    my $filenames = shift;
    my %attrs     = @_;

    foreach my $filename (@$filenames) {
        $self->add_file( $filename, %attrs );
    }
}

# Add a file group from a DOM element or a METS::FileGroup object.
sub add_file_group {
    my $self      = shift;
    my $filegroup = shift;
}

sub get_next_id {
    my $self   = shift;
    my $prefix = shift;
    $prefix = "" if not defined $prefix;

    $self->{'prefix_counts'}{$prefix} = 0
        if not defined $self->{'prefix_counts'}{$prefix};

    return $prefix . sprintf( "%08d", ++$self->{'prefix_counts'}{$prefix} );

}

sub to_node {
    my $self = shift;
    my $node = METS::createElement( "fileGrp", $self->{'attrs'} );
    foreach my $item ( @{ $self->{'components'} } ) {
        $node->appendChild( $item->to_node() );
    }
    return $node;

}
1;
