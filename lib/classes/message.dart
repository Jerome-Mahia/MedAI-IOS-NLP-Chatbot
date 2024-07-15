class Message {
  final String text;

  Message({
    required this.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
    };
}
