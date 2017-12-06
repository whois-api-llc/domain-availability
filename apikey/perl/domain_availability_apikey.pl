use strict;
use warnings;
use Data::Dumper;
use LWP::Simple;                            # From CPAN
use JSON qw( decode_json encode_json );     # From CPAN
use Time::HiRes qw( time );                 # From CPAN
use Digest::HMAC_MD5 qw( hmac_md5_hex );    # From CPAN
use URI::Escape;                            # From CPAN
use MIME::Base64 qw( encode_base64 );

my @domains = (
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
);
my $url = 'https://whoisxmlapi.com/whoisserver/WhoisService?';
my $username = 'Your domain availability api username';
my $apiKey = 'Your domain availability api api_key';
my $secret = 'Your domain availability api secret_key';

my $timestamp = int((time * 1000 + 0.5));
my $digest = generateDigest($username, $timestamp, $apiKey, $secret);

foreach my $domain (@domains){
    my $requstString = buildRequest(
        $username,
        $timestamp,
        $digest,
        $domain
    );
    my $response = get($url . $requstString);
    if (index($response, 'Request timeout')){
        $timestamp = int((time * 1000 + 0.5));
        $digest = generateDigest($username, $timestamp, $apiKey, $secret);
        $requstString = buildRequest(
            $username,
            $timestamp,
            $digest,
            $domain
        );
        $response = get($url . $requstString);
    }
    printResponse($response);
    print "---------------------------------------\n";
}

sub generateDigest{
    my ($username, $timestamp, $apiKey, $secret) = @_;

    my $digest = $username . $timestamp . $apiKey;
    my $hash = hmac_md5_hex($digest, $secret);
    return uri_escape($hash);
}

sub buildRequest{
    my ($username, $timestamp, $digest, $domain) = @_;
    my $requestString = 'requestObject=';
    my %request =(
        'u' => $username,
        't' => $timestamp
    );
    my $requestJson = encode_json(\%request);
    my $requestBase64 = encode_base64($requestJson);
    $requestString .= uri_escape($requestBase64);
    $requestString .= '&cmd=GET_DN_AVAILABILITY';
    $requestString .= '&digest=';
    $requestString .= $digest;
    $requestString .= '&domainName='
        . $domain
        . '&outputFormat=json';
    return $requestString;
}

sub printResponse{
    my ($response) = @_;
    my $responseObject = decode_json($response);
    if (exists $responseObject->{'DomainInfo'}->{'domainName'}){
        print 'Domain name: ',
            $responseObject->{'DomainInfo'}->{'domainName'},
            "\n";
    }
    if (exists $responseObject->{'DomainInfo'}->{'domainAvailability'}){
        print 'Domain availability: ',
            $responseObject->{'DomainInfo'}->{'domainAvailability'},
            "\n";
    }
}
