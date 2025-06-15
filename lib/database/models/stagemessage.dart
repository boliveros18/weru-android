class StageMessage {
  final int? id;
  final String Message;
  final String MessageFamily;
  final String Action;
  final String CreatedAt;
  final int Sent;

  StageMessage(
      {this.id,
      required this.Message,
      required this.MessageFamily,
      required this.Action,
      required this.CreatedAt,
      required this.Sent});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'Message': Message,
      'MessageFamily': MessageFamily,
      'Action': Action,
      'CreatedAt': CreatedAt,
      'Sent': Sent
    };
  }

  factory StageMessage.fromMap(Map<String, dynamic> map) {
    return StageMessage(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      Message: map['Message']?.toString() ?? '',
      MessageFamily: map['MessageFamily']?.toString() ?? '',
      Action: map['Action']?.toString() ?? '',
      CreatedAt: map['CreatedAt']?.toString() ?? '',
      Sent: int.tryParse(map['Sent']?.toString() ?? '') ?? 0,
    );
  }

  @override
  String toString() {
    return 'StageMessage{id: $id, Message: $Message, MessageFamily: $MessageFamily, Action: $Action, CreatedAt: $CreatedAt, Sent: $Sent}';
  }
}
