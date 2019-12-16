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

package Model::Project;
use 5.010;
use utf8;

sub new {
    my $class = shift;
    my $dbh   = shift;
    bless { dbh => $dbh }, $class;
}

sub project_order {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "select p.id pid , p.name pname , o.id oid,o.name oname from (select project.id,project.name, r_p.roleid from project left join r_p on r_p.projectid=project.id where r_p.roleid = 0) as p left join `order` o on p.id=o.projectid where o.id is not null;";
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
    my $sql    = "select * from project";
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
    my $sql    = "select project.name from project left join r_p  on project.id=r_p.projectid where r_p.roleid =0;";
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
    my $sql    = "select * from project where";
 
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
    my $sql    = "select * from project where";
 
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
    my $sql    = "delete from project where ";
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
    my $sth = $dbh->prepare("insert into project (name) values (?)");
    $sth->execute( $values);
    return 0;
}


1
