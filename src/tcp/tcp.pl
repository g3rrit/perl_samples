#!/usr/bin/env perl

use feature ':5.10';
use IO::Socket::INET;

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


$socket->close();
say "disconnected";
