const token = '007eJxTYIhYkbzuzOmpFsUSBw3MFvZPiF6roeHaV7ckvGTHsSQJUV4FBhNz0zTLNGMzAxMLQxOzJPPEVEuLVEsjE8vUtORkIwvL5ZufpjcEMjIU5H5gZWSAQBCfm8E3Na8kMUfBNbE4lYEBANM0IQo=';
const appId = '475f9f36048146b7ae98e9249efcc289';

String generateChannelId(String currentUserId, String receiverId) {
  List<String> ids = [currentUserId, receiverId]..sort();
  return 'call_${ids[0]}_${ids[1]}';
}


