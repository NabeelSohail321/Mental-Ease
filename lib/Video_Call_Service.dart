const token = '007eJxTYOCQLn0ixNZglJO9NLDnnqmr7ofuay7GycWnLGex2+xbIafAYGJummaZZmxmYGJhaGKWZJ6YammRamlkYpmalpxsZGG57WRaRkMgI8OJ9YqsjAwQCOJzM/im5pUk5ii4JhanMjAAAE04H4k=';
const appId = '475f9f36048146b7ae98e9249efcc289';

String generateChannelId(String currentUserId, String receiverId) {
  List<String> ids = [currentUserId, receiverId]..sort();
  return 'call_${ids[0]}_${ids[1]}';
}


// 007eJxTYLDeuWpp1e+8xsv/RUJYzrzYtf+HRYVd4ymn+BQLv2XqmksVGEzMTdMs04zNDEwsDE3MkswTUy0tUi2NTCxT05KTjSwsD4U5ZDQEMjI0P4pgZmSAQBCfm8E3Na8kMUfBNbE4lYEBAIMYImI=