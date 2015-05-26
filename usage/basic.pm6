use Piker::Route;

class MyApp::Basic does Piker::Route {
  has $.path = '/';

  method handler($req, $res) {
    $res.close('Hello world!');
  }
}
