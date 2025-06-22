// lib/Admin/screens/psychologist_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:mental_ease/Admin/providers/phycologistVerificationProvider.dart';
import 'package:provider/provider.dart';

class PsychologistVerificationScreen extends StatefulWidget {
  @override
  _PsychologistVerificationScreenState createState() => _PsychologistVerificationScreenState();
}

class _PsychologistVerificationScreenState extends State<PsychologistVerificationScreen> {
  late PsychologistVerificationProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = PsychologistVerificationProvider();
    _provider.fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _provider.setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PsychologistVerificationProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size.fromHeight(size.height * 0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(size.height * 0.03)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'User ',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                      TextSpan(
                        text: 'Verification',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Divider(thickness: 2, indent: 50, endIndent: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<PsychologistVerificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        return Column(
          children: [
            _buildSearchField(context),
            _buildFilterChips(context),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: provider.filteredUsers.length,
                itemBuilder: (context, index) {
                  return _buildUserCard(context, provider.filteredUsers[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              Provider.of<PsychologistVerificationProvider>(context, listen: false)
                  .setSearchQuery('');
              FocusScope.of(context).unfocus();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Color(0xFF80DEEA), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Color(0xFF80DEEA), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.01),

        ),
      ),
    );
  }
  Widget _buildFilterChips(BuildContext context) {
    final provider = Provider.of<PsychologistVerificationProvider>(context);
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Psychologists', 'value': 'psychologists'},
      {'label': 'Verified', 'value': 'verified'},
      {'label': 'Unverified', 'value': 'unverified'},
      {'label': 'Unlisted', 'value': 'unlisted'},
      {'label': 'Users', 'value': 'users'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: provider.currentFilter == filter['value'],
              onSelected: (selected) {
                provider.setFilter(filter['value']!);
              },
              selectedColor: Color(0xFF80DEEA),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: provider.currentFilter == filter['value']
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    final size = MediaQuery.of(context).size;
    final isPsychologist = user.role == 'Psychologist';
    final isSmallScreen = size.width < 360;

    return Card(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row with user info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: size.width * 0.08,
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null
                      ? Icon(Icons.person, size: size.width * 0.06)
                      : null,
                ),

                SizedBox(width: size.width * 0.04),

                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? user.username ?? 'No Name',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006064),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: size.height * 0.005),

                      // Role and Status Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            user.role,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.grey[600],
                            ),
                          ),

                          if (isPsychologist) ...[
                            Chip(
                              label: Text(
                                user.isVerified ?? false ? 'Verified' : 'Unverified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
                              backgroundColor: user.isVerified ?? false
                                  ? Colors.green
                                  : Colors.orange,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
                                vertical: isSmallScreen ? 0 : 2,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),

                            Chip(
                              label: Text(
                                user.isListed ?? false ? 'Listed' : 'Unlisted',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
                              backgroundColor: user.isListed ?? false
                                  ? Colors.green
                                  : Colors.red,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
                                vertical: isSmallScreen ? 0 : 2,
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ],
                      ),

                      if (isPsychologist && user.specialization != null)
                        Padding(
                          padding: EdgeInsets.only(top: size.height * 0.005),
                          child: Text(
                            user.specialization!,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Psychologist Details
            if (isPsychologist) ...[
              Divider(height: size.height * 0.03),

              _buildDetailRow(
                context,
                Icons.email,
                user.email ?? 'No email',
              ),

              if (user.phoneNumber != null)
                _buildDetailRow(
                  context,
                  Icons.phone,
                  user.phoneNumber!,
                ),

              if (user.address != null)
                _buildDetailRow(
                  context,
                  Icons.location_on,
                  user.address!,
                ),

              if (user.degreeImageUrl != null)
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.01),
                  child: InkWell(
                    onTap: () => _showDegreeImage(context, user.degreeImageUrl!),
                    child: Text(
                      'View Degree Certificate',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: isSmallScreen ? 12 : 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: size.height * 0.015),

              // Action Buttons
              if (isPsychologist)
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Verification Button
                      Flexible(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: user.isVerified ?? false
                                  ? Colors.red[400]
                                  : Color(0xFF80DEEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.012,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await Provider.of<PsychologistVerificationProvider>(
                                    context, listen: false)
                                    .toggleVerification(user.id, user.isVerified ?? false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      user.isVerified ?? false
                                          ? 'Psychologist unverified'
                                          : 'Psychologist verified',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              user.isVerified ?? false ? 'Unverify' : 'Verify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: size.width * 0.03),

                      // List/Unlist Button
                      Flexible(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: user.isListed ?? false
                                  ? Colors.red[400]
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.012,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await Provider.of<PsychologistVerificationProvider>(
                                    context, listen: false)
                                    .toggleListing(user.id, user.isListed ?? false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      user.isListed ?? false
                                          ? 'Psychologist unlisted'
                                          : 'Psychologist listed',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              user.isListed ?? false ? 'Unlist' : 'List',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 14 : 16,
            color: Colors.grey[600],
          ),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDegreeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Degree Certificate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}