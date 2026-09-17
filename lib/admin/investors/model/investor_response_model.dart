import 'investor_model.dart';

class InvestorTotalsModel {
  final double totalInvestmentAmount;
  final double totalPaidAmount;

  const InvestorTotalsModel({
    this.totalInvestmentAmount = 0,
    this.totalPaidAmount = 0,
  });

  factory InvestorTotalsModel.fromJson(Map<String, dynamic> json) {
    return InvestorTotalsModel(
      totalInvestmentAmount: _readDouble(
        json['totalInvestmentAmount'] ?? json['TotalInvestmentAmount'],
      ),
      totalPaidAmount: _readDouble(
        json['totalPaidAmount'] ?? json['TotalPaidAmount'],
      ),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class InvestorResponseModel {
  final bool status;
  final String message;
  final List<InvestorModel> data;
  final InvestorTotalsModel total;
  final int code;

  InvestorResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.total,
    required this.code,
  });

  factory InvestorResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawData = json['data'] ?? json['Data'];
    final rootTotal = json['total'] ?? json['Total'];

    List<dynamic> list = const [];
    Map<String, dynamic>? nestedTotal;

    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      final dataMap = Map<String, dynamic>.from(rawData);
      final nestedList = dataMap['investors'] ??
          dataMap['Investors'] ??
          dataMap['items'] ??
          dataMap['Items'] ??
          dataMap['list'] ??
          dataMap['List'] ??
          dataMap['data'] ??
          dataMap['Data'];
      if (nestedList is List) {
        list = nestedList;
      }
      final totalInData = dataMap['total'] ?? dataMap['Total'];
      if (totalInData is Map) {
        nestedTotal = Map<String, dynamic>.from(totalInData);
      }
    }

    final totalJson = rootTotal is Map
        ? Map<String, dynamic>.from(rootTotal)
        : nestedTotal;

    return InvestorResponseModel(
      status: _readStatus(json['status'] ?? json['Status']),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: list
          .whereType<Map>()
          .map(
            (item) => InvestorModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      total: totalJson != null
          ? InvestorTotalsModel.fromJson(totalJson)
          : const InvestorTotalsModel(),
      code: _readInt(json['code'] ?? json['Code']),
    );
  }

  static bool _readStatus(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 'success' ||
          normalized == '1';
    }
    return false;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
