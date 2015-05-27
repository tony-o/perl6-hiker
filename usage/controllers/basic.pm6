use Hiker::Route;

class MyApp::Basic does Hiker::Route {
  has $.path = '/';
  has $.template = 'basic.pt';

  method handler($req, $res) {
    $res.data<what> = 'variables';
  }
}
