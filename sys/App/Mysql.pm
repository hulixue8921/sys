#
#===============================================================================
#
#         FILE: Mysql.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 11/11/2019 02:31:21 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package App::Mysql;
use 5.010;

sub new {
    my $class=shift;
    my $connId=shift;

    bless { connId=>'', cons=>[]  } , $class;

}

sub get {
    my $self=shift;
    return shift @{$self->{cons}};
}

sub put {
    my $self=shift;
    my $dbh=shift;
    push @{$self->{cons}}, $dbh; 

}

sub delete {
    my $self=shift;
    my $index=shift;
    splice @{$self->{cons}} ,$index ,1;
}

sub add {
    my $self=shift;
    my $conn=shift;
    push @{$self->{cons}}, $conn; 
}

sub addSession {
    my $self=shift;
    my $session=shift;
    $self->{connId}=$session;
}

1
 

