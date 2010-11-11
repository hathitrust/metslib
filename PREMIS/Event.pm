package PREMIS::Event;
use strict;
use PREMIS;
use PREMIS::LinkingAgent;

use XML::LibXML;

sub new {
    my $class    = shift;
    my $id       = shift;
    my $idtype   = shift;
    my $eventtype     = shift;
    my $datetime = shift;
    my $detail   = shift;
    my $self     = bless {
        agents     => [],
        event_type => $eventtype,
        datetime   => $datetime,
        detail     => $detail,

    }, $class;

    $self->set_identifier( $idtype, $id );
    return $self;
}

sub set_identifier {
    my $self  = shift;
    my $type  = shift;
    my $value = shift;

    my $node = PREMIS::createElement("eventIdentifier");
    $node->appendChild( PREMIS::createElement("eventIdentifierType", $type));
    $node->appendChild( PREMIS::createElement("eventIdentifierValue", $value));

    $self->{'identifier'} = $node;

}

sub to_node {
    my $self = shift;

    my $node = PREMIS::createElement("event");
    $node->appendChild( $self->{'identifier'} ) if(defined $self->{'identifier'});
    $node->appendChild(
        PREMIS::createElement( "eventType", $self->{'event_type'} ) );
    $node->appendChild(
        PREMIS::createElement( "eventDateTime", $self->{'datetime'} ) );
    $node->appendChild(
        PREMIS::createElement( "eventDetail", $self->{'detail'} ) );

    foreach my $event_outcome (@{$self->{'outcomes'}}) {
	$node->appendChild(PREMIS::objectOrNodeToNode($event_outcome));
    }

    foreach my $agent ( @{ $self->{'agents'} } ) {
        $node->appendChild( PREMIS::objectOrNodeToNode($agent) );
    }

    return $node;
}

sub add_linking_agent {
    my $self = shift;

    my $agent = shift;

    push( @{ $self->{'agents'} }, $agent );
}

sub add_software_tool {
    my $self = shift;
    my $toolname = shift;

    push( @{ $self->{'agents'} }, new PREMIS::LinkingAgent("tool",$toolname,"software"));
}

sub add_outcome {
    my $self = shift;
    my $outcome = shift;

    push( @{$self->{'outcomes'} },$outcome);
}

1;
