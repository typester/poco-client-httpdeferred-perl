package POE::Component::Client::HTTPDeferred::Deferred;
use Moose;

use POE;

has request => (
    is       => 'rw',
    isa      => 'HTTP::Request',
    weak_ref => 1,
    required => 1,
);

has client_alias => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has callbacks => (
    is      => 'rw',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub { [] },
);

__PACKAGE__->meta->make_immutable;

sub cancel {
    my $self = shift;
    $poe_kernel->post( $self->client_alias => cancel => $self->request );

    $self;
}

sub callback {
    my ($self, $res) = @_;

    for my $cb (@{ $self->callbacks }) {
        $cb->[0]->($res) if $cb->[0];
    }
}

sub errback {
    my ($self, $res) = @_;

    for my $cb (@{ $self->callbacks }) {
        $cb->[1]->($res) if $cb->[1];
    }
}

sub addBoth {
    my ($self, $cb) = @_;
    $self->addCallbacks($cb, $cb);
}

sub addCallback {
    my ($self, $cb) = @_;
    $self->addCallbacks($cb, undef);
}


sub addCallbacks {
    my ($self, $cb, $eb) = @_;
    push @{ $self->callbacks }, [ $cb, $eb ];

    $self;
}

sub addErrback {
    my ($self, $eb) = @_;
    $self->addCallbacks(undef, $eb);
}

1;
