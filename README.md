# README

## About

I created this package about 4 years ago when I was building a lot of custom IRC bots. Several bots
idled inside channels which used Blowfish to encrypt their communication. I am opensourcing it, hopefully
somebody has some use for it.

The code was reverse engineered from several C and Perl applications. I sadly do not remember which ones. 

## Usage

    # package
    use Blowfish;

    # encrypt
    my $encrypted = Blowfish::encrypt('this is plaintext', 'secret_key');
    	
    # decrypt
    my $decrypted = Blowfish::decrypt($encrypted, 'secret_key');
    
    # prints 'hwwnV0UVbDE1z2N0E0AZlBT/Mi965/OLpHf/'
    print $encrypted ."\n";
    	
    # prints 'this is plaintext'
    print $decrypted ."\n";
	
## IRC usage

To be able to use it inside a IRC channel, you need to prefix the encrypted string with `+OK`.

    # send to irc channel
    print $ircSocket 'PRIVMSG #channel :+OK'. $encrypted;