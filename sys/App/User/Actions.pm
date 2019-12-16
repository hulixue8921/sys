#
#===============================================================================
#
#         FILE: Actions.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/26/2019 10:10:08 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package App::User::Actions;
use Model::User;
use Model::Role;
use Model::Project;
use Model::Css;
use Model::Order;
use POE;
use 5.010;
use utf8;
use App::User::RootActions;

use Data::Dumper;

our @ISA    = qw(Exporter);
our @EXPORT = qw(&reg &load &getProjects &getProject &getCss &doOrder);

sub reg {
    my $self  = shift;
    my $check = shift;

    return 0 unless ( $check->( $self->{info}, ['user'] ) );

    my $dbh = $self->{mysql}->get();

    my $user = Model::User->new($dbh);
    my $result = $user->filter( { 'name' => $self->{info}->{user} } );

    if ( $#$result eq '-1' ) {
        ## 注册开始
        $user->insert( [ $self->{info}->{user}, $self->{info}->{passwd} ] );
        $poe_kernel->yield( 'sent',
            { kind => 'info', info => 'reg success !!!' } );

        #添加用户缓存信息(conid , passwd , roleid)
        $self->{mem}->set(
            'user' . '-' . $self->{info}->{user},
            {
                conid  => $self->{conid},
                passwd => $self->{info}->{passwd},
                roleid => -1
            }
        );
    }
    else {
        $poe_kernel->yield(
            'sent',
            {
                kind => 'errorInfo',
                info => "$self->{info}->{user} have reg by other "
            }
        );
    }

    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub load {
    my $self  = shift;
    my $check = shift;
    return 0 unless ( $check->( $self->{info}, ['user'] ) );

    my $dbh = $self->{mysql}->get();
    if ( $self->{mem}->voteKey( 'user' . '-' . $self->{info}->{user} ) ) {
        my $passwd =
          $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{passwd};
        my $conid =
          $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{conid};
        if ( $passwd eq $self->{info}->{passwd} and $conid eq $self->{conid} ) {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info => 'load  repeat !!' } );
        }
        elsif ( $passwd eq $self->{info}->{passwd} ) {
            $poe_kernel->post(
                $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )
                  ->{conid},
                'sent',
                { kind => 'info', info => 'your are offline !!' }
            );
            $poe_kernel->yield( 'sent',
                { kind => 'info', info => '登录成功 !!' } );
            $self->{mem}->update( 'user' . '-' . $self->{info}->{user},
                { conid => $self->{conid} } );

        }
        elsif ( $conid eq $self->{conid} ) {
            $poe_kernel->yield(
                'sent',
                {
                    kind => 'info',
                    info => 'load repeat, and your passwd is error'
                }
            );
        }
        else {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info => 'user passwd is not  match !!' } );
        }

    }
    else {
        my $user   = Model::User->new($dbh);
        my $result = $user->filter(
            {
                name   => $self->{info}->{user},
                passwd => $self->{info}->{passwd}
            }
        );
        if ( $#$result eq '-1' ) {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info => ' user passwd is not  match !!' } );
            $self->{mysql}->put($dbh);
            $dbh->commit;
            return 0;
        }

        #验证通过 添加用户信息缓存(conid , passwd)
        $poe_kernel->yield( 'sent',
            { kind => 'info', info => '登录成功 !!' } );
        $self->{mem}->set(
            'user' . '-' . $self->{info}->{user},
            {
                conid  => $self->{conid},
                passwd => $self->{info}->{passwd},
                roleid => $result->[0]->{roleid}
            }
        );
    }

    $self->{mysql}->put($dbh);
    $dbh->commit;
}

sub getProjects {
    my $self       = shift;
    my $check      = shift;
    my $voteOnline = shift;

    return 0 unless $check->( $self->{info}, ['user'] );
    return 0 unless $voteOnline->($self);

    my $roleid =
      $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{roleid};

    if ( $self->{mem}->voteKey("role_$roleid-projects") ) {
        my $data = $self->{mem}->get("role_$roleid-projects")->{projects};
        $poe_kernel->yield( 'sent',
            { kind => 'data', data => $data, location => '1', action => 'add' }
        );
        return 1;
    }

    my $dbh    = $self->{mysql}->get();
    my $user   = Model::User->new($dbh);
    my $result = $user->getProject($roleid);

    $poe_kernel->yield(
        'sent',
        {
            kind     => 'data',
            location => '1',
            action   => 'add',
            data     => $result
        }
    );

    $self->{mem}->update( "role_$roleid-projects", { projects => $result } );
    $dbh->commit;
    $self->{mysql}->put($dbh);

}

