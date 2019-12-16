#
#===============================================================================
#
#         FILE: Mem.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/11/2019 10:40:19 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package App::Mem;
use 5.010;

sub new {
    my $class  = shift;
    my $config = shift;
    my $self   = { config => $config };
    bless $self, $class;
}

sub cleanRight {
    my $self=shift;
    foreach my $key (keys %$self) {
        if ( $key =~ /^role_/) {
            $self->del($key);
        } 
    } 

}

sub orderkeys {
    my $self=shift;
    my $result=[];
    foreach my $key (keys %$self) {
        if ( $key =~ /^ordername-/) {
            push @$result, $key; 
        }
    }
    return $result;
}

sub set {
    my $self  = shift;
    my $key   = shift;
    my $value = shift;
    Encode::_utf8_on($key);
    say "开始设置缓存 $key  $value ！！";
    $self->{$key} = $value;
}

sub get {
    my $self = shift;
    my $key  = shift;
    say "开始返回缓存 $key ！！";
    return $self->{$key};
}

sub keys {
    my $self   = shift;
    my @result = keys %$self;
    say "开始返回所有的key ！！";
    return \@result;
}

sub voteKey {
    my $self = shift;
    my $key  = shift;
    return 0 unless $key;
    unless ( exists $self->{$key} ) {
        return 0;
    }
    else {
        return 1;
    }
}

sub del {
    my $self = shift;
    my $key  = shift;
    return 0 unless $key;
    delete $self->{$key};
}

sub update {
    my $self = shift;
    my $key  = shift;
    my $info = shift;

    return 0 unless ref $info eq 'HASH';
    Encode::_utf8_on($key);
    while ( my ( $k, $v ) = each %$info ) {
        say "开始更新缓存 $key -  $k  - $v ！！";
        $self->{$key}->{$k} = $v;
    }
    return 1;
}

1

