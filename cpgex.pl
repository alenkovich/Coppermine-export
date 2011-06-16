#!/usr/bin/perl

use strict;
use DBI();



### LOCAL settings ###

my $dbHost = 'localhost';
my $dbName = 'foto';
my $dbUser = 'foto';
my $dbPass = '******';

my $dbTablePrefix = 'cpg132_';

my $srcAlbumsPath = '/storage/galerija/albums/';
my $dstAlbumsPath = '/storage/DAV/library_archive/tmp/albums/';

### LOCAL settings END ###



my $dsn = "DBI:mysql:database=" . $dbName . ";host=" . $dbHost;

my $dbh = DBI->connect($dsn, $dbUser, $dbPass, {'RaiseError' => 1});

my $sqlQuery = "select * from " . $dbTablePrefix. "albums;";

my $uni = $dbh->prepare("set names utf8;");
my $sth = $dbh->prepare($sqlQuery);

$uni->execute();
$sth->execute();


while (my $ref = $sth->fetchrow_hashref()) {

        my $dstAlbumDir = $dstAlbumsPath . $ref->{'title'};
        my $mkdir = "mkdir '" . $dstAlbumDir . "'";
        print $mkdir . "\n";
        system($mkdir);

        my $sqlQueryPic = "select * from " . $dbTablePrefix . "pictures where aid=" . $ref->{'aid'};
        my $sthPic = $dbh->prepare($sqlQueryPic);
        $sthPic->execute();
        while (my $refPic = $sthPic->fetchrow_hashref()) {
                my $picture =  $srcAlbumsPath . $refPic->{'filepath'} . $refPic->{'filename'};
                my $cp = "cp '" . $picture . "' '" . $dstAlbumDir . "'";
                print $cp . "\n";
                system($cp);
        }
        $sthPic->finish();
}

$sth->finish();

$dbh->disconnect();
