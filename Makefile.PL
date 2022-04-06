use ExtUtils::MakeMaker;

WriteMakefile(
  NAME => 'METS',
  VERSION_FROM => 'lib/METS.pm',
  AUTHOR => 'Aaron Elkiss (aelkiss@umich.edu)',
  ABSTRACT => 'Metadata Encoding and Transmission Standard (METS) 1.x',
  PREREQ_PM => {
    'XML::LibXML' => '2',
    'URI::Escape' => '1.60'
  },
);
