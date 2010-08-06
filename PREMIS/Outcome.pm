package PREMIS::Outcome;

use strict;

my $ns_HT = "http://www.hathitrust.org/premis_extension";
my $ns_prefix_HT = "HT";

sub new {
    my $class = shift;
    my $outcome = shift;
    return bless {
        outcome => $outcome,
	detail => []
    }, $class;
}

sub add_file_list_detail {
    my $self = shift;
    my $fail_message = shift;
    my $fail_type = shift;
    my $file_list = shift;

    my $node = PREMIS::createElement("eventOutcomeDetail");
    $node->appendChild( PREMIS::createElement("eventOutcomeDetailNote", $fail_message));

    my $ext_node = PREMIS::createElement("eventOutcomeDetailExtension");
    $node->appendChild($ext_node);
    my $filelist_node = new XML::LibXML::Element("fileList");
    $filelist_node->setNamespace($ns_HT,$ns_prefix_HT);
    $filelist_node->setAttribute("status",$fail_type);

    $ext_node->appendChild($filelist_node);

    foreach my $file (@$file_list) {
	my $file_node = new XML::LibXML::Element("file");
	$file_node->setNamespace( $ns_HT, $ns_prefix_HT);
	$file_node->appendText($file);
	$filelist_node->appendChild($file_node);
    }

    push(@{$self->{'detail'}},$node);
}

sub to_node {
    my $self = shift;
    my $node = PREMIS::createElement("eventOutcomeInformation");

    $node->appendChild( PREMIS::createElement("eventOutcome",$self->{'outcome'}));

    foreach my $detail (@{$self->{'detail'}}) {
	$node->appendChild($detail);
    }

    return $node;
}

1;
