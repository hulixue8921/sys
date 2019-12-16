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
#      CREATED: 11/08/2019 10:15:37 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package App::User;
use 5.010;
use POE;
use utf8;
use Data::Dumper;
use App::User::Actions;
use App::User::Sqls;
use App::User::RootActions;

sub new {
    my $class = shift;
    my $id    = shift;
    my $mem   = shift;
    my $mysql = shift;
    my $info  = shift;
    my $data  = { conid => $id, mem => $mem, mysql => $mysql, info => $info };
    bless $data, $class;
}

sub check {
    my $info = shift;
    my $data = shift;
    ## 判定是否存在key
    foreach my $param (@$data) {
        unless ( exists $info->{$param} ) {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info =>__PACKAGE__. ' check paramas erros !!' } );
            return 0;
        }
    }

    ## 判定是否存在value
    foreach my $param (@$data) {
        unless ( defined $info->{$param} and $info->{$param} ) {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info =>__PACKAGE__. ' check paramas erros !!' } );
            return 0;
        }
    }
    return 1;
}

#检测是否登录验证过
sub voteOnline {
    my $self = shift;
    if ( $self->{mem}->voteKey('user'.'-'. $self->{info}->{user} ) ) {
        my $conid =
          $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{conid};
        unless ( $conid eq $self->{conid} ) {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info =>__PACKAGE__. ' please load first !!' } );
            return 0;
        }
    }
    else {
        $poe_kernel->yield( 'sent',
                { kind => 'info', info =>__PACKAGE__. ' please load first !!' } );
        return 0;
    }

    return 1;
}

sub P (&) {
    return $_[0];
}

sub control {
    my $self = shift;
    my $tab  = {
        'User-reg'  => P ( \&reg ),      #用户注册
        'User-load' => P ( \&load ),     # 用户登录
        'Sql-init'  => P ( \&initsql ),  # 初始化数据库
        'Projects-get'  => P ( \&getProjects ), #用户获取项目信息
        'Project-get'  => P ( \&getProject ),    #用户获取具项目中所有的指令
        'Order-get'  => P ( \&getCss ),    #用户执行指令前，需要获取指令的相关信息
        'Order-do'  => P ( \&doOrder ),    #用户执行指令
        #'Order-getadmin'  => P ( \&getOrderAdmin ),    #admin 执行管理指令前 需要获取的数据
    };
    return 0 unless &check( $self->{info}, [ 'obj', 'action' ] );
    return 0
      unless &check(
              $tab, [ $self->{info}->{obj} . '-' . $self->{info}->{action} ]
      );
    $tab->{ $self->{info}->{obj} . '-' . $self->{info}->{action} }
      ->( $self, \&check, \&voteOnline );
}

1
