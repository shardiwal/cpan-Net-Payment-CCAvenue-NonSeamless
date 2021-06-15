## Welcome to Net-Payment-CCAvenue-NonSeamless

CCAvenue billing page (Non-Seamless) - Avoid the hassle of developing and managing your own checkout page. Use the customizable billing page provided by CCAvenue which enables you to collect billing and shipping information of the customer.

CCAvenue integration document can be found here [Document](https://mars.ccavenue.com/downloads/CCAvenue_Integration%20_Ver_3_1.pdf).

### Installation

```
	perl Makefile.PL
	make
	make test
	make install

```

### Uses

```

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

    my $handle_response = Net::Payment::CCAvenue::NonSeamless::Response->new(
        encryption_key => 'xxxx',
        access_code => 'xxxx',
        merchant_id => 'xxxxx',
        order_no => 'Returned orderNo query param value',
        enc_response => 'Returned encResp query param value',
    );

    # Returns true if payment was success
    $handle_response->is_success();

```

### Support or Contact

Having trouble with this module? Check out perldoc Net::Payment::CCAvenue::NonSeamless or [contact support](rakesh.shardiwal@gmail.com) and i’ll help you sort it out.
