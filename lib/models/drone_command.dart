class DroneCommand {
  final String baseCommand; // e.g., TAKE OFF, FLY FORWARD, FLY UP
  final double? value; // optional numeric value in meters

  DroneCommand({required this.baseCommand, this.value});

  @override
  String toString() {
    return value != null ? '$baseCommand $value meters' : baseCommand;
  }
}
