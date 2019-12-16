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

package App::User::Sqls;
use POE;
use utf8;

our @ISA    = qw(Exporter);
our @EXPORT = qw(&initsql);

my $dbindb = 'ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;';

sub initsql {
    my $self  = shift;
    my $check = shift;

    return 0 unless $check->( $self->{info}, ['passwd'] );

    my $dbh = $self->{mysql}->get();
    $dbh->do(
"create table IF NOT EXISTS `user` (`id` int(11) NOT NULL AUTO_INCREMENT,name varchar(11) DEFAULT NULL,passwd varchar(41) DEFAULT NULL,roleid int(11) NOT NULL DEFAULT '-1', PRIMARY KEY (`id`),  UNIQUE KEY `uid`(`name`)) $dbindb "
    );
    $dbh->do(
"create table IF NOT EXISTS `role` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(11) DEFAULT NULL, PRIMARY KEY (`id`)) $dbindb "
    );
    $dbh->do(
"create table IF NOT EXISTS `project` (`id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(100) DEFAULT NULL,PRIMARY KEY (`id`)) $dbindb"
    );
    $dbh->do(
"create table IF NOT EXISTS `order` (`id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(100) DEFAULT NULL,`path` varchar(100) default null, `cssid` int(11) not null default '0', `projectid` int(11) not null default '0', PRIMARY KEY (`id`)) $dbindb"
    );
    $dbh->do(
"create table if not exists `css` (`id` int(11) not null auto_increment, `name` varchar(100) default null,`binfa` int(1) NOT NULL DEFAULT '0', `arg` varchar(100),PRIMARY KEY (`id`)) $dbindb"
    );
    $dbh->do(
"create table if not exists `r_p` (`id` int(11) not null auto_increment , `roleid` int(11),`projectid` int(11) , primary key(`id`)) $dbindb"
    );

    $dbh->prepare(
        "insert into user (name,passwd, roleid) values ('root', ? ,1);")
      ->execute( $self->{info}->{passwd} );

    $dbh->do("insert into role (id , name) values (1 ,'admin')");

    $dbh->do("insert into project (id , name) values (1 ,'用户管理')");
    $dbh->do("insert into project (id , name) values (2 ,'角色管理')");
    $dbh->do("insert into project (id , name) values (3 ,'项目管理')");
    $dbh->do("insert into project (id , name) values (4 ,'指令管理')");
    $dbh->do("insert into project (id , name) values (5 ,'指令样式管理')");
    $dbh->do("insert into project (id , name) values (6 ,'缓存管理')");

    $dbh->do(
        "insert into `order` ( projectid , name ,cssid) values ( 1, 'del-user' ,1)"
    );
    $dbh->do(
"insert into `order` ( projectid , name ,cssid) values ( 1, 'user-to-role' ,2)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values ( 1, 'user-x-role' ,3)"
    );

    $dbh->do(
        "insert into `order` ( projectid , name ,cssid) values (2, 'del-role' , 4)"
    );
    $dbh->do(
        "insert into `order` ( projectid , name, cssid) values (2, 'add-role',5)");
    $dbh->do(
"insert into `order` ( projectid , name, cssid) values (2, 'role-to-project' ,6)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (2, 'role-x-project' ,7)"
    );

    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (3, 'del-project' ,8)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (3, 'add-project' ,9)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (3, 'project-to-order' ,10)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (3, 'project-x-order',11)"
    );

    $dbh->do(
        "insert into `order` ( projectid , name,cssid) values (4, 'add-order',12)"
    );
    $dbh->do(
        "insert into `order` ( projectid , name,cssid) values (4, 'del-order',13)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (4, 'order-to-css' ,14)"
    );
    $dbh->do(
"insert into `order` ( projectid , name,cssid) values (4, 'order-x-css',15)"
    );

    $dbh->do(
        "insert into `order` ( projectid , name,cssid) values (5, 'add-css',16)");
    $dbh->do(
        "insert into `order` ( projectid , name,cssid) values (5, 'del-css',17)");
    $dbh->do(
        "insert into `order` ( projectid , name,cssid) values (6, '清除缓存',18)");

    $dbh->do("insert into `r_p` (roleid , projectid) values (1, 1)");
    $dbh->do("insert into `r_p` (roleid , projectid) values (1, 2)");
    $dbh->do("insert into `r_p` (roleid , projectid) values (1, 3)");
    $dbh->do("insert into `r_p` (roleid , projectid) values (1, 4)");
    $dbh->do("insert into `r_p` (roleid , projectid) values (1, 5)");
    $dbh->do("insert into `r_p` (roleid , projectid) values (1, 6)");
    
    $dbh->do("insert into css (name,id) values ('del-user' ,1)");
    $dbh->do("insert into css (name,id) values ('user-to-role',2)");
    $dbh->do("insert into css (name,id) values ('user-x-role',3)");
    $dbh->do("insert into css (name,id) values ('del-role',4)");
    $dbh->do("insert into css (name,id) values ('add-role',5)");
    $dbh->do("insert into css (name,id) values ('role-to-project',6)");
    $dbh->do("insert into css (name,id) values ('role-x-project',7)");
    $dbh->do("insert into css (name,id) values ('del-project',8)");
    $dbh->do("insert into css (name,id) values ('add-project',9)");
    $dbh->do("insert into css (name,id) values ('project-to-order',10)");
    $dbh->do("insert into css (name,id) values ('project-x-order',11)");
    $dbh->do("insert into css (name,id) values ('add-order',12)");
    $dbh->do("insert into css (name,id) values ('del-order',13)");
    $dbh->do("insert into css (name,id) values ('order-to-css',14)");
    $dbh->do("insert into css (name,id) values ('order-x-css',15)");
    $dbh->do("insert into css (name,id) values ('add-css',16)");
    $dbh->do("insert into css (name,id) values ('del-css',17)");
    $dbh->do("insert into css (name,id) values ('cleancache',18)");

    $self->{mysql}->put($dbh);
    $dbh->commit;

    $poe_kernel->yield( 'sent',
        { kind => 'initsql', info => 'init sql success !!' } );

}

1
