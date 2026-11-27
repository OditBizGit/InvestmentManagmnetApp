import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/investor_nominee_submit.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/register_investor_model.dart';
import 'package:maribel_wellness_centre_application/admin/investors/model/update_investor_model.dart';

MultipartFile _file(String name) =>
    MultipartFile.fromBytes([1, 2, 3], filename: name);

bool _isProfileKey(String key) => key.contains('Profile');

Set<String> _documentKeys(FormData formData) => formData.files
    .map((e) => e.key)
    .where((key) => !_isProfileKey(key))
    .toSet();

String? _field(FormData formData, String key) {
  for (final entry in formData.fields) {
    if (entry.key == key) return entry.value;
  }
  return null;
}

String? _fileName(FormData formData, String key) {
  for (final entry in formData.files) {
    if (entry.key == key) return entry.value.filename;
  }
  return null;
}

InvestorNomineeSubmitData _fullNominee(int id, String tag) =>
    InvestorNomineeSubmitData(
      nomineeId: id,
      name: 'Nominee $tag',
      aadhaarCardImage: _file('$tag-aadhaar-front.jpg'),
      aadhaarCardBackImage: _file('$tag-aadhaar-back.jpg'),
      panCardImage: _file('$tag-pan-front.jpg'),
      panCardBackImage: _file('$tag-pan-back.jpg'),
    );

RegisterInvestorRequestModel _register({
  MultipartFile? aadhaarFront,
  MultipartFile? aadhaarBack,
  MultipartFile? panFront,
  MultipartFile? panBack,
  List<InvestorNomineeSubmitData> nominees = const [],
}) {
  return RegisterInvestorRequestModel(
    username: 'user',
    password: 'secret1',
    fullName: 'Full Name',
    email: 'a@b.com',
    phoneNumber: '9999999999',
    alternativeNumber: '',
    investorType: 'Type',
    staffId: 1,
    organization: '',
    address: 'Somewhere',
    investmentDate: DateTime(2026, 1, 1),
    investmentSplitMonths: 12,
    investmentSplitType: 'Month',
    investmentSplitGap: 1,
    investmentAdvanceAmount: 0,
    paymentMethod: 'Cash',
    aadhaarNumber: '',
    panCardNumber: '',
    accountNumber: '',
    ifscCode: '',
    bankName: '',
    nominees: nominees,
    aadhaarCardImage: aadhaarFront,
    aadhaarCardBackImage: aadhaarBack,
    panCardImage: panFront,
    panCardBackImage: panBack,
  );
}

UpdateInvestorRequestModel _update({
  MultipartFile? aadhaarFront,
  MultipartFile? aadhaarBack,
  MultipartFile? panFront,
  MultipartFile? panBack,
  List<InvestorNomineeSubmitData> nominees = const [],
}) {
  return UpdateInvestorRequestModel(
    userId: 7,
    fullName: 'Full Name',
    nominees: nominees,
    aadhaarPhoto: aadhaarFront,
    aadhaarBackPhoto: aadhaarBack,
    panCardPhoto: panFront,
    panCardBackPhoto: panBack,
  );
}

