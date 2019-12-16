#
#===============================================================================
#
#         FILE: Config.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/08/2019 10:14:44 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package App::Config;
use 5.010;
use Data::Dumper;

sub new {
    my $class = shift;
    my $file  = shift;
    my $info  = { file => $file };
    my $ConfigKey;

    die "没有参数:" unless $file;

    open Read, $file or die "没有文件： $file !!!!";

    while (<Read>) {
        if ( $_ =~ /\[(\w+)\]:/ ) {
            $ConfigKey = $1;
        }
        elsif ( $_ =~ /(\w+)=(.*)/ ) {
            $info->{$ConfigKey}->{$1} = $2;
        } 
        else {
            die "配置文件格式有错误 ！！！"
        }
    }

    bless $info, $class;
}

sub getInfo {
    my $self = shift;
    my $ConfigKey  = shift;

    if ( exists $self->{$ConfigKey} ) {
        return $self->{$ConfigKey};
    }
    else {
        say "$self->{file} 没有 $ConfigKey 配置！！！";
        return {};
    }

}

1
