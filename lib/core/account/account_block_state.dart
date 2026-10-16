part of 'account_block_cubit.dart';

sealed class AccountBlockState {
  const AccountBlockState();
}

class AccountActive extends AccountBlockState {
  const AccountActive();
}

class AccountBlocked extends AccountBlockState {
  const AccountBlocked();
}
