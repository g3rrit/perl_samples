#!/usr/bin/env perl

use feature ':5.10';
use IO::Socket::INET;
use Switch;

my $running = 1;
$SIG{INT} = sub { $running = 0 };

if ($#ARGV != 1) {
  say "usage: ./tcp ip port";
  exit;
}

$| = 1;

my $dst_ip   = $ARGV[0];
my $dst_port = $ARGV[1];

my $socket = new IO::Socket::INET (
  PeerHost => $dst_ip,
  PeerPort => $dst_port,
  Proto => 'tcp',
);
  
die "unable to connect to $dst_ip $dst_port" unless $socket;

say "connected -> ($dst_ip:$dst_port)";

my $pid = fork();
die if not defined $pid;
if (not $pid) {
  while ($running) {
    my $res = "";
    $socket->recv($res, 1);
    print "$res";
  }
  exit;
}

sub read_file {
  open my $fh, '<:raw', $_[0]
    or die "unable to open file $_[0]";

  my $cont ='';
  while (1) {
    my $success = read $fh, $cont, 100, length($cont);
    die $! if not defined $success;
    last if not $success;
  }
  close $fh; 
  return $cont
}

while ($running) {
  my $in = <STDIN>;

  my $val = substr $in, 3, -1;
  switch($in) {
    case /\:s / {
      $socket->send(substr $in, 3);
    }
    case /\:x / {
      $socket->send(pack "H*", $val);
    }
    case /\:f / {
      $socket->send(read_file($val));
    }
    case /\:h / {
      $socket->send(pack "H*", read_file($val));
    }

  }
}

wait();
$socket->close();
say "\ndisconnected";
