use Hiker::Route;

class MyApp::Basic does Hiker::Route {
  has $.path = '/';

  method handler($req, $res) {
    $res.close('Hello world!');
  }
}
