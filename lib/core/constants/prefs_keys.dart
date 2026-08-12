enum PrefsKey {
  accessToken('access_token'),
  refreshToken('refresh_token'),
  userProfile('user_profile');

  final String value;
  const PrefsKey(this.value);
}
