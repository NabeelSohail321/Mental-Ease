import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Doctor_Profile.dart';
import 'UserDashboard.dart';

class DoctorsListing extends StatefulWidget {
  const DoctorsListing({super.key});

  @override
  State<DoctorsListing> createState() => _DoctorsListingState();
}

class _DoctorsListingState extends State<DoctorsListing> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _showFavorites = false;
  List<dynamic> _allDoctors = [];
  List<dynamic> _displayedDoctors = [];
  int _currentPage = 0;
  final int _pageSize = 10; // Number of doctors to load per page
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreDoctors();
    }
  }

  void _onSearchChanged() {
    _searchDoctors(_searchController.text);
  }

  void _loadMoreDoctors() {
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;
    if (startIndex < _allDoctors.length) {
      setState(() {
        _displayedDoctors.addAll(_allDoctors.sublist(
            startIndex, endIndex > _allDoctors.length ? _allDoctors.length : endIndex));
        _currentPage++;
      });
    }
  }

  void _searchDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all doctors or favorites based on the toggle
        if (_showFavorites) {
          _filterFavorites();
        } else {
          _displayedDoctors = _allDoctors;
        }
      } else {
        // Apply search filter to the appropriate list
        final searchList = _showFavorites ? _displayedDoctors : _allDoctors;
        _displayedDoctors = searchList
            .where((doctor) =>
            doctor['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleFavorites() {
    setState(() {
      _showFavorites = !_showFavorites;
      if (_showFavorites) {
        _filterFavorites();
      } else {
        _displayedDoctors = _allDoctors;
      }
    });
  }

  Future<void> _filterFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _databaseRef.child("${user.uid}/favourites");
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final favorites = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _displayedDoctors = _allDoctors
            .where((doctor) => favorites.containsKey(doctor['uid']))
            .toList();
      });
    } else {
      setState(() {
        _displayedDoctors = []; // Clear the list if no favorites exist
      });
    }
  }

  Future<void> _toggleFavorite(String doctorId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _databaseRef.child("${user.uid}/favourites");
    final snapshot = await userRef.child(doctorId).get();
    if (snapshot.exists) {
      await userRef.child(doctorId).remove();
    } else {
      await userRef.child(doctorId).set(true);
    }
    if (_showFavorites) {
      _filterFavorites();
    }
  }

  Future<bool> _isFavorite(String doctorId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final userRef = _databaseRef.child("${user.uid}/favourites");
    final snapshot = await userRef.child(doctorId).get();
    return snapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 600;
    final crossAxisCount = isDesktop ? 4 : 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(screenHeight * 0.03),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Meet your ',
                                    style: TextStyle(
                                      fontFamily: "CustomFont",
                                      color: Color(0xFF006064),
                                      fontSize: screenHeight * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Doctor",
                                    style: TextStyle(
                                      // fontFamily: "CustomFont",
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Container(
                          width: screenWidth * 0.7,
                          child: Divider(
                            thickness: 2,
                            height: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for doctors...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.03,
                      ),
                    ),
                    onChanged: (query) {
                      _searchDoctors(query);
                    },
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                IconButton(
                  icon: Icon(
                    _showFavorites ? Icons.favorite : Icons.favorite_border,
                    size: screenWidth * 0.06,
                  ),
                  onPressed: _toggleFavorites,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _databaseRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Text('No doctors found.'));
                } else {
                  final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                  _allDoctors = data.entries
                      .where((entry) => entry.value['role'] == 'Psychologist' && entry.value['isListed'] == true)
                      .map((entry) => entry.value)
                      .toList();

                  if (_showFavorites) {
                    _filterFavorites();
                  } else {
                    _displayedDoctors = _allDoctors;
                  }

                  // Apply search filter
                  if (_searchController.text.isNotEmpty) {
                    final searchList = _showFavorites ? _displayedDoctors : _allDoctors;
                    _displayedDoctors = searchList
                        .where((doctor) =>
                        doctor['username'].toLowerCase().contains(_searchController.text.toLowerCase()))
                        .toList();
                  }

                  // Show a message if no favorites are found
                  if (_showFavorites && _displayedDoctors.isEmpty) {
                    return Center(child: Text('No favorites found.'));
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: isDesktop ? 1.2 : 0.6,
                      crossAxisSpacing: screenWidth * 0.02,
                      mainAxisSpacing: screenWidth * 0.02,
                    ),
                    itemCount: _displayedDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _displayedDoctors[index];
                      return FutureBuilder<bool>(
                        future: _isFavorite(doctor['uid']),
                        builder: (context, favoriteSnapshot) {
                          final isFavorite = favoriteSnapshot.data ?? false;
                          return GestureDetector(
                            onTap: (){

                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return DoctorProfile(doctor['uid']);
                              },));

                            },
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Doctor's ImageA
                                  Stack(
                                    children: [
                                      Container(
                                        height: screenHeight * 0.21,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(doctor['profileImageUrl'] ?? ''),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -4,
                                        right: -4,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isFavorite ? Color(0xFF006064) : Colors.transparent,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(24),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite ? Colors.white : Colors.red,
                                              size: screenWidth * 0.06,
                                            ),
                                            onPressed: () => _toggleFavorite(doctor['uid']),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Doctor's Details
                                  Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.01),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor['username'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                        Text(
                                          'Fee: ${doctor['appointmentFee'] ?? 'Unknown'}\$ ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.003),
                                        Text(
                                          doctor['isVerfied']?'Verified':"Not verified",
                                          style: TextStyle(
                                            color: doctor['isVerfied']? Colors.green: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenWidth * 0.028,
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: screenHeight * 0.04,
                                          ),
                                          child: Text(
                                            doctor['specialization'] ?? 'Unknown',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: screenWidth * 0.035,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${doctor['experience'] ?? '0'} years',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(5, (index) {
                                                final rating = double.tryParse(doctor['ratings'] ?? "0.0") ?? 0.0;
                                                if (index < rating.floor()) {
                                                  return Icon(
                                                    Icons.star,
                                                    color: Colors.orange,
                                                    size: screenWidth * 0.05,
                                                  );
                                                } else if (index < rating) {
                                                  return Icon(
                                                    Icons.star_half,
                                                    color: Colors.orange,
                                                    size: screenWidth * 0.05,
                                                  );
                                                } else {
                                                  return Icon(
                                                    Icons.star_border,
                                                    color: Colors.orange,
                                                    size: screenWidth * 0.05,
                                                  );
                                                }
                                              }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: screenHeight*0.08,
        width: screenWidth*0.17,
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to the home page
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return HomeScreen();
            },),(_) => false, );
          },
          child: Icon(Icons.home,color: Colors.white,size: 35,),
          backgroundColor: Color(0xFF006064),
        ),
      ),
    );
  }
}