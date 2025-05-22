abstract class AiEvent {}

class AskAiEvent extends AiEvent {
  final String description;
  final String token;

  AskAiEvent({required this.description, required this.token});
}

class GetMedicineByNameEvent extends AiEvent {
  final String name;
  final String token;

  GetMedicineByNameEvent({required this.name, required this.token});
}
