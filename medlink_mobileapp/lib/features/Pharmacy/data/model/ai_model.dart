
class AiResponseModel {
  final List<String> medicines;
  final String explanation;

  AiResponseModel({
    required this.medicines,
    required this.explanation,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(
      medicines: List<String>.from(json['medicines'] as List),
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicines': medicines,
      'explanation': explanation,
    };
  }
}
