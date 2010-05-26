package PREMIS::LinkingAgent;
use strict;
use PREMIS;

use XML::LibXML;

sub new {
    my $class = shift;
    my $type  = shift;
    my $value = shift;
    my $role  = shift;
    return bless {
        type  => $type,
        value => $value,
        role  => $role
    }, $class;
}

sub to_node {
    my $self = shift;

    my $node = PREMIS::createElement("linkingAgentIdentifier");
    $node->appendChild( PREMIS::createElement("linkingAgentIdentifierType"),
        $self->{'type'} );
    $node->appendChild( PREMIS::createElement("linkingAgentIdentifierValue"),
        $self->{'value'} );
    $node->appendChild( PREMIS::createElement("linkingAgentRole"),
        $self->{'role'} );

    return $node;
}
1;
