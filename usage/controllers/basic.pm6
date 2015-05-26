use Hiker::Route;

class MyApp::Basic does Hiker::Route {
  has $.path = '/';
  has $.template = 'basic.pt';

  method handler($req, $res) {
    'i do some controller stuff here'.say;
    $res.data.say;
  }
}
