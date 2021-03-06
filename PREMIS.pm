package PREMIS;
use strict;

use XML::LibXML;
use PREMIS::Object;
use PREMIS::Event;
use PREMIS::LinkingAgent;
use PREMIS::Outcome;
use Carp qw(croak);

my $ns_PREMIS        = "info:lc/xmlns/premis-v2";
my $ns_prefix_PREMIS = "PREMIS";
my $schema_PREMIS    = "http://www.loc.gov/standards/mets/mets.xsd";

sub new {
    my $class = shift;
    return bless {
        objects => [],
        events  => {},
    }, $class;
}

sub sort_date {
    my ($date1,$date2);

    if(ref($a) eq 'XML::LibXML::Element') {
        $date1 = ( $a->getChildrenByTagNameNS($ns_PREMIS,"eventDateTime") )[0]->textContent();
    }
    if(ref($b) eq 'XML::LibXML::Element') {
        $date2 = ( $b->getChildrenByTagNameNS($ns_PREMIS,"eventDateTime") )[0]->textContent();
    }
    $date1 = $a->{datetime} if($a->isa("PREMIS::Event") and exists $a->{datetime}) ;
    $date2 = $b->{datetime} if($b->isa("PREMIS::Event") and exists $b->{datetime}) ;

    if(not defined $date1 or not defined $date2) {
        croak("Missing date for PREMIS event");
    }
    return $date1 cmp $date2;
}

# Return the PREMIS node
sub to_node {
    my $self = shift;

    my $node = createElement( "premis");
    $node->setAttribute("version" => "2.0");

    foreach my $object ( @{ $self->{objects} } ) {
        $node->appendChild( objectOrNodeToNode($object) );
    }

    # sort events by date before adding
    foreach my $event ( sort sort_date values %{ $self->{events} } ) {
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

    my $eventid;
    if($event->isa('PREMIS::Event')) {
      $eventid = $event->{'identifier'};
    } elsif($event->isa('XML::LibXML::Element')) {
      $eventid = ($event->getChildrenByTagNameNS($ns_PREMIS,'eventIdentifier'))[0];
    } else {
      die("Missing eventid") if not defined $eventid;
    }
    my $eventidvalue = ($eventid->getChildrenByTagNameNS($ns_PREMIS,'eventIdentifierValue'))[0]->textContent();
    die("Missing eventid") if not defined $eventidvalue;

    $self->{'events'}{$eventidvalue} = $event;
}
