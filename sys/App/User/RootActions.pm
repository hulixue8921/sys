#
#===============================================================================
#
#         FILE: Sqls.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/26/2019 11:38:01 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package App::User::RootActions;
use Model::User;
use Model::Role;
use Model::Project;
use Model::Css;
use Model::Order;
use Model::Rp;
use 5.010;
use POE;
use Data::Dumper;
use utf8;
use POE;

our @ISA = qw(Exporter);
our @EXPORT =
  qw(&voteValue &duser &uTrole &uXrole &dRole &aRole &rTproject &rXproject &dProject &aProject &pTorder &pXorder &aOrder &dOrder &oTcss &oXcss  &aCss &dCss &cleancache);

sub voteValue {
    my $value = shift;
    if ( defined $value and $value or $value eq 0 ) {
        return 1;
    }
    else {
        $poe_kernel->yield( 'sent',
            { kind => 'info', info => '缺少值 或者传参数格式不对' }
        );
        return 0;
    }
}

sub duser {
    my $self = shift;
    my $data = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($data);
    my $dbh  = $self->{mysql}->get();
    my $user = Model::User->new($dbh);
    $user->del( { name => $data } );
    $dbh->commit();
    $self->{mysql}->put($dbh);

    if ( $self->{mem}->voteKey( "user" . '-' . $data ) ) {
        my $memData = $self->{mem}->get( "user" . '-' . $data );
        $self->{mem}->del( "user" . '-' . $data );
    }

}

