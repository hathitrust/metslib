#!/usr/bin/perl

package METS::Header;
use METS;
use strict;

sub new {
    my $class = shift;
    my %attrs = @_;

    return bless {
        attrs => METS::copyAttributes(
            \%attrs, qw(ID ADMID CREATEDATE LASTMODDATE RECORDSTATUS)
        ),
        agents            => [],
        alt_record_ids    => [],
        mets_document_ids => undef
    }, $class;
}

sub set_attributes {
    my $self = shift;

}

# Adds an agent to the header
sub add_agent {
    my $self  = shift;
    my %attrs = @_;

    my $name  = $attrs{'name'};
    my $notes = $attrs{'notes'};

    METS::checkAttrVal( $attrs{'type'}, @METS::allowed_AGENT_TYPE );
    METS::checkAttrVal( $attrs{'role'}, @METS::allowed_AGENT_ROLE );

    my $agent_node = METS::createElement( "agent",
        METS::copyAttributes( \%attrs, qw(ID ROLE OTHERROLE TYPE OTHERTYPE) )
    );

    if ( defined $name ) {
        my $name_node = METS::createElement( "name", undef, $name );
        $agent_node->appendChild($name_node);
    }

    if ( defined $notes ) {
        foreach my $note (@$notes) {
            my $note_node = METS::createElement( "note", undef, $note );
            $agent_node->appendChild($note_node);
        }
    }

    push( @{ $self->{'agents'} }, $agent_node );
}

# Adds an alternate record ID, will be added to the header
sub add_alt_record_id {
    my $self          = shift;
    my $alt_record_id = shift;
    my %attrs         = ();

    push(
        @{ $self->{'alt_record_ids'} },
        METS::createElement(
            "altRecordID", METS::copyAttributes( \%attrs, qw(ID TYPE) ),
            $alt_record_id
        )
    );
}

# Sets the METS document ID, goes in the header.
sub set_mets_document_id {
    my $self        = shift;
    my $document_id = shift;
    my $id          = shift;
    my $type        = shift;

    $self->{'mets_document_id'} = METS::createElement(
        "metsDocumentID",
        {   "ID"   => $id,
            "TYPE" => $type
        },
        $document_id
    );
}

# Returns the metsHdr element
sub to_node {
    my $self = shift;

    #    my $output_node = $self->{'node'}->cloneNode(1);
    my $node = METS::createElement( "metsHdr", $self->{'attrs'} );

    foreach my $agent_node ( @{ $self->{'agents'} } ) {
        $node->appendChild($agent_node);
    }

    foreach my $alt_record_id ( @{ $self->{'alt_record_ids'} } ) {
        $node->appendChild($alt_record_id);
    }

    $node->appendChild( $self->{'mets_document_id'} )
        if defined $self->{'mets_document_id'};

    return $node;
}

1;
