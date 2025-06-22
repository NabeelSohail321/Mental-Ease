const token = '007eJxTYNh6q2iiVpYGq8ijyZ8NblRnbn7yfKH+tpBt7qkRdtaVEw4rMJiYm6ZZphmbGZhYGJqYJZknplpapFoamVimpiUnG1lYBtU6ZDQEMjKc097FysgAgSA+N4Nval5JYo6Ca2JxKgMDAEKOIbo=';
const appId = '475f9f36048146b7ae98e9249efcc289';

String generateChannelId(String currentUserId, String receiverId) {
  List<String> ids = [currentUserId, receiverId]..sort();
  return 'call_${ids[0]}_${ids[1]}';
}


// 007eJxTYLDeuWpp1e+8xsv/RUJYzrzYtf+HRYVd4ymn+BQLv2XqmksVGEzMTdMs04zNDEwsDE3MkswTUy0tUi2NTCxT05KTjSwsD4U5ZDQEMjI0P4pgZmSAQBCfm8E3Na8kMUfBNbE4lYEBAIMYImI=