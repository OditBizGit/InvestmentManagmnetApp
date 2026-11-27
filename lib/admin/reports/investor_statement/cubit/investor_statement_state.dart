part of 'investor_statement_cubit.dart';

enum InvestorStatementInvestorsStatus { initial, loading, success, failure }

enum InvestorStatementStatus { initial, loading, success, failure }

@immutable
class InvestorStatementState {
  const InvestorStatementState({
    this.investorsStatus = InvestorStatementInvestorsStatus.initial,
    this.investors = const [],
    this.investorsErrorMessage,
    this.statementStatus = InvestorStatementStatus.initial,
    this.statement = const InvestorStatement(),
    this.statementErrorMessage,
  });

  final InvestorStatementInvestorsStatus investorsStatus;
  final List<InvestorOption> investors;
  final String? investorsErrorMessage;

  final InvestorStatementStatus statementStatus;
  final InvestorStatement statement;
  final String? statementErrorMessage;

  InvestorStatementState copyWith({
    InvestorStatementInvestorsStatus? investorsStatus,
    List<InvestorOption>? investors,
    String? investorsErrorMessage,
    bool clearInvestorsError = false,
    InvestorStatementStatus? statementStatus,
    InvestorStatement? statement,
    String? statementErrorMessage,
    bool clearStatementError = false,
  }) {
    return InvestorStatementState(
      investorsStatus: investorsStatus ?? this.investorsStatus,
      investors: investors ?? this.investors,
      investorsErrorMessage: clearInvestorsError
          ? null
          : (investorsErrorMessage ?? this.investorsErrorMessage),
      statementStatus: statementStatus ?? this.statementStatus,
      statement: statement ?? this.statement,
      statementErrorMessage: clearStatementError
          ? null
          : (statementErrorMessage ?? this.statementErrorMessage),
    );
  }
}
