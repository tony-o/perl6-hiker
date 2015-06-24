use Hiker::Model;

class MyApp::Model::Basic does Hiker::Model {
  method bind($req, $res) {
    $res.data<what> = qw<some database call>; 
  }
}
