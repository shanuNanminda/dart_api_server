import 'dart:convert';
import 'dart:io';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';


final _router = Router()
  ..get('/', _rootHandler)
  ..post('/test', _echoHandler)
  ..post('/login',loginHandler)
  ..post('/signUp',signUpHandler)
  ;

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}


MySqlConnection? conn;

Future<void> startDB()async{
  conn = await MySqlConnection.connect( ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      // password: '',
      db: 'sample',
      ));
  print('connection $conn');
  print('connection done');
}


Future<Response> loginHandler(Request req)async{
final message= jsonDecode(await req.readAsString());
String userName= message['userName'];
String password= message['password'];
Results res=await conn!.query("select * from login_table where username='$userName' and password='$password' ");
return Response.ok(jsonEncode({'result':res.length>0?'succesful':'failed'}));
}

Future<Response> signUpHandler(Request req)async{
final message= jsonDecode(await req.readAsString());
String userName= message['userName'];
String password= message['password'];
Results res=await conn!.query("insert into login_table(username,password) values('$userName','$password')");
print(res.affectedRows);
return Response.ok(jsonEncode({'result':res.affectedRows!<1?'failed':'user created'}));
}

Future<Response> _echoHandler(Request request) async{
  print('handler called');
  final message = jsonDecode(await request.readAsString());
  print(message['message']);
  if(conn!=null){
    print('connection $conn');
    // conn!.query("insert into new values ('hello')");

  }
  Results names=await  conn!.query('select name from new');
  final namesList=[];
  names.forEach((element) { 
    namesList.add(element.values!.first);
    print(element.values!.first);
  });
  return Response.ok(jsonEncode({'message':message['message'],'created_at':DateTime.now().toString(),'names':'${namesList}'}),);
}



void main(List<String> args) async {
  await startDB();
  print('connection $conn');
  final ip = InternetAddress.anyIPv4;

  
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
