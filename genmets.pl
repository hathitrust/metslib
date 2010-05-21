#!/usr/bin/perl

use METS;
use strict;

chdir("sample");
my $mets = new METS( objid => "uc2.ark:/13960/t3rv0kf98" );

$mets->add_schema(
    "MARC",
    "http://www.loc.gov/MARC21/slim",
    "http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
);

my $header = new METS::Header(
    createdate   => "2010-04-30T23:41:22",
    recordstatus => "NEW"
);

$header->add_agent(
    role => 'CREATOR',
    type => 'ORGANIZATION',
    name => 'DLPS'
);

$header->add_alt_record_id( 'ia.londonspybookoft00burk',
    type => 'IAidentifier' );

$mets->set_header($header);

my $dmdSec = new METS::MetadataSection( 'dmdSec', id => "DMD1" );
$dmdSec->set_md_ref(
    mdtype       => "MARC",
    loctype      => "OTHER",
    otherloctype => "Item ID stored as second call number in item record",
    xptr         => "uc2.ark:/13960/t3rv0kf98"
);

$mets->add_dmd_sec($dmdSec);

$dmdSec = new METS::MetadataSection( 'dmdSec', id => "DMD2" );
$dmdSec->set_xml_file(
    "marc.xml",
    mdtype => "MARC",
    label  => "IA MARC record"
);

$mets->add_dmd_sec($dmdSec);

# add files to checksum cache, if we have existing checksums..
#my $checksum_cache = new METS::ChecksumCache;
#foreach my $file (@somefiles) {
#    $checksum_cache->add_file($file,get_checksum($file));
#}

my $zip_filegroup = new METS::FileGroup( id => 'FG1', use => 'zip archive' );

#$filegroup->set_checksum_cache($checksum_cache);

$zip_filegroup->add_file(
    "ark+=13960=t3rv0kf98.zip",
    mimetype => 'application/zip',
    prefix   => 'ZIP'
);

$mets->add_filegroup($zip_filegroup);

my $img_filegroup = new METS::FileGroup( id => 'FG2', use => 'image' );

#$filegroup->set_checksum_cache($checksum_cache);
$img_filegroup->add_files(
    [ glob("*.jp2") ],
    mimetype => 'image/jp2',
    prefix   => 'IMG'
);

$mets->add_filegroup($img_filegroup);

my $ocr_filegroup = new METS::FileGroup( id => 'FG3', use => 'ocr' );

#$filegroup->set_checksum_cache($checksum_cache);
$ocr_filegroup->add_files(
    [ glob("*.txt") ],
    mimetype => 'text/plain',
    prefix   => 'TXT'
);

$mets->add_filegroup($ocr_filegroup);

my $xml_filegroup = new METS::FileGroup( id => 'FG4', use => 'coordOCR' );

#$filegroup->set_checksum_cache($checksum_cache);
$xml_filegroup->add_files(
    [ glob("0*.xml") ],
    mimetype => 'text/xml',
    prefix   => 'XML'
);
$mets->add_filegroup($xml_filegroup);

my $struct_map = new METS::StructMap;
my $voldiv = new METS::StructMap::Div( type => 'volume' );
$struct_map->add_div($voldiv);
for ( my $i = 1; $i <= 10; $i++ ) {
    my $imgnum = sprintf( "%08d", $i );
    my $pagediv = $voldiv->add_file_div(
        [   $img_filegroup->get_file_id("$imgnum.jp2"),
            $ocr_filegroup->get_file_id("$imgnum.txt"),
            $xml_filegroup->get_file_id("$imgnum.xml")
        ],
        order => $i,
        type  => "page",
        label => "PAGETAG"
    );
}

$mets->add_struct_map($struct_map);

print $mets->to_node()->toString(1);

