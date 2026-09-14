import 'package:flutter/material.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/add_fund/widgets/add_fund_form_card.dart';
import 'package:maribel_wellness_centre_application/admin/funding&payments/add_fund/widgets/add_fund_side_panel.dart';
import 'package:maribel_wellness_centre_application/core/constants/app_colors.dart';
import 'package:sizer/sizer.dart';

class AddNewFundScreen extends StatefulWidget {
  const AddNewFundScreen({
    super.key,
    this.onBack,
    this.onSaveSuccess,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSaveSuccess;

  @override
  State<AddNewFundScreen> createState() => _AddNewFundScreenState();
}

class _AddNewFundScreenState extends State<AddNewFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final _payingNowController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _investor;
  String? _investorType;
  DateTime _fundingDate = DateTime.now();

  static const _investors = [
    _InvestorOption(
      name: 'Corey Herwitz',
      type: 'Angel Investor',
      totalAmount: '₹1,20,00,000',
    ),
    _InvestorOption(
      name: 'ABC Constructions',
      type: 'Corporate Investor',
      totalAmount: '₹85,00,000',
    ),
    _InvestorOption(
      name: 'Lotus Heights Fund',
      type: 'Institutional Investor',
      totalAmount: '₹2,50,00,000',
    ),
    _InvestorOption(
      name: 'Park Road Ventures',
      type: 'Individual Investor',
      totalAmount: '₹40,00,000',
    ),
  ];

  List<String> get _investorNames =>
      _investors.map((investor) => investor.name).toList();

  @override
  void initState() {
    super.initState();
    _payingNowController.addListener(_onPayingNowChanged);
  }

  void _onPayingNowChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _payingNowController.removeListener(_onPayingNowChanged);
    _totalAmountController.dispose();
    _payingNowController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onInvestorChanged(String? name) {
    final selected = _investors.cast<_InvestorOption?>().firstWhere(
          (investor) => investor?.name == name,
          orElse: () => null,
        );

    setState(() {
      _investor = selected?.name;
      _investorType = selected?.type;
      _totalAmountController.text = selected?.totalAmount ?? '';
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _handleSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }

    if (widget.onSaveSuccess != null) {
      widget.onSaveSuccess!();
      return;
    }
    _handleBack();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fundingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _fundingDate = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;
          final isNarrow = constraints.maxWidth < 980;

          final formCard = AddFundFormCard(
            formKey: _formKey,
            investor: _investor,
            investorOptions: _investorNames,
            onInvestorChanged: _onInvestorChanged,
            investorType: _investorType,
            totalAmountController: _totalAmountController,
            payingNowController: _payingNowController,
            fundingDate: _fundingDate,
            onPickDate: _pickDate,
            formatDate: _formatDate,
            descriptionController: _descriptionController,
          );

          final sidePanel = AddFundSidePanel(
            investor: _investor,
            fundingType: _investorType,
            totalAmount: _totalAmountController.text.isEmpty
                ? null
                : _totalAmountController.text,
            payingNow: _payingNowController.text.trim().isEmpty
                ? null
                : _payingNowController.text.trim(),
            onCancel: _handleBack,
            onSave: _handleSave,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  16,
                ),
                child: _BreadcrumbHeader(onBack: _handleBack),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isNarrow) ...[
                        formCard,
                        const SizedBox(height: 16),
                        sidePanel,
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: formCard),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: sidePanel),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InvestorOption {
  const _InvestorOption({
    required this.name,
    required this.type,
    required this.totalAmount,
  });

  final String name;
  final String type;
  final String totalAmount;
}

class _BreadcrumbHeader extends StatelessWidget {
  const _BreadcrumbHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final breadcrumbAndTitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Funding & Payments',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '>',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  'Add New Fund',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Add New Fund',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a new funding entry to track investor contributions and project financing',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        );

        final backButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.newBorder,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.newBorder, width: 1),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Back to Funding',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              breadcrumbAndTitle,
              const SizedBox(height: 8),
              backButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: breadcrumbAndTitle),
            backButton,
          ],
        );
      },
    );
  }
}
