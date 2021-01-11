import 'dart:convert' as convert;

String getImage(String imgJson) {
  try {
    Map<String,dynamic> json = convert.jsonDecode(imgJson);
    if(json.containsKey('medium_format')){
      print('parsedJson ' + json['medium_format']);
      return json['medium_format'];
    }
    print('not parsedJson ' + imgJson);
    return imgJson;
  } catch(e){
    if(imgJson.startsWith('"\\"')) {
      imgJson = imgJson.substring(3, imgJson.length - 3);
    }else if(imgJson.startsWith('"')){
      imgJson = imgJson.substring(1, imgJson.length - 1);
    }
    print('exception ' + imgJson);
    return imgJson;
  }
}