sub uTrole {
    my $self   = shift;
    my $data_u = $self->{info}->{arg}->[0];
    my $data_r = $self->{info}->{arg}->[1];
    return 0 unless &voteValue($data_u);
    return 0 unless &voteValue($data_r);
    my $dbh  = $self->{mysql}->get();
    my $role = Model::Role->new($dbh);
    my $user = Model::User->new($dbh);

    my $uid = $user->filter( { name => $data_u } )->[0]->{id};
    my $rid = $role->filter( { name => $data_r } )->[0]->{id};

    unless ( defined $uid and defined $rid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    if ( $self->{mem}->voteKey( 'user' . '-' . $data_u ) ) {
        my $memData = $self->{mem}->get( 'user' . '-' . $data_u );
        $memData->{roleid} = $rid;
        my $result = $user->getProject($rid);
        $poe_kernel->post(
            $memData->{conid},
            'sent',
            {
                kind     => 'data',
                location => '1',
                action   => 'add',
                data     => $result
            }
        );
    }

    $user->update( [ "roleid", $rid ], [ 'id', $uid ] );
    $dbh->commit();
    $self->{mysql}->put($dbh);

}

sub uXrole {
    my $self = shift;
    my $data = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($data);
    my $dbh      = $self->{mysql}->get();
    my @data_do  = split( /-/, $data );
    my $username = $data_do[0];
    my $rolename = $data_do[1];

    my $user = Model::User->new($dbh);
    my $uid = $user->filter( { name => $username } )->[0]->{id};

    unless ( defined $uid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }

    $user->update( [ "roleid", -1 ], [ 'id', $uid ] );
    $dbh->commit();
    $self->{mysql}->put($dbh);

    if ( $self->{mem}->voteKey( 'user' . '-' . $username ) ) {
        my $memData = $self->{mem}->get( 'user' . '-' . $username );
        $memData->{roleid} = -1;
        $poe_kernel->post(
            $memData->{conid},
            'sent',
            {
                kind     => 'data',
                location => '1',
                action   => 'add',
                data     => [],
            }
        );
    }
}

sub dRole {
    my $self = shift;
    my $data = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($data);
    my $dbh = $self->{mysql}->get();

    my $role   = Model::Role->new($dbh);
    my $user   = Model::User->new($dbh);
    my $rp     = Model::Rp->new($dbh);
    my $roleid = $role->filter( { name => $data } )->[0]->{id};

    unless ( defined $roleid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    my $userRole = $user->filter( { roleid => $roleid } );

    foreach my $x (@$userRole) {
        my $username = $x->{name};
        my $userid   = $x->{id};
        $user->update( [ "roleid", -1 ], [ "id", $userid ] );
        if ( $self->{mem}->voteKey( "user" . '-' . $username ) ) {
            my $memdata = $self->{mem}->get( "user" . '-' . $username );
            $memdata->{roleid} = -1;
            $poe_kernel->post(
                $memdata->{conid},
                'sent',
                {
                    kind     => 'data',
                    location => '1',
                    action   => 'add',
                    data     => [],
                }
            );

        }

    }

    $self->{mem}->cleanRight();
    $role->del( { id => $roleid } );
    $rp->del( { roleid => $roleid } );
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub aRole {
    my $self     = shift;
    my $rolename = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($rolename);
    my $dbh  = $self->{mysql}->get();
    my $role = Model::Role->new($dbh);

    my $rid = $role->filter( { name => $rolename } )->[0]->{id};
    if ( defined $rid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }

    $role->insert($rolename);
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub rTproject {
    my $self        = shift;
    my $rolename    = $self->{info}->{arg}->[0];
    my $projectname = $self->{info}->{arg}->[1];
    return 0 unless &voteValue($rolename);
    return 0 unless &voteValue($projectname);
    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $r_p     = Model::Rp->new($dbh);

    my $rid = $role->filter( { name => $rolename } )->[0]->{id};
    my $pid = $project->filter( { name => $projectname } )->[0]->{id};

    unless ( defined $rid and defined $pid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }
    my $id = $r_p->filter( { roleid => $rid, projectid => $pid } );

    unless ( $#$id eq -1 ) {
        $poe_kernel->yield(
            'sent',
            {
                kind => 'info',
                info => "$rolename  $projectname 关联过 ！！！"
            }
        );
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }

    $r_p->insert( [ $rid, $pid ] );
    $self->{mem}->cleanRight();

    foreach my $u ( @{ $user->filter( { roleid => $rid } ) } ) {
        my $username = $u->{name};
        if ( $self->{mem}->voteKey( "user" . '-' . $username ) ) {
            my $memdata = $self->{mem}->get( "user" . '-' . $username );
            my $result  = $user->getProject($rid);
            $poe_kernel->post(
                $memdata->{conid},
                'sent',
                {
                    kind     => 'data',
                    location => '1',
                    action   => 'add',
                    data     => $result
                }
            );
        }
    }

    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub rXproject {
    my $self = shift;
    my $data = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($data);
    my @data_do     = split( /-/, $data );
    my $rolename    = $data_do[0];
    my $projectname = $data_do[1];
    return 0 unless &voteValue($rolename);
    return 0 unless &voteValue($projectname);
    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $r_p     = Model::Rp->new($dbh);

    my $rid = $role->filter( { name => $rolename } )->[0]->{id};
    my $pid = $project->filter( { name => $projectname } )->[0]->{id};

    unless ( defined $rid and defined $pid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }

    $r_p->del( { roleid => $rid, projectid => $pid } );
    $self->{mem}->cleanRight();
    foreach my $u ( @{ $user->filter( { roleid => $rid } ) } ) {
        my $username = $u->{name};
        if ( $self->{mem}->voteKey( "user" . '-' . $username ) ) {
            my $memdata = $self->{mem}->get( "user" . '-' . $username );
            my $result  = $user->getProject($rid);
            $poe_kernel->post(
                $memdata->{conid},
                'sent',
                {
                    kind     => 'data',
                    location => '1',
                    action   => 'add',
                    data     => $result
                }
            );

        }
    }

    $dbh->commit();
    $self->{mysql}->put($dbh);

}

sub dProject {
    my $self        = shift;
    my $projectname = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($projectname);
    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $r_p     = Model::Rp->new($dbh);
    my $order   = Model::Order->new($dbh);

    my $pid = $project->filter( { name => $projectname } )->[0]->{id};

    unless ( defined $pid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }

    my $rids = $r_p->filter( { projectid => $pid } );
    $r_p->del( { projectid => $pid } );
    $project->del( { id => $pid } );
    $order->update( [ 'projectid', 0 ], [ 'projectid', $pid ] );

    foreach my $r (@$rids) {
        my $rid = $r->{roleid};
        my $us = $user->filter( { roleid => $rid } );
        foreach my $u (@$us) {
            my $username = $u->{name};
            if ( $self->{mem}->voteKey( "user" . '-' . $username ) ) {
                my $memdata = $self->{mem}->get( "user" . '-' . $username );
                my $result  = $user->getProject($rid);
                $poe_kernel->post(
                    $memdata->{conid},
                    'sent',
                    {
                        kind     => 'data',
                        location => '1',
                        action   => 'add',
                        data     => $result
                    }
                );

            }
        }
    }

    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);

}

sub aProject {
    my $self        = shift;
    my $projectname = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($projectname);
    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $r_p     = Model::Rp->new($dbh);

    my $r = $project->filter( { name => $projectname } );
    unless ( $#$r eq -1 ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    $project->insert($projectname);
    my $pid = $project->filter( { name => $projectname } )->[0]->{id};
    $r_p->insert( [ 1, $pid ] );
    $r_p->insert( [ 0, $pid ] );

    my $result = $user->getProject(1);
    $poe_kernel->yield(
        'sent',
        {
            kind     => 'data',
            location => '1',
            action   => 'add',
            data     => $result
        }
    );

    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub pTorder {
    my $self        = shift;
    my $projectname = $self->{info}->{arg}->[0];
    my $ordername   = $self->{info}->{arg}->[1];
    return 0 unless &voteValue($projectname);
    return 0 unless &voteValue($ordername);
    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $order   = Model::Order->new($dbh);
    my $r_p     = Model::Rp->new($dbh);

    my $pid = $project->filter( { name => $projectname } )->[0]->{id};
    my $oid = $order->filter( { name => $ordername } )->[0]->{id};

    unless ( defined $pid and defined $oid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return;
    }

    $order->update( [ 'projectid', $pid ], [ 'id', $oid ] );
    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);

}

sub pXorder {
    my $self = shift;
    my $data = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($data);
    my @data_to     = split( /-/, $data );
    my $projectname = $data_to[0];
    my $ordername   = $data_to[1];
    return 0 unless &voteValue($projectname);
    return 0 unless &voteValue($ordername);
    my $dbh     = $self->{mysql}->get();
    my $user    = Model::User->new($dbh);
    my $role    = Model::Role->new($dbh);
    my $project = Model::Project->new($dbh);
    my $order   = Model::Order->new($dbh);
    my $r_p     = Model::Rp->new($dbh);

    my $pid = $project->filter( { name => $projectname } )->[0]->{id};

    unless ( defined $pid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }
    my $oid =
      $order->filter( { name => $ordername, projectid => $pid } )->[0]->{id};

    unless ( defined $oid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    $order->update( [ 'projectid', 0 ], [ 'id', $oid ] );

    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub aOrder {
    my $self      = shift;
    my $ordername = $self->{info}->{arg}->[0];
    my $path      = $self->{info}->{arg}->[1];
    return 0 unless &voteValue($ordername);
    return 0 unless &voteValue($path);
    my $dbh   = $self->{mysql}->get();
    my $order = Model::Order->new($dbh);
    my $oid   = $order->filter( { name => $ordername } )->[0]->{id};
    if ( defined $oid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        $poe_kernel->yield(
            'sent',
            {
                kind => 'info',
                info => '这个命令名字已经有了，请重新取名'
            }
        );
        return 0;
    }
    $order->insert( [ $ordername, $path ] );
    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub dOrder {
    my $self      = shift;
    my $ordername = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($ordername);
    my $dbh   = $self->{mysql}->get();
    my $order = Model::Order->new($dbh);
    my $oid   = $order->filter( { name => $ordername } )->[0]->{id};

    unless ( defined $oid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }
    $order->del( { id => $oid } );
    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub oTcss {
    my $self      = shift;
    my $ordername = $self->{info}->{arg}->[0];
    my $cssname   = $self->{info}->{arg}->[1];
    return 0 unless &voteValue($ordername);
    return 0 unless &voteValue($cssname);
    my $dbh   = $self->{mysql}->get();
    my $order = Model::Order->new($dbh);
    my $css   = Model::Css->new($dbh);

    my $oid = $order->filter( { name => $ordername } )->[0]->{id};
    my $cid = $css->filter( { name => $cssname } )->[0]->{id};

    unless ( defined $oid and defined $cid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }
    $order->update( [ 'cssid', $cid ], [ 'id', $oid ] );
    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub oXcss {
    my $self = shift;
    my $data = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($data);
    my @data_do   = split( /-/, $data );
    my $ordername = $data_do[0];
    my $cssname   = $data_do[1];
    return 0 unless &voteValue($ordername);
    return 0 unless &voteValue($cssname);

    my $dbh   = $self->{mysql}->get();
    my $order = Model::Order->new($dbh);
    my $css   = Model::Css->new($dbh);

    my $cid = $css->filter( { name => $cssname } )->[0]->{id};
    unless ( defined $cid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    my $oid =
      $order->filter( { name => $ordername, cssid => $cid } )->[0]->{id};
    unless ( defined $oid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    $order->update( [ 'cssid', 0 ], [ 'id', $oid ] );
    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);

}

sub aCss {
    my $self    = shift;
    my $cssname = $self->{info}->{arg}->[0];
    my $binfa   = $self->{info}->{arg}->[1];
    my $arg     = $self->{info}->{arg}->[2];
    return 0 unless &voteValue($cssname);
    return 0 unless &voteValue($binfa);
    return 0 unless &voteValue($arg);
    my $dbh = $self->{mysql}->get();
    my $css = Model::Css->new($dbh);

    my $cid = $css->filter( { name => $cssname } )->[0]->{id};

    if ( defined $cid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    $css->insert( [ $cssname, $binfa, $arg ] );

    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);

}

sub dCss {
    my $self    = shift;
    my $cssname = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($cssname);
    my $dbh   = $self->{mysql}->get();
    my $order = Model::Order->new($dbh);
    my $css   = Model::Css->new($dbh);

    my $cid = $css->filter( { name => $cssname } )->[0]->{id};
    unless ( defined $cid ) {
        $dbh->commit();
        $self->{mysql}->put($dbh);
        return 0;
    }

    $order->update( [ 'cssid', 0 ], [ 'cssid', $cid ] );
    $css->del( { id => $cid } );

    $self->{mem}->cleanRight();
    $dbh->commit();
    $self->{mysql}->put($dbh);
}

sub cleancache {
    my $self  = shift;
    my $cache = $self->{info}->{arg}->[0];
    return 0 unless &voteValue($cache);
    

    if ( $self->{mem}->voteKey($cache) ) {
        $poe_kernel->yield( 'sent',
            { kind => 'info', info => "$cache 清除成功！！！" } );
        my $user=$self->{mem}->get($cache)->{user};
        
        $poe_kernel->post(
            $self->{mem}->get( "user".'-'.$self->{mem}->get($cache)->{user} )->{conid},
            'sent', { kind => 'info', info => "$cache 异常中断" } );
        $self->{mem}->del($cache);
    }

}

1