void main() {
  group('RegisterInvestor form data', () {
    test('all 16 document files produce exactly the 16 expected keys',
        () async {
      final formData = await _register(
        aadhaarFront: _file('i-aadhaar-front.jpg'),
        aadhaarBack: _file('i-aadhaar-back.jpg'),
        panFront: _file('i-pan-front.jpg'),
        panBack: _file('i-pan-back.jpg'),
        nominees: [
          _fullNominee(0, 'n1'),
          _fullNominee(0, 'n2'),
          _fullNominee(0, 'n3'),
        ],
      ).toFormData();

      expect(_documentKeys(formData), {
        'AadhaarPhoto',
        'AadhaarBackPhoto',
        'PanCardPhoto',
        'PanCardBackPhoto',
        'NomineeAadhaarPhoto',
        'NomineeAadhaarBackPhoto',
        'NomineePanCardPhoto',
        'NomineePanCardBackPhoto',
        'Nominee2AadhaarPhoto',
        'Nominee2AadhaarBackPhoto',
        'Nominee2PanCardPhoto',
        'Nominee2PanCardBackPhoto',
        'Nominee3AadhaarPhoto',
        'Nominee3AadhaarBackPhoto',
        'Nominee3PanCardPhoto',
        'Nominee3PanCardBackPhoto',
      });
      expect(
        formData.files.where((e) => !_isProfileKey(e.key)),
        hasLength(16),
      );
    });

    test('each register key carries the file of its owner, document and side',
        () async {
      final formData = await _register(
        aadhaarBack: _file('i-aadhaar-back.jpg'),
        nominees: [
          _fullNominee(0, 'n1'),
          _fullNominee(0, 'n2'),
          _fullNominee(0, 'n3'),
        ],
      ).toFormData();

      expect(_fileName(formData, 'AadhaarBackPhoto'), 'i-aadhaar-back.jpg');
      expect(
        _fileName(formData, 'NomineePanCardBackPhoto'),
        'n1-pan-back.jpg',
      );
      expect(
        _fileName(formData, 'Nominee2AadhaarBackPhoto'),
        'n2-aadhaar-back.jpg',
      );
      expect(
        _fileName(formData, 'Nominee3PanCardPhoto'),
        'n3-pan-front.jpg',
      );
    });

    test('a back-only pick adds only the back key', () async {
      final formData = await _register(
        panBack: _file('pan-back.jpg'),
        nominees: [
          InvestorNomineeSubmitData(
            name: 'N',
            aadhaarCardBackImage: _file('n-aadhaar-back.jpg'),
          ),
        ],
      ).toFormData();

      expect(_documentKeys(formData), {
        'PanCardBackPhoto',
        'NomineeAadhaarBackPhoto',
      });
    });

    test('a front-only pick adds only the front key', () async {
      final formData = await _register(
        aadhaarFront: _file('front.jpg'),
        nominees: [
          InvestorNomineeSubmitData(
            name: 'N',
            panCardImage: _file('n-pan-front.jpg'),
          ),
        ],
      ).toFormData();

      expect(_documentKeys(formData), {
        'AadhaarPhoto',
        'NomineePanCardPhoto',
      });
    });

    test('nothing picked adds no document key', () async {
      final formData = await _register(
        nominees: [const InvestorNomineeSubmitData(name: 'N')],
      ).toFormData();

      expect(_documentKeys(formData), isEmpty);
    });
  });

  group('UpdateInvestor form data', () {
    test('all 16 document files keep their slot and NomineeId', () async {
      final formData = await _update(
        aadhaarFront: _file('i-aadhaar-front.jpg'),
        aadhaarBack: _file('i-aadhaar-back.jpg'),
        panFront: _file('i-pan-front.jpg'),
        panBack: _file('i-pan-back.jpg'),
        nominees: [
          _fullNominee(11, 'n1'),
          _fullNominee(12, 'n2'),
          _fullNominee(13, 'n3'),
        ],
      ).toFormData();

      expect(_documentKeys(formData), {
        'AadhaarPhoto',
        'AadhaarBackPhoto',
        'PanCardPhoto',
        'PanCardBackPhoto',
        for (final slot in [1, 2, 3]) ...[
          'NomineeAadhaarPhoto$slot',
          'NomineeAadhaarBackPhoto$slot',
          'NomineePanCardPhoto$slot',
          'NomineePanCardBackPhoto$slot',
        ],
      });

      expect(_field(formData, 'NomineeId'), '11');
      expect(_field(formData, 'NomineeId2'), '12');
      expect(_field(formData, 'NomineeId3'), '13');
      expect(
        _fileName(formData, 'NomineeAadhaarBackPhoto1'),
        'n1-aadhaar-back.jpg',
      );
      expect(
        _fileName(formData, 'NomineePanCardBackPhoto2'),
        'n2-pan-back.jpg',
      );
      expect(
        _fileName(formData, 'NomineeAadhaarBackPhoto3'),
        'n3-aadhaar-back.jpg',
      );
      expect(
        _fileName(formData, 'NomineePanCardPhoto3'),
        'n3-pan-front.jpg',
      );
    });

    test('a back-only pick on nominee 2 adds only that slot key', () async {
      final formData = await _update(
        nominees: [
          const InvestorNomineeSubmitData(nomineeId: 11, name: 'A'),
          InvestorNomineeSubmitData(
            nomineeId: 12,
            name: 'B',
            panCardBackImage: _file('n2-pan-back.jpg'),
          ),
          const InvestorNomineeSubmitData(nomineeId: 13, name: 'C'),
        ],
      ).toFormData();

      expect(_documentKeys(formData), {'NomineePanCardBackPhoto2'});
      expect(_field(formData, 'NomineeId2'), '12');
    });

    test('a front-only investor pick adds only the front key', () async {
      final formData =
          await _update(aadhaarFront: _file('front.jpg')).toFormData();

      expect(_documentKeys(formData), {'AadhaarPhoto'});
    });

    test('a back-only investor pick adds only the back key', () async {
      final formData = await _update(panBack: _file('back.jpg')).toFormData();

      expect(_documentKeys(formData), {'PanCardBackPhoto'});
    });

    test('nothing picked adds no document key', () async {
      final formData = await _update(
        nominees: [const InvestorNomineeSubmitData(nomineeId: 11, name: 'A')],
      ).toFormData();

      expect(_documentKeys(formData), isEmpty);
      expect(_field(formData, 'NomineeId'), '11');
    });
  });
}
