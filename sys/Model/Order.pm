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

package Model::Order;
use 5.010;
use utf8;

sub new {
    my $class = shift;
    my $dbh   = shift;
    bless { dbh => $dbh }, $class;
}
sub order_css {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    ="select `order`.id as oid , `order`.name as oname , css.id as cid , css.name  as cname from `order` ,css where `order`.cssid = css.id and `order`.id in (select  o.id from `order` o left join project on o.projectid=project.id left join r_p on r_p.projectid = project.id where project.id is null or r_p.roleid is null or r_p.roleid != 1);";
    my $result = [];
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    return $result;
}

sub get {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "select * from `order`";
    my $result = [];
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    return $result;
}

sub ugetRoot {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "select distinct(`order`.name) from `order` left join project on `order`.projectid=project.id left join r_p on r_p.projectid = project.id where project.id is null  or r_p.roleid is null or r_p.roleid != 1;";
    my $result = [];
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    return $result;
}


sub ufilter {
    my $self   = shift;
    my $info   = shift;
    my $dbh    = $self->{dbh};
    my $result = [];
    my $sql    = "select * from `order` where";
 
    ## 检测传参
   return 0 unless ref $info eq 'HASH';

    my $num = keys %$info;
    my $V   = [];

    while ( my ( $k, $v ) = each %$info ) {
        $num--;
        if ( $num eq 0 ) {
            $sql= $sql . " " . "$k != ?";
        }
        else {
            $sql= $sql . " " . "$k != ?  and";
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

sub filter {
    my $self   = shift;
    my $info   = shift;
    my $dbh    = $self->{dbh};
    my $result = [];
    my $sql    = "select * from `order` where";
 
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
    my $sql    = "delete from `order` where ";
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
    my $update = shift;
    my $condition = shift;
    my $dbh    = $self->{dbh};
    my $sth = $dbh->prepare(" update `order` set $update->[0]= ? where $condition->[0] = ? ;");
    $sth->execute( $update->[1], $condition->[1] );
}

sub insert {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $values = shift;
    my $sth = $dbh->prepare("insert into `order` (name , path) values (?, ?)");
    $sth->execute( $values->[0] , $values->[1]);
    return 0;
}


1
