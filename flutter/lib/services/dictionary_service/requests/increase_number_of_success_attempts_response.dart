class IncreaseNumberOfSuccessAttemptsResponse {
  final bool trainingPhaseWasIncreased;

  IncreaseNumberOfSuccessAttemptsResponse(this.trainingPhaseWasIncreased);

  factory IncreaseNumberOfSuccessAttemptsResponse.fromJson(dynamic json) {
    return IncreaseNumberOfSuccessAttemptsResponse(
      json['trainingPhaseWasIncreased'] as bool,
    );
  }
}
