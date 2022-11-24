import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


class ApiConnector {

  File? uploadimage;

  // checks if there is internet
  init() {
    return true;
  }

  sendPicture({imagePath})  {
    uploadimage = File(imagePath);
    uploadImage();
  }

  Future<void> uploadImage() async {
     //show your own loading or progressing code here

     String uploadurl = "https://novo.aplop.org/upload.php";

    Uri uploadUri = Uri.parse(uploadurl);

     //dont use http://localhost , because emulator don't get that address
     //insted use your local IP address or use live URL
     //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    try{
      List<int> imageBytes = uploadimage!.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      //convert file image to Base64 encoding
      var response = await http.post(
              uploadUri,
              body: {
                 'image': baseimage,
              }
      );
      if(response.statusCode == 200){
         var jsondata = json.decode(response.body); //decode json data
         if(jsondata["error"]){ //check error sent from server
             print(jsondata["msg"]);
             //if error return from server, show message from server
         }else{
             print("Upload successful");
         }
      }else{
        print("Error during connection to server");
        //there is error during connecting to server,
        //status code might be 404 = url not found
      }
    }catch(e){
       print("Error during converting to Base64");
       //there is error during converting file image to base64 encoding.
    }
  }

}
