=head1 PACKAGE

Web::oEmbed::Common -- Define several well-known oEmbed providers.


=head1 SYNOPSIS

  my $oembedder = Web::oEmbed::Common->new();

  my $info = $oembedder->embed( $link_url );
  if ( $info ) {
    print $info->render;
  }


=head1 DESCRIPTION

Web::oEmbed::Common defines oEmbed API endpoints for over a dozen popular providers.

When you create an Web::oEmbed::Common instance, it is initialized with a default set of providers; you can extend it further with your own definitions using the C<register_provider> method.

The interface mirrors that of L<Web::oEmbed>: call the C<embed> method with a URL you'd like more information about, then extract the result information using the methods defined by Web::oEmbed::Response. 

Endpoints are currently defined for the following content sites: 5min, Blip.tv, DailyMotion, Flickr, FunnyOrDie.com, Hulu, PhotoBucket, PollDaddy.com, Qik, Revision3, Scribd, SmugMug, Viddler, Vimeo, WordPress.tv, YouTube

An endpoint is also defined for the oEmbed adaptor service from Embed.ly, which itself supports several dozen content sites. As this service is continuing to add new URL patterns, the list of sites it currently supports is fetched on the fly via HTTP when a new Web::oEmbed::Common instance is created.


=head1 SEE ALSO

L<http://www.oembed.com/>, L<Web::oEmbed>


=head1 AUTHOR

Developed by Matthew Simon Cavalletto.  You may contact the author 
directly at C<evo@cpan.org> or C<simonm@cavalletto.org>.

I found some of these oEmbed endpoint URLs defined in similar libraries 
in other languages, including wp-includes/class-oembed and django-oembed.


=head1 LICENSE 

Copyright 2010 Matthew Simon Cavalletto. 

You may use, modify, and distribute this software under the same terms as Perl.

See http://dev.perl.org/licenses/ for more information.

=cut


package Web::oEmbed::Common;

use strict;
use 5.006;

use Carp;
use Any::Moose;

our $VERSION = '0.01';

use Web::oEmbed;
extends 'Web::oEmbed';

########################################################################

{
	# Embed.ly passes back a non-standard "description" field.
	package Web::oEmbed::Response;
	has 'description', is => 'rw';
}

# Embed.ly's web-accessible URL list includes patterns like *yfrog.com, so
# we over-ride the default Web::oEmbed behavior to allow * to match . in
# hostnames, so the above line will match both www.yfrog.com and yfrog.com.
sub _compile_url {
    my($self, $url) = @_;
    my $res;
    my $uri = URI->new($url);
    $res  = $uri->scheme . '://';
    $res .= Web::oEmbed::_run_regexp($uri->host, '[0-9a-zA-Z\-\.]*');
    $res .= Web::oEmbed::_run_regexp($uri->path, "[$URI::uric]+" );
    $res;
}

########################################################################

# Extends the default Web::oEmbed behavior to allow loading the URL list 
# from a remote location, as well as for passing multiple space-separated 
# URLs in a single call.
sub register_provider {
    my($self, $provider) = @_;

	if ( ! $provider->{url} and $provider->{url_src} ) {		
		my $res = $self->agent->get( $provider->{url_src} );
	
		unless ( $res->is_success ) {
			croak( 'Unable to retrive remote URLs for oEmbed: ' . $res->status_line . ' from ' . $provider->{url_src} );
		}
		
		$provider->{url} = $res->content;
	}

	if ( ! length $provider->{url} ) {
		croak( 'Missing url for oEmbed: ' . $provider->{api} );
	}

	$provider->{regexp} = join '|', map {  $self->_compile_url( $_ ) } grep $_, split ' ', $provider->{url};
	
    push @{$self->providers}, $provider;
}

########################################################################

sub BUILD {
	my $self = shift;
	$self->register_common();
}

sub register_providers {
    my($self, @providers) = @_;

	foreach my $provider ( @providers ) {
		$self->register_provider( $provider ) 
	}
}

########################################################################

sub register_common {	
	(shift)->register_providers( 
		{
			name => 'Flickr', 
			api  => 'http://www.flickr.com/services/oembed/', 
			url  => 'http://flickr.com/photos/* http://www.flickr.com/photos/*', 
		},
		{ 
			name => 'YouTube',                                                                                                              
			api  => 'http://www.youtube.com/oembed', 
			url  => 'http://*youtube.com/watch* http://youtu.be/*', 
		},
		{
			name => 'Viddler', 
			api  => 'http://lab.viddler.com/services/oembed/', 
			url  => 'http://viddler.com/* http://www.viddler.com/*', 
		},
		{
			name => 'Qik', 
			api  => 'http://qik.com/api/oembed.json', 
			url  => 'http://qik.com/*', 
		},
		{
			name => 'Vimeo', 
			api  => 'http://vimeo.com/api/oembed.json', 
			url  => 'http://www.vimeo.com/* http://vimeo.com/*', 
		},
		{
			name => 'Revision3', 
			api  => 'http://revision3.com/api/oembed/', 
			url  => 'http://*revision3.com/*', 
		},
		{                                                                                                                        
			name => 'Scribd',                                                                                                              
			api  => 'http://www.scribd.com/services/oembed',                                                                           
			url  => 'http://www.scribd.com/* http://scribd.com/*',                                                                                  
		},
		{                                                                                                                        
			name => '5min',                                                                                                              
			api  => 'http://api.5min.com/oembed.xml',                                                                           
			url  => 'http://www.5min.com/video/*',                                                                                  
		},
		{ 
			name => 'Blip.tv',                                                                                                              
			api  => 'http://blip.tv/oembed/', 
			url  => 'http://blip.tv/file/*', 
		},
		{ 
			name => 'DailyMotion',                                                                                                              
			api  => 'http://www.dailymotion.com/api/oembed', 
			url  => 'http://*dailymotion.com/*', 
		},
		{ 
			name => 'SmugMug',                                                                                                              
			api  => 'http://api.smugmug.com/services/oembed/', 
			url  => 'http://*smugmug.com/*', 
		},
		{ 
			name => 'Hulu',                                                                                                              
			api  => 'http://www.hulu.com/api/oembed.json', 
			url  => 'http://*hulu.com/watch/*', 
		},
		{ 
			name => 'PhotoBucket',                                                                                                              
			api  => 'http://photobucket.com/oembed', 
			url  => 'http://i*.photobucket.com/albums/* http://gi*.photobucket.com/groups/*', 
		},
		{ 
			name => 'WordPress.tv',                                                                                                              
			api  => 'http://wordpress.tv/oembed/', 
			url  => 'http://wordpress.tv/*', 
		},
		{ 
			name => 'PollDaddy.com',                                                                                                              
			api  => 'http://polldaddy.com/oembed/', 
			url  => 'http://*polldaddy.com/*', 
		},
		{ 
			name => 'FunnyOrDie.com',                                                                                                              
			api  => 'http://www.funnyordie.com/oembed', 
			url  => 'http://*funnyordie.com/videos/*', 
		},
		{
			name => 'Embed.ly',
			api  => 'http://api.embed.ly/v1/api/oembed',
			url_src  => 'http://api.embed.ly/static/data/embedly_regex.txt',
		},
	);
}

########################################################################

1;
