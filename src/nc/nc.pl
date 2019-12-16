#!/usr/bin/env perl

use feature ':5.10';
use IO::Socket::INET;

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

sub parse_input {
  my $in = $_[0];
  if ($in =~ m/:s/) {
    return substr($in, 2, length $in);
  }
}

while ($running) {
  my $in = <STDIN>;
  $socket->send($in);
}

wait();
$socket->close();
say "\ndisconnected";
