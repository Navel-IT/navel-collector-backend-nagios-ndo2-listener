# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-collector-backend-nagios-ndo2-listener is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> initialization

package Navel::Collector::Backend::Nagios::NDO2::Listener 0.1;

use Navel::Base;

use constant EVENT_CLASS => undef;

use AnyEvent::Socket;
use AnyEvent::Handle;

use Protocol::Nagios::NDO2;

use Navel::Logger::Message;

#-> class variables

my ($server, %handles);

#-> functions

sub new_server {
    $server = tcp_server(
        W::collector()->{backend_input}->{address},
        W::collector()->{backend_input}->{port},
        sub {
            my ($filehandle, $host, $port) = @_;

            my $from = $host . ':' . $port;

            $handles{$filehandle} = AnyEvent::Handle->new(
                fh => $filehandle,
                keepalive => 1,
                W::collector()->{backend_input}->{tls} ? (
                    tls => 'accept',
                    tls_ctx => W::collector()->{backend_input}->{tls_ctx}
                ) : (),
                on_error => sub {
                    my ($handle, $fatal, $message) = @_;

                    if ($fatal) {
                        W::log(
                            [
                                'err',
                                Navel::Logger::Message->stepped_message($from . ': savage disconnection.',
                                    [
                                        $message
                                    ]
                                )
                            ]
                        );

                        delete $handles{$filehandle};
                    } else {
                        W::log(
                            [
                                'warning',
                                $from . ': ' . $message
                            ]
                        );
                    }
                },
                on_eof => sub {
                    W::log(
                        [
                            'notice',
                            $from . ': disconnection.'
                        ]
                    );

                    delete $handles{$filehandle};
                }
            );

            $handles{$filehandle}->push_read(
                regex => qr/HELLO/,
                sub {
                    my $handle = shift;

                    local $@;

                    my $ndo2 = eval {
                        Protocol::Nagios::NDO2->new(delete $handle->{rbuf});
                    };

                    unless ($@) {
                        W::log(
                            [
                                'notice',
                                $from . ': hello.'
                            ]
                        );

                        $handle->on_read(
                            sub {
                                for (split "\n\n", delete shift->{rbuf}) {
                                    eval {
                                        my $data = $ndo2->decode_data($_);

                                        if ($data->{type} eq 'HOSTSTATUSDATA' || $data->{type} eq 'SERVICESTATUSDATA') {
                                            my %event = (
                                                time => int $data->{values}->{TIMESTAMP} + 0.5,
                                                id => $ndo2->{INSTANCENAME} . '/' . $data->{values}->{HOST},
                                                class => 'nagios_ndo_' . $data->{type},
                                                data => $data->{values}
                                            );

                                            $event{id} .= '/' . $data->{values}->{SERVICE} if $data->{type} eq 'SERVICESTATUSDATA';

                                            W::queue()->enqueue(W::event(%event));
                                        }
                                    };

                                    W::log(
                                        [
                                            'warning',
                                            $from . ': ' . $@
                                        ]
                                    ) if $@;
                                }
                            }
                        );
                    }
                }
            );
        }
    );
}

sub init {
    new_server;
}

sub enable {
    new_server unless defined $server;

    shift->(1);
}

sub disable {
    %handles = ();

    undef $server;

    shift->(1);
}

1;

#-> END

__END__

=pod

=encoding utf8

=head1 NAME

Navel::Collector::Backend::Nagios::NDO2::Listener

=head1 COPYRIGHT

Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras

=head1 LICENSE

navel-collector-backend-nagios-ndo2-listener is licensed under the Apache License, Version 2.0

=cut
