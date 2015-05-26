use HTTP::Server::Threaded;
use HTTP::Server::Threaded::Router;

use Piker::Model;
use Piker::Route;

class Piker {
  has Str  $.host;
  has Int  $.port;
  has Bool $.autobind;
  has      $.server;
  has      @!dirs; 

  submethod BUILD(:$!host? = '127.0.0.1', :$!port? = 8080, :@!dirs? = @('lib'), :$!autobind? = True, :$!server?) {
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
    for @!dirs -> $d {
      try {
        for $d.IO.dir.grep(/ ('.pm6' | '.pl6') $$ /) -> $f {
          try {
            say "{@ignore.perl} vs {GLOBAL::.values.map({.WHO.values}).list.perl}";
            require $f;
            say "{@ignore.perl} vs {GLOBAL::.values.map({.WHO.values}).list.perl}";
            for GLOBAL::.values.map({.WHO.values}).list.grep({ $_.WHICH !~~ any @ignore.map({.WHICH}) }) -> $module {
              $module.perl.say;
              @ignore.push($module);
              "==> Binding {$module.perl} ...".say;
              try { 
                my $obj = $module.new;
                if $obj.^does(Piker::Model) {
                  #something
                }
                if $obj.^does(Piker::Route) {
                  die "{$module.perl} does not contain .path" unless $obj.path;
                  "==> Setting up route {$obj.path}".say;
                  route $obj.path, sub ($req,$res) {
                    $obj.handler($req, $res);;
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
