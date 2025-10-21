/// Base model interface for API responses
abstract class BaseModel {
  BaseModel fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