sub getProject {
    my $self       = shift;
    my $check      = shift;
    my $voteOnline = shift;

    return 0 unless $check->( $self->{info}, [ 'user', 'pid' ] );
    return 0 unless $voteOnline->($self);

    my $pid = $self->{info}->{pid};

    my $roleid =
      $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{roleid};
    if ( $self->{mem}->voteKey("role_$roleid-project_$pid") ) {
        my $data = $self->{mem}->get("role_$roleid-project_$pid")->{orders};
        $poe_kernel->yield(
            'sent',
            {
                kind     => 'data',
                location => '2',
                action   => 'add',
                data     => $data,
                pid      => $pid
            }
        );
        return 1;
    }

    my $dbh    = $self->{mysql}->get();
    my $user   = Model::User->new($dbh);
    my $result = $user->getProjectOrder( $roleid, $pid );
    $poe_kernel->yield(
        'sent',
        {
            kind     => 'data',
            location => '2',
            action   => 'add',
            data     => $result,
            pid      => $pid
        }
    );

    $dbh->commit();
    $self->{mysql}->put($dbh);
    $self->{mem}->update( "role_$roleid-project_$pid", { orders => $result } );

}

sub getCss {
    my $self       = shift;
    my $check      = shift;
    my $voteOnline = shift;

    return 0 unless $check->( $self->{info}, [ 'user', 'pid', 'oid' ] );
    return 0 unless $voteOnline->($self);

    my $oid = $self->{info}->{oid};
    my $pid = $self->{info}->{pid};
    my $roleid =
      $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{roleid};

    if ( $self->{mem}->voteKey("role_$roleid-project_$pid-order_$oid") ) {
        my $data =
          $self->{mem}->get("role_$roleid-project_$pid-order_$oid")->{css};
        $poe_kernel->yield(
            'sent',
            {
                kind     => 'data',
                data     => $data,
                pid      => $pid,
                oid      => $oid,
                location => '3'
            }
        );
        return 1;
    }

    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $order   = Model::Order->new($dbh);
    my $css     = Model::Css->new($dbh);
    my $result  = $user->getCss( $roleid, $pid, $oid );
    my $rootcss = {};

    my $cssname = $result->[0]->{cssname};
    unless ( defined $cssname ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        $poe_kernel->yield( 'sent',
            { kind => 'info', info => '此命令没有样式' } );
        return 0;
    }

    $result->[0]->{title} = $cssname;

    if ( $cssname eq 'del-user' ) {
        $rootcss->{user}  = $user->ufilter( { roleid => 1 } );
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;

    }
    elsif ( $cssname eq 'user-to-role' ) {
        $rootcss->{user} = $user->filter( { roleid => -1 } );
        $rootcss->{role}  = $role->ufilter( { id => 1 } );
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    elsif ( $cssname eq 'user-x-role' ) {
        $rootcss->{user_role} = $user->user_role();
        $rootcss->{title}     = $cssname;
        $result->[0]          = $rootcss;
    }
    elsif ( $cssname eq 'del-role' ) {
        $rootcss->{role}  = $role->ufilter( { id => 1 } );
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    elsif ( $cssname eq 'add-role' ) {
    }
    elsif ( $cssname eq 'role-to-project' ) {
        $rootcss->{role}    = $role->ufilter( { id => 1 } );
        $rootcss->{project} = $project->ugetRoot();
        $rootcss->{title}   = $cssname;
        $result->[0]        = $rootcss;
    }
    elsif ( $cssname eq 'role-x-project' ) {
        $rootcss->{role_project} = $role->role_project();
        $rootcss->{title}        = $cssname;
        $result->[0]             = $rootcss;
    }
    elsif ( $cssname eq 'del-project' ) {
        $rootcss->{project} = $project->ugetRoot();
        $rootcss->{title}   = $cssname;
        $result->[0]        = $rootcss;
    }
    elsif ( $cssname eq 'add-project' ) {
    }
    elsif ( $cssname eq 'project-to-order' ) {
        $rootcss->{project} = $project->ugetRoot();
        $rootcss->{order}   = $order->filter( { projectid => 0 } );
        $rootcss->{title}   = $cssname;
        $result->[0]        = $rootcss;
    }
    elsif ( $cssname eq 'project-x-order' ) {
        $rootcss->{project_order} = $project->project_order();
        $rootcss->{title}         = $cssname;
        $result->[0]              = $rootcss;
    }
    elsif ( $cssname eq 'add-order' ) {
    }
    elsif ( $cssname eq 'del-order' ) {
        $rootcss->{order} = $order->ugetRoot();
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    elsif ( $cssname eq 'order-to-css' ) {
        $rootcss->{order} = $order->filter( { cssid => 0 } );
        $rootcss->{css}   = $css->getnoorder();
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    elsif ( $cssname eq 'order-x-css' ) {
        $rootcss->{order} = $order->order_css();
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    elsif ( $cssname eq 'add-css' ) {
    }
    elsif ( $cssname eq 'del-css' ) {
        $rootcss->{css}   = $css->ugetRoot();
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    elsif ( $cssname eq 'cleancache' ) {
        $rootcss->{cache} = $self->{mem}->orderkeys();
        $rootcss->{title} = $cssname;
        $result->[0]      = $rootcss;
    }
    else {
        $self->{mem}->update( "role_$roleid-project_$pid-order_$oid",
            { css => $result->[0] } );
    }

    $poe_kernel->yield(
        'sent',
        {
            kind     => 'data',
            data     => $result->[0],
            pid      => $pid,
            oid      => $oid,
            location => '3'
        }
    );

    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub doOrder {
    my $self       = shift;
    my $check      = shift;
    my $voteOnline = shift;

    return 0
      unless $check->( $self->{info},
        [ 'user', 'pid', 'oid', 'arg', 'title' ] );
    return 0 unless $voteOnline->($self);

    my $tab = {
        'del-user'         => \&duser,
        'user-to-role'     => \&uTrole,
        'user-x-role'      => \&uXrole,
        'del-role'         => \&dRole,
        'add-role'         => \&aRole,
        'role-to-project'  => \&rTproject,
        'role-x-project'   => \&rXproject,
        'del-project'      => \&dProject,
        'add-project'      => \&aProject,
        'project-to-order' => \&pTorder,
        'project-x-order'  => \&pXorder,
        'add-order'        => \&aOrder,
        'del-order'        => \&dOrder,
        'order-to-css'     => \&oTcss,
        'order-x-css'      => \&oXcss,
        'add-css'          => \&aCss,
        'del-css'          => \&dCss,
        'cleancache'       =>\&cleancache
    };

    my @tab = keys %$tab;
    ###管理员的专用指令执行
    if ( $self->{info}->{title} ~~ @tab ) {
        $tab->{ $self->{info}->{title} }->($self);
        return 0;
    }
    ##执行其他普通指令
    unless ( ref $self->{info}->{arg} eq 'ARRAY' ) {
        $poe_kernel->yield( 'sent',
            { kind => 'errorinfo', info => 'param: arg error' } );
        return 0;
    }

    my $oid = $self->{info}->{oid};
    my $pid = $self->{info}->{pid};
    my $roleid =
      $self->{mem}->get( 'user' . '-' . $self->{info}->{user} )->{roleid};

    my $dbh = $self->{mysql}->get();
    if ( $self->{mem}->voteKey("role_$roleid-project_$pid-order_$oid") ) {
        my $memcss =
          $self->{mem}->get("role_$roleid-project_$pid-order_$oid")->{css};
        my $order = Model::Order->new($dbh);
        my $oresult = $order->filter( { id => $oid } )->[0];
        $memcss->{path}      = $oresult->{path};
        $memcss->{ordername} = $oresult->{name};
        &sysdo( $self, $memcss );
        $dbh->commit;
        $self->{mysql}->put($dbh);
        return 1;
    }

    my $user = Model::User->new($dbh);
    my $css = $user->getCss( $roleid, $pid, $oid );

    if ( $css eq '0' ) {
        $poe_kernel->yield(
            'sent',
            {
                kind => 'info',
                info => '对不起， 你没有此命令权限 !!!'
            }
        );
        $dbh->commit;
        $self->{mysql}->put($dbh);
        return 0;
    }
    my $order = Model::Order->new($dbh);
    my $oresult = $order->filter( { id => $oid } )->[0];
    $css->{path}      = $oresult->{path};
    $css->{ordername} = $oresult->{name};

    &sysdo( $self, $css->[0] );
    $dbh->commit;
    $self->{mysql}->put($dbh);

}

sub sysdo {
    my $self = shift;
    my $css  = shift;
    
    Encode::_utf8_on($css->{ordername});

    my @mysqlCssArg = split( '-', $css->{arg} );
    my $infoArg = $self->{info}->{arg};

    unless ( $#$infoArg eq $#mysqlCssArg ) {
        $poe_kernel->yield( 'sent',
            { kind => 'info', info => '参数错误！！' } );
        return 0;
    }

    foreach my $arg (@$infoArg) {
        return 0 unless &voteValue($arg);
    }

    if ( $css->{binfa} eq '1' ) {
        ###不能并发执行的
        if ( $self->{mem}->voteKey( 'ordername' . '-' . $css->{ordername} ) ) {
            $poe_kernel->yield(
                'sent',
                {
                    kind => 'info',
                    info => "user:"
                      . $self->{mem}
                      ->get( 'ordername' . '-' . $css->{ordername} )->{user}
                      . " 正在执行，请耐心等待！！！"
                }
            );
            return 0;
        }
        else {
            #system("$css->{path} @$infoArg &");
            say("$css->{path} @$infoArg &");
            $poe_kernel->yield( 'sent',
                { kind => 'info', info => '指令正在执行当中 ！！！' } );
            $self->{mem}
              ->update( 'ordername' . '-' . $css->{ordername},
                { user => $self->{info}->{user} } );
        }
    }
    else {
        ####可以并发执行的
        if (
            $self->{mem}->voteKey(
                'ordername' . '-' . $css->{ordername} . join( ',', @$infoArg )
            )
          )
        {
            $poe_kernel->yield( 'sent',
                { kind => 'info', info => '请勿重复提交指令 ！！！' } );
            return 0;
        }
        else {
            # system("$css->{path} @$infoArg &");
            say("$css->{path} @$infoArg &");
            $self->{mem}->update(
                'ordername' . '-' . $css->{ordername} . join( ',', @$infoArg ),
                { user => $self->{info}->{user} }
            );

            $poe_kernel->yield( 'sent',
                { kind => 'info', info => '指令正在执行当中 ！！！' } );

        }

    }
}

1
