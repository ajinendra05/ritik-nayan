class Post {

  String? name;
  String? qualification;
  String? imagepath;

  Post({this.name, this.imagepath, this.qualification});

  Post.fromJson(Map<String, dynamic> json){

    name = json[name];
    qualification = json[qualification];
    imagepath = json[imagepath];
  }
}