#!/usr/bin/perl
# Blowfish Package v1.0.1
#
# Encrypt or decrypt using the blowfish algorithm
#
# @author	Dieter Vanden Eynde <www.dieterve.be>
package Blowfish;


# Required perl package
use Crypt::Blowfish_PP;


# Possible characters to use for encryption/decryption
use constant B64 => './0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';


# Create key 
#
# If the key is shorter then 8 characters we need to rebuild it till its 8 characters
# If its longer the 8 characters we simply return it.
sub createKey
{
	# parameters
	my($key) = @_;

	# length of the key
	my $keyLength = length($key);

	# its too short
	if ($keyLength < 8)
	{
		# init
		my $longKey = '';
	
		# how many times do we need to add the key before we have a minimum of 8 characters
		my $i = 8 / $keyLength;

		# round up (ugly way but this doesnt require another package)
		$i = int($i + .5);

		# loop
		while($i > 0)
		{
			# add to the long key
			$longKey .= $key;
            
			# decrease counter
			$i--;
		}
        
		# set
		$key = $longKey;
	}
    
    # return the key
    return $key;
}


# Decrypt to plaintext
sub decrypt
{
	# parameters
	my($text, $key) = @_;
	
	# create key
	$key = createKey($key);

	# add a newline character every 12 characters
    $text =~ s/(.{12})/$1\n/g;
    
    # init
    my $result = '';
    
    # blowfish object
    my $cipher = new Crypt::Blowfish_PP($key);
    
    # split on newline character
    my @chunks = split(/\n/, $text);
    
    # loop chunks
    foreach(@chunks)
    {
    	# convert to bytes and decrypt
        $result .= $cipher->decrypt(convertToBytes($_));
    }
    
    # remove trailing null characters
    $result =~ s/\x0+$//;
    
	# return decrypted string
    return $result;
}


# Convert a string to bytes using the B64 characters
sub convertToBytes
{
	# parameters
	my ( $text ) = @_;
	
	# init
    my $result = '';
    my $k = -1;
    
    # text length
    my $textLength = length($text);

	# loop
    while($k < ($textLength - 1))
    {
    	# init
        my($left, $right) = (0, 0);
        
        # loop right and left
        for($right, $left)
        {
        	# loop 6 times
            foreach my $i(0 .. 5)
            {
            	# increase
            	$k++;
            	
            	# get corresponding index from the B64 characters
            	my $tmp = index(B64, substr($text, $k, 1));
            	
            	# shift to the left
            	$tmp = $tmp << ($i * 6);
            	
            	# add left/right
            	$_ |= $tmp;
            }
        }
        
        # loop left and right
        for($left, $right)
        {
        	# loop 4 times
            foreach my $i(0 .. 3)
            {
            	# add the character based on the index created above
            	$result .= chr(($_ & (0xFF << ((3 - $i) * 8))) >> ((3 - $i) * 8));
            }
        }
    }

	# return bytes
    return $result;
}


# Encrypt plaintext using blowfish
sub encrypt
{
	# parameters
	my($text, $key) = @_;
	
	# create key
	$key = createKey($key);

	# put a newline character every 8 characters
    $text =~ s/(.{8})/$1\n/g;
    
    # init
    my $result = '';
    
    # create blowfish object
    my $cipher = new Crypt::Blowfish_PP($key);
    
    # split text on newlines
    @chunks = split(/\n/, $text);
    
    # loop chunks
    foreach(@chunks)
    {
    	# encrypt the chunk and convert it to a string
        $result .= convertToString($cipher->encrypt($_));
    }

	# return the encrypted string
    return $result;
}


# Convert encrypted bytes to a string using the B64 characters
sub convertToString
{
	# parameters
	my($text) = @_;
	
	# init
    my $result = '';
    my $k = -1;
    
	# text length
	$textLength = length($text);
	
	# loop
    while($k < ($textLength - 1))
    {
    	# init
        my($left, $right) = (0, 0);
        
        # loop left and right
        for($left, $right) 
        {
        	# shift text for each of numbers
            foreach my $i(24, 16, 8)
            {
            	# increase
            	$k++;
            	
            	# get numeric (native encoding) value for the text
            	my $tmp = ord(substr($text, $k, 1));
            	
            	# shift to the left
            	$tmp = $tmp << $i;
            	
            	# add
            	$_ += $tmp;
            }
            
            # add numeric value without shifting
            $_ += ord(substr($text, ++$k, 1));
        }
		
        # loop right and left
        for($right, $left)
        {
        	# loop 5 times
            foreach my $i(0 .. 5)
            {
            	# get the corresponding character
                $result .= substr(B64, $_ & 0x3F, 1);
                
                # shift 6 times to the right and add
                $_ = $_ >> 6;
            }
        }
    }
    
    # return string
    return $result;
}
1;