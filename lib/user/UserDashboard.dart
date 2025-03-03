import 'package:flutter/material.dart';

class Userdashboard extends StatefulWidget {
  const Userdashboard({super.key});

  @override
  State<Userdashboard> createState() => _UserdashboardState();
}

class _UserdashboardState extends State<Userdashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.25),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bi_peace-fill.png'),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Heal ',
                          style: TextStyle(
                            fontFamily: "Ubuntu",
                            color: Color(0xFF006064),
                            fontSize: 30,
                          ),
                        ),
                        TextSpan(
                          text: 'Grow & ',
                          style: TextStyle(
                            color: Color(0xFF006064),
                            fontSize: 30,
                          ),
                        ),
                        TextSpan(
                          text: 'Thrive',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
