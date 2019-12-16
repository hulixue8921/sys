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

package Model::Css;
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
    my $sql    = "select * from css";
    my $result = [];
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    return $result;
}

sub getnoorder {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $sql    = "select css.id , css.name from css where css.id not in (select css.id  from css , `order` where `order`.cssid=css.id);";
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
    my $sql    = "select distinct(css.name) from css left join `order` on css.id = `order`.cssid left join project on `order`.projectid = project.id left join r_p on project.id=r_p.projectid where `order`.id is null or project.id is null or r_p.roleid is null or  r_p.roleid !=1;";
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
    my $sql    = "select * from css where";
 
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
    my $sql    = "select * from css where";
 
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
    my $sql    = "delete from css where ";
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
    my $sth = $dbh->prepare("insert into css (name , binfa , arg) values (? ,? ,?)");
    $sth->execute( $values->[0] , $values->[1] , $values->[2]);
    return 0;
}

sub getnoorde {
    my $self   = shift;
    my $dbh    = $self->{dbh};
    my $result =[];
    my $sth = $dbh->prepare("select css.id , css.name from `order` , css where `order`.cssid ! = css.id");
    $sth->execute();
    
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    
    return $result;
}


1
