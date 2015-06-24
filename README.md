#hiker

##usage

```perl6
use Hiker;

my $app = Hiker.new(
  hikes     => ['controllers', 'models'],
  templates => 'templates',
);

$app.listen;
```

Pretty easy, right?

###explain yourself

```perl6
  hikes => ['controllers', 'models'],
```

`hikes` are the directories where `Hiker` should look for any `pm6|pl6` files and check for anything resembling a `Hiker::Route|Hiker::Model`.  Since we all love organization, this parameter accepts an array so you can split your models and controllers.

The `Hiker::Route`s found in these directories are sorted by the type of path (`Regex` vs `Str`) and `Str`s without optional parameters (see `HTTP::Server::Router`) are given highest priority, then optional param strings, and then regexes.

```perl6
  templates => 'templates',
```

##`Hiker::Route` a controller

This role lets `Hiker` know what this class does.  Boilerplate class (controller) would look like the following:

```perl6
use Hiker::Route;

class MyApp::Basic does Hiker::Route {
  has $.path     = '/'; # can also be a regex, eg: /.+/
  has $.template = '/routes/basic.pt';
  has $.model    = 'MyApp::Model'; #this is an optional attribute

  method handler($req, $res) {
    True;
  }
}
```

Note, returning the 'True' value auto renders whatever the $.template is.

##`Hiker::Model` a model

This role lets `Hiker` know what this class does.  Boilerplate class (model) would look like the following:

```perl6
use Hiker::Model;

class MyApp::Model does Hiker::Model {
  method bind($req, $res) {
    $res.data<data> = qw<do some db or whatever stuff here>;
  }
}
```

##Request Flow

- Request is received
- `Hiker` runs through all of the routes it found on startup
- The routes are run through until a `True` (or a Promise whose result is `True`) value is returned
- The template specified by the controller is rendered and the result is sent to the client


