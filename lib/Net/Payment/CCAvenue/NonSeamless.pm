package Net::Payment::CCAvenue::NonSeamless;

use Moo;
extends 'Net::Payment::CCAvenue';

use URI;
use Crypt::Mode::CBC;
use CGI ( ':standard', '-no_debug', '-no_xhtml' );
use DateTime;
use JSON::XS;

=head1 NAME

Net::Payment::CCAvenue::NonSeamless - Processing orders using CCAvenue billing page!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    CCAvenue billing page (Non-Seamless) - Avoid the hassle of developing and managing your own checkout page. Use the customizable billing page provided by CCAvenue which enables you to collect billing and shipping information of the customer.

    use Net::Payment::CCAvenue::NonSeamless;

    my $foo = Net::Payment::CCAvenue::NonSeamless->new(
        encryption_key => 'xxxx',
        access_code => 'xxxx',
        merchant_id => 'xxxxx',
        currency => 'AED',
        amount => '3.00',
        redirect_url => 'http://example.com/order/success_or_fail',
        cancel_url => 'http://example.com/order/cancel',
    );
    
    # Get NonSeamless integration form
    $foo->payment_form();

    # Above method returns html form and your need to render this and click on pay button to start payment.

=cut

has aes_cipher => (
    is         => 'ro',
    isa        => 'Crypt::Mode::CBC',
    lazy_build => 1
);

sub _build_aes_cipher {
    my ($self) = @_;
    return Crypt::Mode::CBC->new( 'AES', 1 );
}

has init_vector => (
    is      => 'ro',
    isa     => 'Str',
    default => sub {
        return pack( "C*",
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
            0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f );
    }
);

has [qw(request_type response_type)] => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { return 'JSON' },
);

has request_version => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { return '1.1' },
);

has order_id => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

sub _build_order_id {
    my ($self) = @_;
    my $dt = DateTime->now;
    my $merch_txn_ref = $dt->ymd('') . $dt->hms('') . $dt->millisecond() . $self->customer_email;
    return substr( $merch_txn_ref, 0, 24 );
}

has [qw(currency amount redirect_url cancel_url)] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has [qw(customer_email customer_name order_description extra_param1)] => (
    is  => 'ro',
    isa => 'Str',
);

has language => (
    is         => 'ro',
    isa        => 'Str',
    default    => sub { return 'en'; }
);

=head1 SUBROUTINES/METHODS

=head2 payment_form_data

Returns required parameter needed for payment gateway as query string format.

=cut

sub payment_form_data {
    my ($self)       = @_;
    my $url          = URI->new( '', 'http' );
    my $query_params = {
        'merchant_id'         => $self->merchant_id,
        'order_id'            => $self->order_id,
        'currency'            => $self->currency,
        'amount'              => $self->amount,
        'redirect_url'        => $self->redirect_url,
        'cancel_url'          => $self->cancel_url,
        'language'            => $self->language,
        'merchant_param1'     => $self->extra_param1,
        'response_type'       => $self->response_type,
        'customer_identifier' => $self->customer_email,
    };
    $url->query_form(%$query_params);
    return $url->query;
}

=head2 payment_form

Returns payment processing html form.

=cut

sub payment_form {
    my ($self) = @_;

    my $data = $self->payment_form_data();

    my $command = 'initiateTransaction';
    my $url     = $self->service_url;
    $url->query_form( 'command' => $command );

    my $form;
    $form .= start_form(
        -method => 'POST',
        -action => $url->as_string,
    );
    $form .= hidden(
        -name    => 'encRequest',
        -default => [ $self->encrypt_data($data) ]
    );
    $form .= hidden(
        -name    => 'access_code',
        -default => [ $self->access_code ]
    );
    $form .= hidden(
        -name    => 'command',
        -default => [$command]
    );
    $form .= hidden(
        -name    => 'request_type',
        -default => [ $self->request_type ]
    );
    $form .= hidden(
        -name    => 'response_type',
        -default => [ $self->response_type ]
    );
    $form .= hidden(
        -name    => 'version',
        -default => [ $self->request_version ]
    );
    $form .= submit(
        -name  => 'submit',
        -id    => 'paybutton',
        -value => 'Pay'
    );
    $form .= end_form;

    return $form;
}

=head2 encrypt_data

Data to be encrypted as 128 bit AES encryption.

=cut

sub encrypt_data {
    my ( $self, $data ) = @_;
    return unpack(
        'H*',
        $self->aes_cipher->encrypt(
            $data, $self->encryption_key_bin, $self->init_vector
        )
    );
}

=head2 decrypt_data

Decrypte the given encrypted data.

=cut

sub decrypt_data {
    my ( $self, $encrypted_data ) = @_;
    return $self->aes_cipher->decrypt(
        pack( 'H*', $encrypted_data ),
        $self->encryption_key_bin,
        $self->init_vector
    );
}

=head1 AUTHOR

Rakesh Kumar Shardiwal, C<< <rakesh.shardiwal at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-payment-ccavenue-nonseamless at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Payment-CCAvenue-NonSeamless>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Payment::CCAvenue::NonSeamless


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Payment-CCAvenue-NonSeamless>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Payment-CCAvenue-NonSeamless>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Payment-CCAvenue-NonSeamless>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Payment-CCAvenue-NonSeamless/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2021 Rakesh Kumar Shardiwal.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Net::Payment::CCAvenue::NonSeamless
