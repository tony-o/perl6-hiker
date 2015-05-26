use HTTP::Server::Threaded;
use HTTP::Server::Threaded::Router;

use Hiker::Model;
use Hiker::Route;
use Hiker::Render;

class Hiker {
  has Str  $.host;
  has Int  $.port;
  has Bool $.autobind;
  has      $.server;
  has      @!controllers;
  has      $.templates;

  submethod BUILD(:$!host? = '127.0.0.1', :$!port? = 8080, :@!controllers? = @('lib'), :$!autobind? = True, :$!server?, Str :$!templates = 'templates') {
    if $!server !~~ HTTP::Server::Threaded {
      $!server = HTTP::Server::Threaded.new(:ip($!host), :$!port);
    }
    if $!autobind {
      self.bind;
    }
    serve $!server;
  }

  method bind {
    my @ignore;
    for GLOBAL::.values {
      @ignore.push($_.WHO.values);
    }
    for @!controllers -> $d {
      try {
        for $d.IO.dir.grep(/ ('.pm6' | '.pl6') $$ /) -> $f {
          try {
            require $f;
            for GLOBAL::.values.map({.WHO.values}).list.grep({ $_.WHICH !~~ any @ignore.map({.WHICH}) }) -> $module {
              @ignore.push($module);
              try {
                "==> Binding {$module.perl} ...".say;
                my $obj = $module.new;
                if $obj.^does(Hiker::Model) {
                  #something
                }
                if $obj.^does(Hiker::Route) {
                  die "{$module.perl} does not contain .path" unless $obj.path;
                  "==> Setting up route {$obj.path} ($f)".say;
                  my $template = $obj.template;
                  route $obj.path, sub ($req, $res) {
                    CATCH { default {
                      "==> Failed to serve {$req.resource}".say;
                      $_.Str.lines.map({ "\t$_".say; });
                      $_.backtrace.Str.lines.map({ "\t$_".say; });
                    } }
                    $res does Hiker::Render;
                    $res.req = $req;
                    $res.template = $*SPEC.catpath('', $.templates, $template);
                    my $lval = $obj.handler($req, $res);
                    return False if $res.rendered;
                    $res.render if so $lval && !so $res.rendered;
                    $lval;
                  }
                }
                CATCH { default {
                  "==> Failed to bind {$module.perl}".say;
                  $_.Str.lines.map({ "\t$_".say; });
                  $_.backtrace.Str.lines.map({ "\t$_".say; });
                } }
              } 
            }
            CATCH { default { say $_; } }
          }
        }
      }
    }
  }

  method listen(Bool $async? = False) {
    if $async {
      return start { $.server.listen; };
    }
    $.server.listen;
  }
}
