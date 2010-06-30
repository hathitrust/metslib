package PREMIS;
use strict;

use XML::LibXML;
use PREMIS::Object;
use PREMIS::Event;
use PREMIS::LinkingAgent;
use PREMIS::Outcome;

my $ns_PREMIS        = "info:lc/xmlns/premis-v2";
my $ns_prefix_PREMIS = "PREMIS";
my $schema_PREMIS    = "http://www.loc.gov/standards/mets/mets.xsd";

sub new {
    my $class = shift;
    return bless {
        objects => [],
        events  => [],
    }, $class;
}

# Return the PREMIS node
sub to_node {
    my $self = shift;

    my $node = createElement( "premis");
    $node->setAttribute("version" => "2.0");

    foreach my $object ( @{ $self->{objects} } ) {
        $node->appendChild( objectOrNodeToNode($object) );
    }

    foreach my $event ( @{ $self->{events} } ) {
        $node->appendChild( objectOrNodeToNode($event) );
    }

    return $node;

}

# Creates the element in the PREMIS namespace with the given name and text.
sub createElement {
    my $name = shift;
    my $text = shift;

    my $node = new XML::LibXML::Element($name);
    $node->setNamespace( $ns_PREMIS, $ns_prefix_PREMIS );
    if ( defined $text and !ref($text) ) {
        $node->appendText($text);
    }
    return $node;
}

sub objectOrNodeToNode {
    my $thing = shift;

    if ( ref($thing) =~ /^XML::LibXML/ ) {
        return $thing;
    }
    else {
        return $thing->to_node();
    }
}

sub add_object {
    my $self = shift;
    my $object = shift;

    push(@{$self->{'objects'}},$object);
}
sub add_event {
    my $self = shift;
    my $event = shift;

    push(@{$self->{'events'}},$event);
}
