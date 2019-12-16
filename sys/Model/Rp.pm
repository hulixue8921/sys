#
#===============================================================================
#
#         FILE: User.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/22/2019 11:02:14 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Model::Rp;
use 5.010;
use utf8;

sub new {
    my $class = shift;
    my $dbh   = shift;

    bless { dbh => $dbh }, $class;
}

sub filter {
    my $self   = shift;
    my $info   = shift;
    my $dbh    = $self->{dbh};
    my $result = [];
    my $sql    = "select * from r_p where";
 
    ## 检测传参
   return 0 unless ref $info eq 'HASH';

    my $num = keys %$info;
    my $V   = [];

    while ( my ( $k, $v ) = each %$info ) {
        $num--;
        if ( $num eq 0 ) {
            $sql= $sql . " " . "$k = ?";
        }
        else {
            $sql= $sql . " " . "$k = ?  and";
        }

        push @$V, $v;
    }

    my $sth = $dbh->prepare($sql);
    $sth->execute(@$V);

    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    return $result;
}

sub del {
    my $self   = shift;
    my $condition = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "delete from r_p where ";
    return 0 unless ref $condition eq 'HASH';
    my $num = keys %$condition;
    my $V   = [];
    while ( my ( $k, $v ) = each %$condition ) {
        $num--;
        if ( $num eq 0 ) {
            $sql= $sql . " " . "$k = ?";
        }
        else {
            $sql= $sql . " " . "$k = ?  and";
        }

        push @$V, $v;
    }
    my $sth = $dbh->prepare($sql);
    $sth->execute(@$V);
    return 1;
}

sub update {
    my $self = shift;
}

sub insert {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $values = shift;
    my $sth = $dbh->prepare("insert into r_p (roleid, projectid) values ( ? ,?)");
    $sth->execute( $values->[0] , $values->[1]);
    return 0;
}

1
