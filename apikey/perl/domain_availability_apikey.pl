use Digest::HMAC_MD5 qw( hmac_md5_hex );    # From CPAN
use JSON qw( decode_json encode_json );     # From CPAN
use LWP::Protocol::https;                   # From CPAN
use LWP::Simple;                            # From CPAN
use MIME::Base64 qw( encode_base64 );
use Time::HiRes qw( time );                 # From CPAN
use URI::Escape qw( uri_escape );           # From CPAN

use strict;
use warnings;

my @domains = (
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
);
my $url = 'https://whoisxmlapi.com/whoisserver/WhoisService';

my $username = 'Your domain availability api username';
my $api_key = 'Your domain availability api key';
my $secret = 'Your domain availability api secret key';

my $timestamp = int((time * 1000 + 0.5));
my $digest = generateDigest($username, $timestamp, $api_key, $secret);

foreach my $domain (@domains) {
    my $requstString = buildRequest($username, $timestamp, $digest, $domain);
    my $response = get($url . $requstString);

    if (index($response, 'Request timeout')) {
        $timestamp = int((time * 1000 + 0.5));
        $digest = generateDigest($username, $timestamp, $api_key, $secret);
        $requstString = buildRequest($username, $timestamp, $digest, $domain);
        $response = get($url . $requstString);
    }

    printResponse($response);
    print "---------------------------------------\n";
}

sub generateDigest
{
    my ($req_username, $req_timestamp, $req_key, $req_secret) = @_;

    my $res_digest = $req_username . $req_timestamp . $req_key;
    my $res_hash = hmac_md5_hex($res_digest, $req_secret);

    return uri_escape($res_hash);
}

sub buildRequest
{
    my ($req_username, $req_timestamp, $req_digest, $req_domain) = @_;
    my $requestString = '?requestObject=';

    my %request =(
        'u' => $req_username,
        't' => $req_timestamp
    );

    my $requestJson = encode_json(\%request);
    my $requestBase64 = encode_base64($requestJson);

    $requestString .= uri_escape($requestBase64);
    $requestString .= '&cmd=GET_DN_AVAILABILITY';
    $requestString .= '&digest=' . $req_digest;
    $requestString .= '&domainName=' . uri_escape($req_domain);
    $requestString .= '&outputFormat=json';

    return $requestString;
}

sub printResponse
{
    my ($response) = @_;
    my $responseObject = decode_json($response);

    if (exists $responseObject->{'DomainInfo'}->{'domainName'}) {
        print 'Domain name: ',
              $responseObject->{'DomainInfo'}->{'domainName'},
              "\n";
    }
    if (exists $responseObject->{'DomainInfo'}->{'domainAvailability'}) {
        print 'Domain availability: ',
              $responseObject->{'DomainInfo'}->{'domainAvailability'},
              "\n";
    }
}