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

package Model::User;
use 5.010;
use utf8;

sub new {
    my $class = shift;
    my $dbh   = shift;
    bless { dbh => $dbh }, $class;
}


sub get {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "select * from user";
    my $result = [];
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    return $result;
}

sub user_role {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "select user.id as uid ,user.name as uname ,role.id as rid ,role.name as rname from user,role where user.roleid = role.id and role.id !=1 ;";
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
    my $sql    = "select * from user where";
 
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
    my $sql    = "select * from user where";
 
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
    my $sql    = "delete from user where ";
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
    my $sth = $dbh->prepare(" update user set $update->[0]= ? where $condition->[0] = ? ;");
    $sth->execute( $update->[1], $condition->[1] );
}

sub insert {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $values = shift;
    my $sth = $dbh->prepare("insert into user (name , passwd) values (? , ?)");
    $sth->execute( $values->[0], $values->[1] );
    return 0;
}

sub getProject {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $roleid =shift;
    my $result =[];
    unless (defined $roleid) {
        say  __PACKAGE__ . '-'. " fun : getProject  lose  roleid !!!";
        return 0;
    }

    my $sth=$dbh->prepare("select project.id , project.name from r_p ,project where r_p.projectid = project.id and r_p.roleid = ? ");
    $sth->execute($roleid);
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }

    return $result;


}


sub getProjectOrder {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $roleid =shift;
    my $projectid =shift;
    my $result =[];
    
    unless (defined $roleid and defined $projectid) {
        say  __PACKAGE__ . '-'. " fun : getProjectOrder  lose  roleid  or projectid !!!";
        return 0;
    }
    
    my $sth=$dbh->prepare("select o.id , o.name from r_p , project , `order` as o  where r_p.projectid = project.id and project.id =  o.projectid and r_p.roleid = ? and project.id = ?");
    $sth->execute($roleid, $projectid);
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    
    return $result;
}

sub getCss {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $rid =shift;
    my $pid =shift;
    my $oid =shift;
    my $result =[];
    
    unless (defined $rid and defined $pid and defined $oid) {
        say  __PACKAGE__ . '-'. " fun : getCss  lose  rid pid oid  !!!";
        return 0;
    }
    
    my $sth=$dbh->prepare("select o.path, css.binfa , css.arg, css.name as cssname  from r_p , project , `order` as o , css  where r_p.projectid = project.id and project.id =  o.projectid and o.cssid=css.id and r_p.roleid=? and project.id= ? and o.id = ?");
    $sth->execute($rid, $pid , $oid);
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    
    return $result;
}

1
