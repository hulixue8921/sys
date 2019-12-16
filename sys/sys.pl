#!/usr/bin/env perl
#===============================================================================
#
#         FILE: 1.pl
#
#        USAGE: ./1.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/19/18 02:16:24
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Encode;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite Wheel::FollowTail);
use Socket qw (AF_INET inet_ntop);
use Data::Dumper;
use JSON;
use DBD::mysql;
use App::Config;
use App::User;
use App::Mem;
use App::Mysql;

my $config = App::Config->new( $ARGV[0] );
my $json   = JSON->new->utf8->allow_nonref;
my $mem    = App::Mem->new($config);
my $mysql  = App::Mysql->new();

####监听打印日志
POE::Session->create(
    inline_states => {
        _start => sub {
            $_[HEAP]{log} = POE::Wheel::FollowTail->new(
                Filename   => $config->{Log}->{LogFile},
                InputEvent => "getlog",
            );
        },
        getlog => sub {
            my $loginfo = $_[ARG0];
            if ( $mem->voteKey($loginfo) ) {
                my $username = $mem->get($loginfo)->{user};
                $poe_kernel->post(
                    $mem->get( 'user' . '-' . $username )->{conid},
                    'sent', { kind => 'info', info => "$loginfo 指令执行完毕！！" } );
                $mem->del($loginfo);
            }
            else {
                $mem->del($loginfo);
                return 0;
            }
        },
    },
);

########mysql session #####
POE::Session->create(
    inline_states => {
        _start    => \&MysqlConnect,
        mysqlping => \&MysqlPing,
    },

);

sub MysqlConnect {
    $mysql->addSession( $_[SESSION]->ID );
    my $dsn =
"DBI:mysql:database=$config->{Mysql}->{DB};host=$config->{Mysql}->{HostIp};port=$config->{Mysql}->{Port}";

    while ( $config->{Mysql}->{connects} > 0 ) {
        my $dbh = DBI->connect(
            $dsn,
            $config->{Mysql}->{UserName},
            $config->{Mysql}->{PassWord},
            { RaiseError => 0, AutoCommit => 0 }
        );
        $dbh->do("SET NAMES utf8");
        if ($dbh) {
            $mysql->add($dbh);
            $config->{Mysql}->{connects}--;
        }
    }

    $poe_kernel->alarm_add(
        mysqlping => time() + $config->{Mysql}->{reconnect} );
}

sub MysqlPing {
    ## 删除没用的数据库连接
    foreach my $i ( sort { $a < $b } ( 0 .. $#{ $mysql->{cons} } ) ) {
        my $r = eval { $mysql->{cons}->[$i]->ping };
        if ( $r and $r eq 1 ) {
        }
        else {
            $mysql->delete($i);
        }
    }

    if ( $#{ $mysql->{cons} } < 4 ) {
        $config->{Mysql}->{connects} = 4 - $#{ $mysql->{cons} };
        $poe_kernel->alarm_add(
            '_start' => time() + $config->{Mysql}->{reconnect} );
    }
    else {
        $poe_kernel->alarm_add(
            mysqlping => time() + $config->{Mysql}->{reconnect} );
    }
}

########mysql session #####

POE::Session->create(
    inline_states => {
        _start      => \&Listen,
        listen_fail => \&Listen_fail,
        connected   => \&Connected,
    },

);

sub Listen {
    my $port = POE::Wheel::SocketFactory->new(
        BindPort       => $config->{Sys}->{ListenPort},
        SocketProtocol => 'tcp',
        SuccessEvent   => 'connected',
        FailureEvent   => 'listen_fail',
        Reuse          => 'on',
    );
    $_[HEAP]{port} = $port;
}

sub Listen_fail {
    say "$config->{Sys}->{ListenPort}  启动失败 ！！！";
}

sub Connected {
    my $hand = $_[ARG0];

    my $peer_host = inet_ntop( AF_INET, $_[ARG1] );

    POE::Session->create(
        inline_states => {
            _start   => \&Bind_con,
            receve   => \&Receve,
            lose_con => \&Losecon,
            sent     => \&Sent,
            _stop    => \&Stop,
        },
        args => [$hand],
    );
}

sub Bind_con {
    my $hand = $_[ARG0];
    $_[HEAP]{hand} = $hand;
    $_[HEAP]{con}  = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "receve",
        ErrorEvent => "lose_con",
    );
}

sub Receve {

    #say $_[SESSION]->ID;
    my $data = $_[ARG0];
    Encode::_utf8_on($data);
    my $datajson = eval { $json->decode($data) };
    print "receve:";
    say $data;
    if ($datajson) {
        my $user = App::User->new( $_[SESSION]->ID, $mem, $mysql, $datajson );
        $user->control();
    }
    else {
        $poe_kernel->yield( 'sent',
            { kind => 'errorInfo', info => 'param is not json !!' } );
    }

}

sub enUtf8 {
    my $data   = shift;
    my $Father = shift;
    my $key    = shift;

    if ( ref $data eq 'HASH' ) {
        foreach my $key ( keys %$data ) {
            &enUtf8( $data->{$key}, $data, $key );
        }
    }
    elsif ( ref $data eq 'ARRAY' ) {
        foreach my $i ( 0 .. $#$data ) {
            &enUtf8( $data->[$i], $data, $i );
        }
    }
    else {
        if ( ref $Father eq 'HASH' ) {
            Encode::_utf8_on( $Father->{$key} );
        }
        elsif ( ref $Father eq 'ARRAY' ) {
            Encode::_utf8_on( $Father->[$key] );
        }
    }
}

sub Sent {
    my $data = $_[ARG0];
    chomp $data;
    &enUtf8( $data, {}, 0 );
    print "sent:";
    my $Data = $json->encode($data);
    say $Data;
    my $len = length($Data) + 2;
    $_[HEAP]{con}->put( pack( 'N', $len ) . $Data );
}

sub Losecon {
    $poe_kernel->yield('_stop');
}

sub Stop {
    delete $_[HEAP]{con};
    delete $_[HEAP]{hand};
}

$poe_kernel->run;

