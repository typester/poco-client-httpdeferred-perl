package POE::Component::Client::HTTPDeferred;
use Moose;

our $VERSION = '0.01';

use POE qw/
    Component::Client::HTTP
    Component::Client::HTTPDeferred::Deferred
    /;

has client_alias => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { 'ua' },
);

has session => (
    is  => 'rw',
    isa => 'POE::Session',
);

__PACKAGE__->meta->make_immutable;

=head1 NAME

POE::Component::Client::HTTPDeferred - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use POE::Component::Client::HTTPDeferred;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 METHODS

=head2 new

=cut

sub BUILD {
    my $self = shift;

    $self->{session} = POE::Session->create(
        object_states => [
            $self => {
                map { $_ => "poe_$_" } qw/_start request response/
            },
        ],
    );
}

=head2 request

=cut

sub request {
    my ($self, $req) = @_;

    my $d = $req->{_deferred} = POE::Component::Client::HTTPDeferred::Deferred->new(
        request      => $req,
        client_alias => $self->client_alias,
    );

    $poe_kernel->post( $self->session->ID => request => $req );

    $d;
}

=head2 shutdown

=cut

sub shutdown {
    my $self = shift;
    $poe_kernel->post( $self->client_alias => 'shutdown' );
}

=head1 POE METHODS

=head2 poe__start

=cut

sub poe__start {
    my ($self, $kernel) = @_[OBJECT, KERNEL];
    POE::Component::Client::HTTP->spawn( Alias => $self->client_alias );
}

=head2 poe_request

=cut

sub poe_request {
    my ($self, $kernel, $req) = @_[OBJECT, KERNEL, ARG0];

    $kernel->post( $self->client_alias, 'request', 'response', $req );
}

=head2 poe_response

=cut

sub poe_response {
    my ($self, $kernel) = @_[OBJECT, KERNEL];
    my ($req, $res)     = ($_[ARG0]->[0], $_[ARG1]->[0]);

    my $d = delete $req->{_deferred} or confess 'deferred object not found';

    if ($res->is_success) {
        $d->callback($res);
    }
    else {
        $d->errback($res);
    }
}

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
