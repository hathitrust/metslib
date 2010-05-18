package METS::XLink;

# Sets xlink attributes. $xlink_attrs should be a dictionary with one or more
# of the following keys:
#
# href
# role
# arcrole
# title
# show
# actuate
# 
# Loctype specifies the locator type used in the xlink:href attribute.

sub set_xlink {
    my $self = shift;
    my $xlink_type = shift;
    my $loctype = shift;
    my $xlink_attrs = shift;

    my $allowed_loctype = qw(ARK URN URL PURL HANDLE DOI OTHER);
}
