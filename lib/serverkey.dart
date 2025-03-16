import 'package:googleapis_auth/auth_io.dart';

class get_server_key {
  Future<String> server_token() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "installmentapp-1cf69",
          "private_key_id": "a0765c7de4370f20bb857ddca053b83ffec1bac3",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDI3bwDHC3gleU0\nhHRMymnV1sFRLb2QFaOhkQJ3eSJGCsmycBJ9TF3sQtUgK3sMkX+I8+VhqQVPCoEI\nr5J+56lL+A2aQx4C1Bw0qasqbACL6r8jldkhtiUUfKpA+2aKCP3EnKcyOW07aZYn\nPg6Ph11ReWzy5kcmoTks1+u/nqYPJCKylDGUWnBwuY30mCTNOZYHUkhnHEs3f3DY\nWxSNb0upyj1jWVbfLhg6Qxt5B6D/xmmOOV1vl4142Rn5GQieIZzyIxfjM+0tcCbp\nBPTA29+V/OoffF2p1J3ZdSII8otUTTPhJX6pBO+XCRgWtuDpQUzPeszwgauj+gPz\nMWatS3G3AgMBAAECggEAAgv4Xkbx1LsFfEgccBF6WJp5AWnBtIknHLG/xuKuGoab\nnYmoA2AKCPeskki/I6NyTqPyYp3FSkcYhea8GGm/f0dGZDVqeRIbCd8jH/bvxOOe\nEclbtNmiF35ZtPkBOq2l+e3ng9ezKQrSlxD6NwFktKLT6fm2U33X3+dNvxGC+0Tl\nv+h7TdxoOi6M6sR/50iAnibTuWXjs74JwST4GXCNPDcQoP6rV99ziTD+EjeHTyW5\n1A4ujC+b3/jPx7auaUOx3R1i9IjQBMJCdlB+rFLPUMxYmtFGBYLfN/poTwwxXfk3\n9T/dPHKeoXUUbHnOGZlW//xc18gTDWT1Oav+MTi3uQKBgQD6cCN1iShip432EJj/\naMWTeArd6f5OeQAuVF3qwMoePkJcQo+zVAjNwo0CpnnD2UIE+5gaw4Ex1kzoUMUB\nOBK1l8FkKx87l/ut1DYyRp7nKHp8AJSBXiE3n5MChQFaOCfvYIjBlIXwmVDoJBLu\nhx+z6cx3mrBeTRegP4o0L/oLOwKBgQDNU8F2hr6ONjP9M+FLWbeYC3d1cWGl8R87\nd/snMHMVW8ZszBtQ1tIZ17qsVNDmyB+U4b/GGKsS4f83g1mT9HhGfxZPFQRN7Jkw\nj81iZ0TaN4KotdaYS6o50K64moVP3gxz71CSo4pQJ52NRZYAkM7LX9SA+01q1LIA\n3PiYiAJztQKBgQCih0w75zuSavMykir49uHihrFmu4kTHGwFpTMeOufxIK6oeXoR\nA6SDBJPG+ItlkwXJfg6EsASUd2OKEYEI/X8G4unbPDEU19m6QlK55iMSGa8D8sxt\n+MzN8H3T0MXD61XfgGLAXsdeEeH0BhVTP9ZPSJgttvJnANkoYpQqskgwKQKBgGHf\nJZ2g1t4k2h08iIyJRGk2NggGNpyJ1fBb3ZytjH3G1Etx8ydSbq2g1jtk5nrLM7qc\n7PO5OHp0vVmxw5Yx9s7rry+c/gNC3zZ1pVndjcVSpnZSzuqjTo3mehJGnXsXheoR\nTd/IEprod0IqxDiazefFUx70Ks/ceMjOi7TxR/HtAoGBANGF4dAmg+7m/8/N0rUa\nuBrwPE1JoFY+PRDiXzMKU4CJp48Gh8RLMRZ4i9ehA9D8kh4wtEWZcRbfrT9HzXmO\n0/YYKDxSuQ1u/8QXh57uH+x0bIuPb2rWx7Fle4tFSrTVS42jxaAjUaC129pVRCLc\ncvHOLEcrGROcjWplwwVGcR6f\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-v136d@installmentapp-1cf69.iam.gserviceaccount.com",
          "client_id": "105523744668287614603",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-v136d%40installmentapp-1cf69.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessserverkey = client.credentials.accessToken.data;
    return accessserverkey;
  }
}
